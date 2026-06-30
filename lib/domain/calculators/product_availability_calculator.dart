import '../../models/inventory_item_model.dart';
import '../../models/recipe_item_model.dart';

int calculateProductAvailability({
  required List<RecipeItemModel> recipeItems,
  required Map<String, InventoryItemModel> inventoryMap,
}) {
  if (recipeItems.isEmpty) return 0;

  int? minUnits;

  for (final item in recipeItems) {
    final inventory = inventoryMap[item.inventoryItemId];

    if (inventory == null || !inventory.active) {
      return 0; // insumo no disponible
    }

    if (item.quantity <= 0) {
      return 0;
    }

    final possibleUnits = (inventory.stock / item.quantity).floor();

    minUnits = (minUnits == null)
        ? possibleUnits
        : (possibleUnits < minUnits ? possibleUnits : minUnits);
  }

  return minUnits ?? 0;
}