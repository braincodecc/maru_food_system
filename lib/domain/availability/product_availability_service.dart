
import '../../models/product.dart';
import '../../models/recipe_model.dart';
import '../../models/product_availability_model.dart';
import '../../services/inventory_service.dart';
import '../../services/recipes_service.dart';
import '../cache/inventory_cache.dart';
import '../cache/recipe_cache.dart';
import '../calculators/product_availability_calculator.dart';

class ProductAvailabilityService {
  final InventoryService inventoryService;
  final RecipesService recipesService;

  final InventoryCache inventoryCache = InventoryCache();
  final RecipeCache recipeCache = RecipeCache();

  ProductAvailabilityService({
    required this.inventoryService,
    required this.recipesService,
  });

  Stream<List<ProductAvailabilityModel>> watchAvailability(
      Stream<List<Product>> productsStream,
      ) {
    return inventoryService.getItems().asyncMap((inventoryItems) async {
      // 🔁 actualiza cache de inventario
      inventoryCache.update(inventoryItems);

      final products = await productsStream.first;
      final result = <ProductAvailabilityModel>[];

      for (final product in products) {
        RecipeModel? recipe;

        // 📦 cache de receta
        if (recipeCache.has(product.id)) {
          recipe = recipeCache.get(product.id);
        } else {
          recipe = await recipesService
              .getRecipeByProduct(product.id)
              .first;
          if (recipe != null) {
            recipeCache.set(recipe);
          }
        }

        final units = recipe == null
            ? 0
            : calculateProductAvailability(
          recipeItems: recipe.items,
          inventoryMap: inventoryCache.map,
        );

        result.add(
          ProductAvailabilityModel(
            product: product,
            availableUnits: units,
          ),
        );
      }

      return result;
    });
  }
}
