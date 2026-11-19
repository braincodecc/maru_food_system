// Importamos los adaptadores de producto y ordenes
import '../data/adapters/client_product_adapter_impl.dart';
import '../data/adapters/client_order_adapter_impl.dart';

//Importamos los proveedores de productor y ordenes
import '../presentation/providers/client_product_provider.dart';
import '../presentation/providers/client_order_provider.dart';

// Importamos las fábricas públicas de los módulos de productos y ordenes
import 'package:maru_food_system/features/product/di/product_injector.dart';
import 'package:maru_food_system/features/order/di/order_injector.dart';

ClientProductProvider createClientProductProvider() {
  // Obtenemos únicamente el caso de uso de lectura desde el módulo Product
  final getActiveProductsUseCase = createGetActiveProductsUseCase();

  // Lo envolvemos en el adaptador del cliente
  final clientProductAdapter = ClientProductAdapterImpl(
    getActiveProductsUseCase: getActiveProductsUseCase,
  );

  return ClientProductProvider(
    clientProductPort: clientProductAdapter,
  );
}

ClientOrderProvider createClientOrderProvider() {
  final clientOrderAdapter = ClientOrderAdapterImpl(
    createOrderReservationUsecase: createCreateOrderReservationUsecase(),
    confirmOrderCheckoutUseCase: createConfirmOrderCheckoutUseCase(),
    getClientOrdersUseCase: createGetClientOrdersUseCase(),
  );

  return ClientOrderProvider(
    clientOrderPort: clientOrderAdapter,
  );
}