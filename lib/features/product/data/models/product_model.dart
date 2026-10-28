import 'package:maru_food_system/features/product/domain/entities/recipe_item_entity.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_type.enum.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.type,
    required super.purchasePrice,
    required super.salePrice,
    required super.stock,
    required super.minStock,
    required super.maxStock,
    super.isActive,
    super.recipe, // Agregamos la receta al modelo
  });

  /// Factory para construir un ProductModel desde un documento de Firestore
  factory ProductModel.fromMap(String id, Map<String, dynamic> json) {
    return ProductModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      type: ProductType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'comprado'),
        orElse: () => ProductType.comprado,
      ),
      purchasePrice: (json['purchasePrice'] ?? 0.0).toDouble(),
      salePrice: (json['salePrice'] ?? 0.0).toDouble(),
      stock: json['stock'] ?? 0,
      minStock: json['minStock'] ?? 5, // Valor por defecto sugerido para alertas
      maxStock: json['maxStock'] ?? 50,
      isActive: json['isActive'] ?? true,
      recipe: (json['recipe'] as List<dynamic>?)
              ?.map((item) => RecipeItemEntity.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [], // Inicializamos la receta como lista vacía si no existe
    );
  }

  /// Convierte el modelo a un Map compatible con Firestore para guardarlo o actualizarlo
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.name, // Guarda 'fabricado' o 'comprado' como texto
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'stock': stock,
      'minStock': minStock,
      'maxStock': maxStock,
      'isActive': isActive,
      'recipe': recipe.map((item) => item.toMap()).toList(),
    };
  }

  /// Convierte una Entidad pura de dominio en un Modelo de datos
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      imageUrl: entity.imageUrl,
      type: entity.type,
      purchasePrice: entity.purchasePrice,
      salePrice: entity.salePrice,
      stock: entity.stock,
      minStock: entity.minStock,
      maxStock: entity.maxStock,
      isActive: entity.isActive,
      recipe: entity.recipe,
    );
  }

  /// Método auxiliar para clonar el modelo y modificar campos específicos si es necesario
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    ProductType? type,
    double? purchasePrice,
    double? salePrice,
    int? stock,
    int? minStock,
    int? maxStock,
    bool? isActive,
    List<RecipeItemEntity>? recipe,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      isActive: isActive ?? this.isActive,
      recipe: recipe ?? this.recipe,
    );
  }
}