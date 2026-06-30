import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/recipe_model.dart';
import '../../models/recipe_item_model.dart';
import '../../services/recipes_service.dart';

class RecipeFormScreen extends StatefulWidget {
  final Product product;
  const RecipeFormScreen({super.key, required this.product});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  StreamSubscription? _subscription;
  List<RecipeItemModel> _items = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final service = context.read<RecipesService>();
    _subscription = service.getRecipeByProduct(widget.product.id).listen((recipe) {
      if (recipe != null && mounted) {
        setState(() => _items = recipe.items);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  double get totalCost => _items.fold(0, (sum, item) => sum + item.totalCost);

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final service = context.read<RecipesService>();
      final recipe = RecipeModel(
        id: widget.product.id,
        productId: widget.product.id,
        productName: widget.product.name,
        items: _items,
        createdAt: DateTime.now(),
      );

      await service.saveRecipe(recipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receta guardada y costo actualizado'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _addItem() async {
    final result = await Navigator.pushNamed(context, '/recipe-item-add');

    if (result != null && result is RecipeItemModel && mounted) {
      setState(() {
        final index = _items.indexWhere((i) => i.inventoryItemId == result.inventoryItemId);
        if (index != -1) {
          _items[index] = result;
        } else {
          _items.add(result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receta: ${widget.product.name}'),
        actions: [
          if (!_loading)
            IconButton(icon: const Icon(Icons.save), onPressed: _save)
          else
            const Center(child: Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('No hay insumos en esta receta'))
                  : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, index) {
                  final item = _items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item.quantity} ${item.unit} x \$${item.costPerUnit.toStringAsFixed(4)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('\$${item.totalCost.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => setState(() => _items.removeAt(index)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(thickness: 2),
            _buildTotalSection(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Agregar ingrediente'),
                onPressed: _loading ? null : _addItem,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('COSTO TOTAL DE PRODUCCIÓN:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('\$${totalCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }
}