import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../order.dart';
//import '../../../product/product.dart';

class CheckoutScreen extends StatefulWidget {
  final String orderId;
  final List<OrderItemEntity> items;
  final double totalAmount;
  //final List<ProductEntity> availableProducts;

  const CheckoutScreen({
    super.key,
    required this.orderId,
    required this.items,
    required this.totalAmount,
    //required this.availableProducts,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _referenceController = TextEditingController();

  bool _isDelivery = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Pago Móvil'),
        automaticallyImplyLeading:
            false, // Evita que regresen atrás y dupliquen reservas
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Aviso de éxito de reserva
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '¡Stock reservado con éxito! Realiza tu pago para confirmar.',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Resumen del Pedido (Copia del carrito)
              const Text(
                'Detalle de tu Pedido:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      ...widget.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.quantity} x ${item.productName}'),
                              Text(
                                '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(thickness: 1.5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total a Pagar:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '\$${widget.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.deepOrange.shade200),
                ),
                child: SwitchListTile(
                  title: Text(
                    _isDelivery
                        ? 'Envío a Domicilio (Delivery)'
                        : 'Retiro en Local (Pickup)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _isDelivery
                        ? 'Tu pedido será llevado en la moto de Maru Food.'
                        : 'Pasarás a retirar tu pedido directamente por el local.',
                    style: const TextStyle(fontSize: 12),
                  ),
                  secondary: Icon(
                    _isDelivery ? Icons.delivery_dining : Icons.storefront,
                    color: Colors.deepOrange,
                    size: 30,
                  ),
                  value: _isDelivery,
                  activeThumbColor: Colors.deepOrange,
                  onChanged: (bool value) {
                    setState(() {
                      _isDelivery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Datos Bancarios de Pago Móvil
              const Text(
                'Datos para el Pago Móvil:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• Banco: Venezuela (0102)'),
                      SizedBox(height: 4),
                      Text('• Teléfono: 0412-2229975'),
                      SizedBox(height: 4),
                      Text('• Cédula: V-20.110.485'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Formulario de referencia y teléfono
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Tu Teléfono (Ej: 04141234567)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Ingresa tu teléfono' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _referenceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Referencia Bancaria (Últimos dígitos)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt_long),
                ),
                validator: (val) => val == null || val.length < 4
                    ? 'Ingresa una referencia válida'
                    : null,
              ),
              const SizedBox(height: 24),

              // Botón Enviar Comprobante
              ElevatedButton(
                onPressed: orderProvider.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;

                        final success = await orderProvider.confirmOrderPurchase(
                          orderId: widget.orderId,
                          paymentReference: _referenceController.text.trim(),
                          clientPhone: _phoneController.text.trim(),
                          isDelivery: _isDelivery,
                        );

                        if (!mounted) return;

                        if (success) {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '¡Comprobante enviado con éxito! El administrador verificará tu pago.',
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 5),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                orderProvider.errorMessage ??
                                    'Error al enviar comprobante',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: orderProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enviar Comprobante de Pago'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
