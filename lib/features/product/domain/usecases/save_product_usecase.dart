// Importaciones del modulo de producto
import '../entities/product_entity.dart';
import '../entities/product_type.enum.dart';
import '../repositories/product_repository.dart';
import '../ports/product_ingredient_port.dart';

class SaveProductUseCase {
  final ProductRepository _productRepository;
  final ProductIngredientPort _productIngredientPort;

  SaveProductUseCase({
    required ProductRepository productRepository,
    required ProductIngredientPort productIngredientPort,
  }) : _productRepository = productRepository,
       _productIngredientPort = productIngredientPort;

  Future<void> call(ProductEntity product) async {
    double totalProductionCost = 0.0;

    if (product.type == ProductType.fabricado && product.recipe.isNotEmpty) {
      for (var item in product.recipe) {
        // Pedimos el costo usando el contrato abstracto
        final unitCost = await _productIngredientPort.getIngredientUnitCost(
          item.ingredientId,
        );

        if (unitCost == null) {
          throw Exception('El ingrediente ${item.ingredientId} no existe.');
        }

        totalProductionCost += item.quantityRequired * unitCost;
      }
    } else {
      totalProductionCost = product.purchasePrice;
    }

    // APLICAMOS LA REGLA DE NEGOCIO: Toda venta debe generar ganancias
    if (product.salePrice <= totalProductionCost) {
      throw Exception(
        'El precio de venta (\$${product.salePrice}) no puede ser menor o igual al costo de producción calculado (\$${totalProductionCost.toStringAsFixed(2)}). Maru Food debe generar ganancias.',
      );
    }

    // Si el ID está vacío, es un producto nuevo; de lo contrario, se actualiza
    if (product.id.isEmpty) {
      await _productRepository.createProduct(product);
    } else {
      await _productRepository.updateProduct(product);
    }
  }
}
