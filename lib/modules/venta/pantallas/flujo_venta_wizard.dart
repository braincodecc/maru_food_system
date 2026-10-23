import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gestores/flujo_venta_provider.dart';
import 'datos_cliente_screen.dart';
import 'menu_productos_screen.dart';
import 'resumen_pago_screen.dart';

class FlujoVentaWizard extends StatefulWidget {
  const FlujoVentaWizard({super.key});

  @override
  State<FlujoVentaWizard> createState() => _FlujoVentaWizardState();
}

class _FlujoVentaWizardState extends State<FlujoVentaWizard> {
  final PageController _pageController = PageController();

  /// Cambia de pantalla de forma animada y fluida
  void _cambiarPantalla(int pagina) {
    _pageController.animateToPage(
      pagina,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Libera el controlador de la memoria al destruir el Widget (Previene Memory Leaks)
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maru Food System - Facturación'),
        centerTitle: true,
        // Agregamos un botón de salida por seguridad tipográfica si se desea cancelar el flujo completo
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Aquí puedes limpiar el flujo si el cajero decide salir al menú principal
            context.read<FlujoVentaProvider>().limpiarFlujo();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        // ¡ESTO ES LO IMPORTANTE! Protege la barra de Android de forma global
        bottom: true,
        top: true,
        child: PageView(
          controller: _pageController,
          // Bloquea gestos del dedo para control total por botones
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // PASO 1: Captura de Datos de Cliente y Ubicación de WhatsApp
            DatosClienteScreen(onSiguiente: () => _cambiarPantalla(1)),

            // PASO 2: Selección y carga de Productos al Carrito
            MenuProductosScreen(
              onAtras: () => _cambiarPantalla(0),
              onSiguiente: () => _cambiarPantalla(2),
            ),

            // PASO 3: Cierre de Caja, Selección de Método de Pago y Transacción a Firestore
            ResumenPagoScreen(
              onAtras: () => _cambiarPantalla(1),
              onVentaExitosa: () {
                // El Provider del cliente ya se limpia internamente en el CarritoProvider
                // al ejecutar despacharVentaExpress, pero nos aseguramos por arquitectura.
                context.read<FlujoVentaProvider>().limpiarFlujo();

                // Regresa al paso 0 instantáneamente sin animación para la siguiente venta rápida
                _pageController.jumpToPage(0);
              },
            ),
          ],
        ),
      ),
    );
  }
}
