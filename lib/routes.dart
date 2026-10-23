import 'package:flutter/material.dart';
import 'package:maru_food_system/models/order_model.dart';
import 'package:maru_food_system/screens/Reports/daily_reports_screen.dart';
import 'package:maru_food_system/screens/inventory/inventory_form_screen.dart';
import 'package:maru_food_system/screens/inventory/inventory_list_screen.dart';
import 'package:maru_food_system/screens/recipes/recipe_form_screen.dart';
import 'package:maru_food_system/screens/recipes/recipe_item_add_screen.dart';
import 'package:maru_food_system/screens/recipes/recipe_list_screen.dart';
import 'models/inventory_item_model.dart';
import 'models/product.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/products/product_list_screen.dart';
import 'screens/products/product_detail_screen.dart';
import 'screens/products/product_form_screen.dart';
import 'screens/sales/sale_cart_screen.dart';
import 'screens/sales/sale_checkout_screen.dart';
import 'screens/sales/sale_list_screen.dart';
import 'screens/orders/order_list_screen.dart';
import 'screens/orders/order_detail_screen.dart';
import 'screens/settings/settings_exchange_rate_screen.dart';
import 'modules/venta/pantallas/flujo_venta_wizard.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/Splash': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),

  // =========================================================
  // VENTA EXPRESS MODULAR (Maru Food System)
  // =========================================================
  // Apuntamos al Wizard que contiene el PageView y distribuye los 3 pasos.
  '/venta-express': (context) => const FlujoVentaWizard(),

  // Productos
  '/products': (context) => ProductListScreen(),
  '/products/detail': (context) => const ProductDetailScreen(),
  '/products/new': (context) => const ProductFormScreen(),
  '/products/edit': (context) {
    final product =
        ModalRoute.of(context)!.settings.arguments as Product;
    return ProductFormScreen(product: product);
  },

  // Inventario
  '/inventory': (_) => const InventoryListScreen(),
  '/inventory-form': (context) {
    final item =
    ModalRoute.of(context)?.settings.arguments as InventoryItemModel?;
    return InventoryFormScreen(item: item);
  },

  // Ventas
  '/cart': (context) => const SaleCartScreen(),
  '/checkout': (context) => const SaleCheckoutScreen(),
  '/sales': (context) => const SaleListScreen(),

  // Ordenes
  '/orders': (context) => const OrdersListScreen(),
  '/order-detail': (context) {
    final _order = ModalRoute.of(context)!.settings.arguments as OrderModel;
    return OrderDetailScreen(order: _order);
  },

  // Tipo de cambio.
  '/exchange-rate': (context) => const SettingsExchangeRateScreen(),

  //Recipes
  '/recipe-list': (context) => const RecipeListScreen(),
  '/recipe-form': (context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    return RecipeFormScreen(product: product);
  },
  '/recipe-item-add': (context) => const RecipeItemAddScreen(),

  //Reportes
  '/reports': (context) => const DailyReportsScreen(),

};
