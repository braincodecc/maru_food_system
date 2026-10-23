import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Requerido para leer el Clipboard nativo
import 'package:provider/provider.dart';
import '../gestores/flujo_venta_provider.dart';

class DatosClienteScreen extends StatefulWidget {
  final VoidCallback onSiguiente;

  const DatosClienteScreen({super.key, required this.onSiguiente});

  @override
  State<DatosClienteScreen> createState() => _DatosClienteScreenState();
}

class _DatosClienteScreenState extends State<DatosClienteScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Escuchamos los valores iniciales por si el provider ya tiene datos retenidos
    final provider = context.read<FlujoVentaProvider>();
    _nombreController.text = provider.customerName == 'Cliente Express'
        ? ''
        : provider.customerName;
    _telefonoController.text = provider.customerPhone;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios reactivos en el estado del flujo de venta
    final flujoVenta = context.watch<FlujoVentaProvider>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Paso 1: Datos del Cliente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 16),

          // Campo de Teléfono (Identificador único en caja rápida)
          TextField(
            controller: _telefonoController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Número de Teléfono',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
              hintText: 'Ej: 04121234567',
            ),
            onChanged: (valor) => flujoVenta.actualizarTelefono(valor),
          ),
          const SizedBox(height: 16),

          // Campo de Nombre
          TextField(
            controller: _nombreController,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              labelText: 'Nombre del Cliente (Opcional)',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
              hintText: 'Se guardará como Cliente Express si se deja vacío',
            ),
            onChanged: (valor) => flujoVenta.actualizarNombre(valor),
          ),
          const SizedBox(height: 24),

          const Divider(),
          const SizedBox(height: 12),

          // =========================================================
          // BOTÓN INTELIGENTE: EXTRAER UBICACIÓN DE WHATSAPP
          // =========================================================
          Card(
            elevation: flujoVenta.customerLocation != null ? 4 : 1,
            color: flujoVenta.customerLocation != null
                ? Colors.green.shade50
                : Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: flujoVenta.customerLocation != null
                    ? Colors.green
                    : Colors.grey.shade300,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      // 1. Obtenemos el texto puro guardado en el portapapeles del teléfono
                      ClipboardData? data = await Clipboard.getData(
                        Clipboard.kTextPlain,
                      );

                      if (data != null && data.text != null) {
                        try {
                          // 2. Ejecutamos la extracción limpia mediante expresiones regulares en el provider
                          flujoVenta.procesarYGuardarUbicacion(data.text!);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✅ Coordenadas de WhatsApp extraídas correctamente',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '❌ El portapapeles no contiene un formato de ubicación válido',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'El portapapeles está vacío. Copia el mensaje en WhatsApp primero.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.assignment_turned_in,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Pegar Ubicación desde WhatsApp',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: flujoVenta.customerLocation != null
                          ? Colors.green
                          : Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Indicador Dinámico del estado del LocationModel?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        flujoVenta.customerLocation != null
                            ? Icons.location_on
                            : Icons.location_off,
                        color: flujoVenta.customerLocation != null
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          flujoVenta.customerLocation != null
                              ? 'Ubicación cargada (Lat: ${flujoVenta.customerLocation!.latitude.toStringAsFixed(4)})'
                              : 'Modo: Retiro en Local / Mostrador (Pickup)',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: flujoVenta.customerLocation != null
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Botón de navegación al paso 2
          ElevatedButton(
            onPressed: widget.onSiguiente,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey.shade800,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Continuar a Productos ➔',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
