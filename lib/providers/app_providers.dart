import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/customer_service.dart';
import '../services/order_payment_service.dart';
import '../services/orders_service.dart';
import '../services/products_service.dart';
import '../services/inventory_service.dart';
import '../services/recipes_service.dart';
import '../domain/availability/product_availability_service.dart';
import '../services/reports_service.dart';
import '../services/sales_service.dart';
import '../services/settings_service.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🔹 Firebase services
        Provider<ProductsService>(
          create: (_) => ProductsService(),
        ),
        Provider<InventoryService>(
          create: (_) => InventoryService(),
        ),
        Provider<RecipesService>(
          create: (_) => RecipesService(),
        ),
        Provider<OrdersService>(
          create: (_) => OrdersService(),
        ),
        Provider<OrderPaymentService>(
          create: (_) => OrderPaymentService(),
        ),
        Provider<SalesService>(
          create: (_) => SalesService(),
        ),
        Provider<CustomerService>(
          create: (_) => CustomerService(),
        ),
        Provider<SettingsService>(
          create: (_) => SettingsService(),
        ),
        Provider<ReportsService>(
          create: (_) => ReportsService(),
        ),

        // 🔹 Domain service (availability)
        Provider<ProductAvailabilityService>(
          create: (context) => ProductAvailabilityService(
            inventoryService: context.read<InventoryService>(),
            recipesService: context.read<RecipesService>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
