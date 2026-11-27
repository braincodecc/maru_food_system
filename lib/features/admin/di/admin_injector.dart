//
// Importaciones para trabajar con el modulo de productos
//

// Adaptador de produtos
import '../data/adapters/admin_product_adapter_impl.dart';
// Proveedores de produtos
import '../presentation/providers/admin_product_provider.dart';
// Fábricas públicas del módulo de productos
import 'package:maru_food_system/features/product/di/product_injector.dart';

//
// Importaciones para trabajar con el modulo de ingredientes
//

// Adaptador de ingredientes
import '../data/adapters/admin_ingredient_adapter_impl.dart';

// Proveedores de ingredientes
import '../presentation/providers/admin_ingredient_provider.dart';

// Fábricas públicas del módulo de ingredientes
import 'package:maru_food_system/features/ingredient/di/ingredient_injector.dart';

//
// Importaciones para trabajar con el modulo de ordenes
//

// Adaptador de ordenes
import '../data/adapters/admin_order_adapter_impl.dart';

// Proveedores de ordenes
import '../presentation/providers/admin_order_provider.dart';

// Fábricas públicas del módulo de ordenes
import 'package:maru_food_system/features/order/di/order_injector.dart';

//
// Importaciones para trabajar con el modulo de finanzas
//

// Adaptador de finanzas
import '../data/adapters/admin_finance_adapter_impl.dart';

// Proveedores de finanzas
import '../presentation/providers/admin_finance_provider.dart';

// Fábricas públicas del módulo de finanzas
import 'package:maru_food_system/features/finance/di/finance_injector.dart';

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
        createOrderReservationUsecase: createCreateOrderReservationUsecase(),
    confirmOrderCheckoutUseCase: createConfirmOrderCheckoutUseCase(),
    updateOrderStatusUseCase: createUpdateOrderStatusUseCase(),
  );

  return AdminOrderProvider(adminOrderPort: adminOrderAdapter);
}

AdminFinanceProvider createAdminFinanceProvider() {
  final adminFinanceAdapter = AdminFinanceAdapterImpl(
    getFinancialAccountsUseCase: createGetFinancialAccountsUseCase(),
    getTransactionsByAccountUseCase: createGetTransactionsByAccountUseCase(),
    transferAccountFundsUseCase: createTransferAccountFundsUseCase(),
  );

  return AdminFinanceProvider(
    adminFinancePort: adminFinanceAdapter,
  );
}