import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../order.dart';
import '../../../product/product.dart';

class CheckoutScreen extends StatefulWidget {
  final String orderId;
  final Map<String, int> cartItems;
  final double totalAmount;
  final List<ProductEntity> availableProducts;

  const CheckoutScreen({
    super.key,
    required this.orderId,
    required this.cartItems,
    required this.totalAmount,
    required this.availableProducts,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _referenceController = TextEditingController();

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
                      ...widget.cartItems.entries.map((entry) {
                        final product = widget.availableProducts.firstWhere(
                          (p) => p.id == entry.key,
                          orElse: () => ProductEntity(
                            id: '',
                            name: 'Producto',
                            description: '',
                            imageUrl: '',
                            type: ProductType.comprado,
                            purchasePrice: 0,
                            salePrice: 0,
                            stock: 0,
                            minStock: 0,
                            maxStock: 0,
                            isActive: true,
                            recipe: [],
                          ),
                        );
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${entry.value} x ${product.name}'),
                              Text(
                                '\$${(product.salePrice * entry.value).toStringAsFixed(2)}',
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

                        final success = await orderProvider.submitPayment(
                          orderId: widget.orderId,
                          paymentReference: _referenceController.text.trim(),
                          clientPhone: _phoneController.text.trim(),
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
