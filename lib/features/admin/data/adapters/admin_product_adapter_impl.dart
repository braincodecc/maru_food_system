import '../../domain/ports/admin_product_port.dart';
import 'package:maru_food_system/features/product/domain/entities/product_entity.dart';
import 'package:maru_food_system/features/product/domain/usecases/get_active_products_usecase.dart';
import 'package:maru_food_system/features/product/domain/usecases/save_product_usecase.dart';
import 'package:maru_food_system/features/product/domain/usecases/delete_product_usecase.dart';

class AdminProductAdapterImpl implements AdminProductPort {
  final GetActiveProductsUseCase _getActiveProductsUseCase;
  final SaveProductUseCase _saveProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;

  AdminProductAdapterImpl({
    required GetActiveProductsUseCase getActiveProductsUseCase,
    required SaveProductUseCase saveProductUseCase,
    required DeleteProductUseCase deleteProductUseCase,
  })  : _getActiveProductsUseCase = getActiveProductsUseCase,
        _saveProductUseCase = saveProductUseCase,
        _deleteProductUseCase = deleteProductUseCase;

  @override
  Future<List<ProductEntity>> getProducts() async {
    return await _getActiveProductsUseCase();
  }

  @override
  Future<void> saveProduct(ProductEntity product) async {
    await _saveProductUseCase(product);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _deleteProductUseCase(productId);
  }
}