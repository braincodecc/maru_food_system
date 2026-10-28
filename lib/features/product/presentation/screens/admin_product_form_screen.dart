import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../product.dart';
import '../../../ingredient/ingredient.dart';

class AdminProductFormScreen extends StatefulWidget {
  // Si viene un producto, estamos editando; si es nulo, estamos creando.
  final ProductEntity? productToEdit;

  const AdminProductFormScreen({super.key, this.productToEdit});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late TextEditingController _maxStockController;

  ProductType _selectedType = ProductType.comprado;
  bool _isActive = true;
  bool _isLoading = false;

  // Lista local para gestionar la receta mientras se edita o crea el producto
  final List<RecipeItemEntity> _recipeItems = [];

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;

    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _purchasePriceController = TextEditingController(
      text: p != null ? p.purchasePrice.toString() : '',
    );
    _salePriceController = TextEditingController(
      text: p != null ? p.salePrice.toString() : '',
    );
    _stockController = TextEditingController(
      text: p != null ? p.stock.toString() : '10',
    );
    _minStockController = TextEditingController(
      text: p != null ? p.minStock.toString() : '5',
    );
    _maxStockController = TextEditingController(
      text: p != null ? p.maxStock.toString() : '50',
    );

    if (p != null) {
      _selectedType = p.type;
      _isActive = p.isActive;
      _recipeItems.addAll(
        p.recipe,
      ); // Cargamos la receta existente si se está editando
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;
    final ingredientProvider = context.watch<IngredientProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Producto' : 'Nuevo Producto - Maru Food',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tipo de Producto
              DropdownButtonFormField<ProductType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Producto',
                  border: OutlineInputBorder(),
                ),
                items: ProductType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type == ProductType.fabricado
                          ? 'Fabricado (Con Receta)'
                          : 'Comprado (Directo)',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Plato o Producto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingresa una descripción'
                    : null,
              ),
              const SizedBox(height: 16),

              // URL de Imagen
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la Imagen',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Precios: Compra y Venta (Para control de ganancias)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _purchasePriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Precio de Compra / Costo (\$)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => double.tryParse(value ?? '') == null
                          ? 'Costo inválido'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _salePriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Precio de Venta (\$)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => double.tryParse(value ?? '') == null
                          ? 'Precio inválido'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stock y Alertas de Reposición (Mínimo y Máximo)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Actual',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          int.tryParse(value ?? '') == null ? 'Inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _minStockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Mín. (Alerta)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          int.tryParse(value ?? '') == null ? 'Inválido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxStockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Máximo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          int.tryParse(value ?? '') == null ? 'Inválido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // SECCIÓN CONDICIONAL: Si es FABRICADO, mostramos la gestión de la receta
              if (_selectedType == ProductType.fabricado) ...[
                const Divider(thickness: 2),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Receta / Lista de Ingredientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.deepOrange,
                        size: 28,
                      ),
                      tooltip: 'Agregar Ingrediente a la Receta',
                      onPressed: () => _showAddRecipeItemDialog(
                        context,
                        ingredientProvider.ingredients,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _recipeItems.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'Este producto fabricado aún no tiene ingredientes en su receta. Presiona "+" para agregarlos.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recipeItems.length,
                        itemBuilder: (context, index) {
                          final item = _recipeItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                item.ingredientName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Cantidad requerida por plato: ${item.quantityRequired}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _recipeItems.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 8),
                const Divider(thickness: 2),
              ],
              const SizedBox(height: 16),

              // Estado Activo / Inactivo
              SwitchListTile(
                title: const Text('Producto Activo en Menú'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 24),

              // Botón Guardar
              ElevatedButton(
                onPressed: _isLoading ? null : () => _saveProduct(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditing ? 'Actualizar Producto' : 'Crear Producto',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Diálogo para seleccionar un ingrediente del almacén y definir su cantidad en la receta
  void _showAddRecipeItemDialog(
    BuildContext context,
    List<IngredientEntity> availableIngredients,
  ) {
    if (availableIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero debes registrar ingredientes en el almacén.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    IngredientEntity? selectedIngredient = availableIngredients.first;
    final qtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir a la Receta'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<IngredientEntity>(
                initialValue: selectedIngredient,
                decoration: const InputDecoration(
                  labelText: 'Seleccionar Insumo',
                  border: OutlineInputBorder(),
                ),
                items: availableIngredients.map((ing) {
                  return DropdownMenuItem(
                    value: ing,
                    child: Text('${ing.name} (${ing.unit})'),
                  );
                }).toList(),
                onChanged: (val) =>
                    setStateDialog(() => selectedIngredient = val),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qtyController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Cantidad requerida',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text);
              if (qty == null || qty <= 0 || selectedIngredient == null) return;

              setState(() {
                // Verificamos si ya estaba agregado para actualizarlo o sumarlo
                final existingIndex = _recipeItems.indexWhere(
                  (i) => i.ingredientId == selectedIngredient!.id,
                );
                if (existingIndex >= 0) {
                  _recipeItems[existingIndex] = RecipeItemEntity(
                    ingredientId: selectedIngredient!.id,
                    ingredientName: selectedIngredient!.name,
                    quantityRequired: qty,
                  );
                } else {
                  _recipeItems.add(
                    RecipeItemEntity(
                      ingredientId: selectedIngredient!.id,
                      ingredientName: selectedIngredient!.name,
                      quantityRequired: qty,
                    ),
                  );
                }
              });

              Navigator.pop(context);
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _saveProduct(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final productProvider = context.read<ProductProvider>();

    final product = ProductEntity(
      id:
          widget.productToEdit?.id ??
          '', // Vacío = Crea documento nuevo con ID autogenerado en Firestore
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      type: _selectedType,
      purchasePrice: double.parse(_purchasePriceController.text),
      salePrice: double.parse(_salePriceController.text),
      stock: int.parse(_stockController.text),
      minStock: int.parse(_minStockController.text),
      maxStock: int.parse(_maxStockController.text),
      isActive: _isActive,
      recipe: _selectedType == ProductType.fabricado ? _recipeItems : [], // Guardamos la receta si es fabricado
    );

    final success = await productProvider.saveProduct(product);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Producto guardado exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.errorMessage ?? 'Error desconocido'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
