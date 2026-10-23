import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../gestores/carrito_provider.dart';
import '../gestores/flujo_venta_provider.dart';
import 'componentes/header_ver_pedido.dart';

class ResumenPagoScreen extends StatefulWidget {
  final VoidCallback onAtras;
  final VoidCallback
  onVentaExitosa; // Callback para reiniciar el PageView principal al finalizar

  const ResumenPagoScreen({
    super.key,
    required this.onAtras,
    required this.onVentaExitosa,
  });

  @override
  State<ResumenPagoScreen> createState() => _ResumenPagoScreenState();
}

class _ResumenPagoScreenState extends State<ResumenPagoScreen> {
  String _metodoPagoSeleccionated = 'Efectivo USD';
  final TextEditingController _referenciaController = TextEditingController();
  bool _estaProcesando = false;

  // Lista de métodos de pago comunes en los comercios de Venezuela
  final List<String> _metodosPago = [
    'Efectivo USD',
    'Efectivo Bs',
    'Pago Móvil',
    'Zelle',
    'Punto de Venta',
  ];

  @override
  void dispose() {
    _referenciaController.dispose();
    super.dispose();
  }

  /// Ejecuta el proceso definitivo de guardado delegando al CarritoProvider
  Future<void> _finalizarDespacho(BuildContext context) async {
    final carrito = context.read<CarritoProvider>();
    final flujoCliente = context.read<FlujoVentaProvider>();

    setState(() {
      _estaProcesando = true;
    });

    try {
      // Invocamos el método del core híbrido pasando los datos recolectados en los 3 pasos
      await carrito.despacharVentaExpress(
        datosCliente: flujoCliente,
        metodoPago: _metodoPagoSeleccionated,
        referenciaPago: _referenciaController.text.trim().isEmpty
            ? null
            : _referenciaController.text.trim(),
      );

      // Si Firestore responde con éxito, mostramos un feedback positivo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 ¡Venta Express registrada y despachada con éxito!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Notificamos al widget padre para que reinicie todo el wizard al paso 0
      widget.onVentaExitosa();
    } catch (e) {
      // Manejo de errores de conexión o escritura en Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al guardar en base de datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _estaProcesando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos los proveedores en modo lectura reactiva
    final carrito = context.watch<CarritoProvider>();
    final flujoCliente = context.watch<FlujoVentaProvider>();

    // Bandera lógica para saber si el método requiere registrar un número de transacción
    bool requiereReferencia =
        _metodoPagoSeleccionated == 'Pago Móvil' ||
        _metodoPagoSeleccionated == 'Zelle' ||
        _metodoPagoSeleccionated == 'Punto de Venta';

    return carrito.items.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Tu carrito se quedó vacío!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No puedes procesar un pago sin productos seleccionados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _estaProcesando ? null : widget.onAtras,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Regresar a Productos'),
                  ),
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==========================================
                // 1. SECCIÓN FIJA SUPERIOR (Siempre visible)
                // ==========================================
                HeaderVerPedido(titulo: 'Paso 3: Cierre y Facturación'),
                const SizedBox(height: 16),

                // TARJETA DE RECAUDACIÓN (Totales Financieros en caliente)
                Card(
                  color: Colors.grey.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'TOTAL A COBRAR',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${carrito.totalUsd.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${carrito.totalBs.toStringAsFixed(2)} Bs.',
                          style: TextStyle(
                            color: Colors.orange.shade300,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Cliente:',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              flujoCliente.customerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tasa Aplicada:',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              '${carrito.tasaCambio.toStringAsFixed(2)} Bs/\$',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // =======================================================
                // 2. SECCIÓN DINÁMICA CON SCROLL (Solo Métodos de Pago)
                // =======================================================
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Seleccione el Método de Pago:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _metodoPagoSeleccionated,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                          ),
                          items: _metodosPago.map((metodo) {
                            return DropdownMenuItem<String>(
                              value: metodo,
                              child: Text(metodo),
                            );
                          }).toList(),
                          onChanged: (nuevoValor) {
                            if (nuevoValor != null) {
                              setState(() {
                                _metodoPagoSeleccionated = nuevoValor;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // CAMPO DE REFERENCIA DINÁMICO
                        if (requiereReferencia) ...[
                          TextField(
                            controller: _referenciaController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Número de Referencia / Aprobación',
                              prefixIcon: const Icon(Icons.receipt_long),
                              hintText: 'Ej: Últimos 4 o 6 dígitos',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.orange.shade50,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ), // Espacio extra interno al abrir teclado
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ), // Separador controlado de la botonera
                // ==========================================
                // 3. SECCIÓN FIJA INFERIOR (Siempre visible)
                // ==========================================
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _estaProcesando ? null : widget.onAtras,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          '➔ Atrás',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _estaProcesando
                            ? null
                            : () => _finalizarDespacho(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _estaProcesando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                '⚡ Procesar y Despachar',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
