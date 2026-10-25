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
  });

  /// Factory para construir un ProductModel desde un documento de Firestore
  factory ProductModel.fromJson(String id, Map<String, dynamic> json) {
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
    );
  }

  /// Convierte el modelo a un Map compatible con Firestore para guardarlo o actualizarlo
  Map<String, dynamic> toJson() {
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
    };
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
    );
  }
}