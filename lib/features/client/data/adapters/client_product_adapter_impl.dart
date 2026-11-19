import 'package:maru_food_system/features/product/domain/entities/product_entity.dart';
import 'package:maru_food_system/features/product/domain/usecases/get_active_products_usecase.dart';
import '../../domain/ports/client_product_port.dart';

class ClientProductAdapterImpl implements ClientProductPort {
  final GetActiveProductsUseCase _getActiveProductsUseCase;

  ClientProductAdapterImpl({
    required GetActiveProductsUseCase getActiveProductsUseCase,
  }) : _getActiveProductsUseCase = getActiveProductsUseCase;

  @override
  Future<List<ProductEntity>> getActiveProducts() async {
    return await _getActiveProductsUseCase();
  }
}