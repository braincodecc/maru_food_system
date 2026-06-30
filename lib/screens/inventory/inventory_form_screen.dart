import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/inventory_item_model.dart';
import '../../services/inventory_service.dart';

class InventoryFormScreen extends StatefulWidget {
  final InventoryItemModel? item;

  const InventoryFormScreen({
    super.key,
    this.item,
  });

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _nameCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _costCtrl = TextEditingController();

  String _unit = 'unidad';
  bool _active = true;
  bool _loading = false; // Agregado

  final List<String> _units = ['unidad', 'kg', 'gr', 'lt', 'ml'];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameCtrl.text = widget.item!.name;
      _stockCtrl.text = widget.item!.stock.toString();
      _costCtrl.text = widget.item!.costPerUnit.toString();
      _unit = widget.item!.unit;
      _active = widget.item!.active;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stockCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final stock = double.tryParse(_stockCtrl.text);
    final cost = double.tryParse(_costCtrl.text);

    if (_nameCtrl.text.isEmpty || stock == null || cost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos inválidos'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true); // Iniciar carga

    try {
      final inventoryService = context.read<InventoryService>();
      final item = InventoryItemModel(
        id: widget.item?.id ?? '',
        name: _nameCtrl.text.trim(),
        unit: _unit,
        stock: stock,
        costPerUnit: cost,
        active: _active,
        createdAt: widget.item?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.item == null) {
        await inventoryService.addItem(item);
      } else {
        await inventoryService.updateItem(item);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guardado exitosamente'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _loading = false); // Liberar botón en caso de error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Nuevo Insumo' : 'Editar Insumo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del insumo', border: OutlineInputBorder()),
              enabled: !_loading, // Deshabilitar si está cargando
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _unit,
              items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: _loading ? null : (value) => setState(() => _unit = value!),
              decoration: const InputDecoration(labelText: 'Unidad', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _stockCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Stock actual', border: OutlineInputBorder()),
              enabled: !_loading,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _costCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Costo por unidad (USD)', border: OutlineInputBorder()),
              enabled: !_loading,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Insumo activo'),
              value: _active,
              onChanged: _loading ? null : (value) => setState(() => _active = value),
              activeColor: Colors.green,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
