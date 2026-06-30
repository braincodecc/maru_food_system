import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/inventory_item_model.dart';
import '../../models/recipe_item_model.dart';
import '../../services/inventory_service.dart';

class RecipeItemAddScreen extends StatefulWidget {
  const RecipeItemAddScreen({super.key});

  @override
  State<RecipeItemAddScreen> createState() => _RecipeItemAddScreenState();
}

class _RecipeItemAddScreenState extends State<RecipeItemAddScreen> {
  InventoryItemModel? _selectedItem;
  final _qtyCtrl = TextEditingController();

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final qty = double.tryParse(_qtyCtrl.text);

    if (_selectedItem == null || qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione un insumo y cantidad válida'),
        ),
      );
      return;
    }

    // 2. Ya tenemos los datos, no hace falta llamar al servicio otra vez
    final recipeItem = RecipeItemModel(
      inventoryItemId: _selectedItem!.id,
      name: _selectedItem!.name,
      quantity: qty,
      unit: _selectedItem!.unit,
      costPerUnit: _selectedItem!.costPerUnit,
    );

    Navigator.pop(context, recipeItem);
  }

  @override
  Widget build(BuildContext context) {
    final inventoryService = context.read<InventoryService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar insumo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StreamBuilder<List<InventoryItemModel>>(
              stream: inventoryService.getItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) return const Text('No hay insumos activos');

                return DropdownButtonFormField<InventoryItemModel>(
                  isExpanded: true,
                  initialValue: _selectedItem,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar Insumo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory_2),
                  ),
                  // Mapeamos el objeto completo como valor
                  items: items.map((item) {
                    return DropdownMenuItem<InventoryItemModel>(
                      value: item,
                      child: Text(
                        '${item.name} (Stock: ${item.stock} ${item.unit})',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedItem = value),
                  selectedItemBuilder: (context) {
                    return items.map((item) {
                      return Text(
                        item.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    }).toList();
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Cantidad a usar',
                helperText: _selectedItem != null
                    ? 'Unidad de medida: ${_selectedItem!.unit}'
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                onPressed: _confirm,
                label: const Text('Agregar a la receta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
