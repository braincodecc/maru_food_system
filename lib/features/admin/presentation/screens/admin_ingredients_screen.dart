import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maru_food_system/app/routes/app_routes.dart';
import '../../../identity/identity.dart';
// Importamos el proveedor de ingredientes
import '../providers/admin_ingredient_provider.dart';

// Importamos del modulo de ingredientes sus entidades y enumerables
import 'package:maru_food_system/features/ingredient/domain/entities/ingredient_entity.dart';

class AdminIngredientsScreen extends StatelessWidget {
  const AdminIngredientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final identityProvider = context.watch<IdentityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración - Maru Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await identityProvider.logout();
              // AuthWrapper redirigirá automáticamente al Login
              // Limpiamos todo el historial de navegación y regresamos al AuthWrapper raíz ('/')
              Navigator.pushNamedAndRemoveUntil(
                // Elimina todas las pantallas superiores de la pila
                context,
                AppRoutes.initial,
                (route) =>
                    false, // Elimina todas las pantallas anteriores de la pila
              );
            },
          ),
        ],
      ),
      body: AdminIngredientsBody(),
    );
  }
}

class AdminIngredientsBody extends StatefulWidget {
  const AdminIngredientsBody({super.key});
  @override
  State<AdminIngredientsBody> createState() => _AdminIngredientsBodyState();
}

class _AdminIngredientsBodyState extends State<AdminIngredientsBody> {
  @override
  Widget build(BuildContext context) {
    final ingredientProvider = context.watch<AdminIngredientProvider>();
    Widget content;

    ingredientProvider.isLoading
        ? content = const Center(child: CircularProgressIndicator())
        : ingredientProvider.errorMessage != null
        ? content = Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    ingredientProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ingredientProvider.loadIngredients(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          )
        : ingredientProvider.ingredients.isEmpty
        ? content = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.kitchen_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay ingredientes registrados en el almacén.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showIngredientForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Primer Ingrediente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          )
        : content = ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ingredientProvider.ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = ingredientProvider.ingredients[index];
              final bool isLowStock = ingredient.needsRestock;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isLowStock
                      ? const BorderSide(color: Colors.red, width: 1.5)
                      : BorderSide.none,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    ingredient.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Costo Unitario: \$${ingredient.unitCost.toStringAsFixed(2)} por ${ingredient.unit}',
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Stock: ${ingredient.stock} ${ingredient.unit}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isLowStock
                                  ? Colors.red
                                  : Colors.green[700],
                            ),
                          ),
                          if (isLowStock) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '¡Almacén bajo!',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.deepOrange),
                    tooltip: 'Editar Ingrediente',
                    onPressed: () => _showIngredientForm(
                      context,
                      ingredientToEdit: ingredient,
                    ),
                  ),
                ),
              );
            },
          );

    return Stack(
      children: [
        content,
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showIngredientForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Ingrediente'),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Muestra un BottomSheet o Diálogo para Crear / Editar un Ingrediente
  void _showIngredientForm(
    BuildContext context, {
    IngredientEntity? ingredientToEdit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _IngredientFormWidget(ingredientToEdit: ingredientToEdit),
      ),
    );
  }
}

// Widget interno del formulario para mantener la limpieza del código
class _IngredientFormWidget extends StatefulWidget {
  final IngredientEntity? ingredientToEdit;

  const _IngredientFormWidget({this.ingredientToEdit});

  @override
  State<_IngredientFormWidget> createState() => _IngredientFormWidgetState();
}

class _IngredientFormWidgetState extends State<_IngredientFormWidget> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _unitController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late TextEditingController _unitCostController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final ing = widget.ingredientToEdit;

    _nameController = TextEditingController(text: ing?.name ?? '');
    _unitController = TextEditingController(text: ing?.unit ?? 'gramos');
    _stockController = TextEditingController(
      text: ing != null ? ing.stock.toString() : '100',
    );
    _minStockController = TextEditingController(
      text: ing != null ? ing.minStock.toString() : '20',
    );
    _unitCostController = TextEditingController(
      text: ing != null ? ing.unitCost.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _unitCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.ingredientToEdit != null;

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing
                    ? 'Editar Ingrediente'
                    : 'Nuevo Ingrediente en Almacén',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Insumo (ej: Carne, Pan)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Unidad de Medida (ej: gramos, unidades, ml)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Ingresa la unidad' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Stock Actual',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => double.tryParse(val ?? '') == null
                          ? 'Inválido'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _minStockController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Stock Mín. (Alerta)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => double.tryParse(val ?? '') == null
                          ? 'Inválido'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitCostController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Costo Unitario (\$)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => double.tryParse(val ?? '') == null
                    ? 'Costo inválido'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _save(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditing
                            ? 'Actualizar Ingrediente'
                            : 'Guardar Ingrediente',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final ingredientProvider = context.read<AdminIngredientProvider>();

    final ingredient = IngredientEntity(
      id: widget.ingredientToEdit?.id ?? '',
      name: _nameController.text.trim(),
      unit: _unitController.text.trim(),
      stock: double.parse(_stockController.text),
      minStock: double.parse(_minStockController.text),
      unitCost: double.parse(_unitCostController.text),
    );

    final success = await ingredientProvider.saveIngredient(ingredient);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Ingrediente guardado con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ingredientProvider.errorMessage ?? 'Error al guardar',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
