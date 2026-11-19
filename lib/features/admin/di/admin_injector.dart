// Adaptadores de productor e ingredientes
import '../data/adapters/admin_product_adapter_impl.dart';
import '../data/adapters/admin_ingredient_adapter_impl.dart';
import '../data/adapters/admin_order_adapter_impl.dart';

// Proveedores de productor e ingredientes
import '../presentation/providers/admin_product_provider.dart';
import '../presentation/providers/admin_ingredient_provider.dart';
import '../presentation/providers/admin_order_provider.dart';

// Importamos las fábricas públicas del módulo de productos e ingredientes
import 'package:maru_food_system/features/product/di/product_injector.dart';
import 'package:maru_food_system/features/ingredient/di/ingredient_injector.dart';
import 'package:maru_food_system/features/order/di/order_injector.dart';

AdminProductProvider createAdminProductProvider() {
  final adminProductAdapter = AdminProductAdapterImpl(
    getActiveProductsUseCase: createGetActiveProductsUseCase(),
    saveProductUseCase: createSaveProductUseCase(),
    deleteProductUseCase: createDeleteProductUseCase(),
  );

  return AdminProductProvider(adminProductPort: adminProductAdapter);
}

AdminIngredientProvider createAdminIngredientProvider() {
  final adminIngredientAdapter = AdminIngredientAdapterImpl(
    getIngredientsUseCase: createGetIngredientsUseCase(),
    saveIngredientUseCase: createSaveIngredientUseCase(),
    deleteIngredientUseCase: createDeleteIngredientUseCase(),
  );

  return AdminIngredientProvider(adminIngredientPort: adminIngredientAdapter);
}

AdminOrderProvider createAdminOrderProvider() {
  final adminOrderAdapter = AdminOrderAdapterImpl(
    getAdminOrdersUseCase: createGetAdminOrdersUseCase(),
    updateOrderStatusUseCase: createUpdateOrderStatusUseCase(),
  );

  return AdminOrderProvider(adminOrderPort: adminOrderAdapter);
}
