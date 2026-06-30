import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../services/products_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _costCtrl = TextEditingController();

  bool _active = true;
  double _profit = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      _nameCtrl.text = widget.product!.name;
      _priceCtrl.text = widget.product!.priceUsd.toString();
      _costCtrl.text = widget.product!.costUsd.toString();
      _active = widget.product!.active;
      _profit = widget.product!.profitUsd;
    }

    _priceCtrl.addListener(_calculateProfit);
    _costCtrl.addListener(_calculateProfit);
  }

  @override
  Widget build(BuildContext context) {
    final profitColor = _profit >= 0 ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Nuevo Producto' : 'Editar Producto',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Nombre
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            /// Precio USD
            TextField(
              controller: _priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Precio USD',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            /// Costo USD
            TextField(
              controller: _costCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Costo USD',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            /// Ganancia (solo lectura)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ganancia: \$${_profit.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: profitColor,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// Activo / Inactivo
            SwitchListTile(
              title: const Text('Producto activo'),
              subtitle: Text(
                _active ? 'Disponible para la venta' : 'No disponible',
              ),
              value: _active,
              onChanged: (value) {
                setState(() => _active = value);
              },
              activeColor: Colors.green,
            ),

            const SizedBox(height: 20),

            /// Guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  void _calculateProfit() {
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final cost = double.tryParse(_costCtrl.text) ?? 0;

    setState(() {
      _profit = price - cost;
    });
  }

  Future<void> _save() async {
    final price = double.tryParse(_priceCtrl.text);
    final cost = double.tryParse(_costCtrl.text);
    final productsService = context.read<ProductsService>();

    if (_nameCtrl.text.isEmpty || price == null || cost == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Datos inválidos')));
      return;
    }

    if (price < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El precio de venta no puede ser menor al costo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameCtrl.text.trim(),
        priceUsd: price,
        costUsd: cost,
        profitUsd: price - cost,
        active: _active,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.product == null) {
        await productsService.addProduct(product);
      } else {
        await productsService.updateProduct(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Solo cerramos si tuvo éxito
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'), // Mensaje corregido
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _loading = false);
    }
    // Eliminamos el Navigator.pop que estaba aquí afuera
  }
}
