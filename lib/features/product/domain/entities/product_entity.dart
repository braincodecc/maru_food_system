import 'product_type.enum.dart';
import 'recipe_item_entity.dart';

class ProductEntity {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final ProductType type;
  
  // Precios y Finanzas
  final double purchasePrice; // Precio de compra / costo
  final double salePrice;     // Precio de venta al público
  
  // Control de Inventario y Alertas
  final int stock;            // Stock actual disponible en servidor/caché
  final int minStock;         // Cantidad mínima (alerta para reponer)
  final int maxStock;         // Cantidad máxima deseada en inventario
  
  final bool isActive;        // Para habilitar o deshabilitar el producto en el menú

  final List<RecipeItemEntity> recipe; // Vacío si es 'comprado', con elementos si es 'fabricado'

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.purchasePrice,
    required this.salePrice,
    required this.stock,
    required this.minStock,
    required this.maxStock,
    this.isActive = true,
    this.recipe = const [],
  });

  /// Getter de negocio para calcular la ganancia unitaria (Margen)
  double get profitMargin => salePrice - purchasePrice;

  /// Getter de negocio para calcular el porcentaje de ganancia
  double get profitPercentage => purchasePrice > 0 
      ? ((profitMargin / purchasePrice) * 100) 
      : 0.0;

  /// Getter para saber si el producto está en estado crítico de stock (necesita reposición)
  bool get needsRestock => stock <= minStock;
}