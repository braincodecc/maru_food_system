import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../models/order_model.dart';
import '../../models/order_item_model.dart';
import '../../models/customer_model.dart';

import '../../providers/cart_provider.dart';
import '../../services/orders_service.dart';
import '../../services/settings_service.dart';
import '../../services/customer_service.dart';

class SaleCheckoutScreen extends StatefulWidget {
  const SaleCheckoutScreen({super.key});

  @override
  State<SaleCheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<SaleCheckoutScreen> {
  // 1. Controladores con nombres claros
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();

  String _paymentMethod = 'efectivo';
  String _currency = 'USD';
  bool _isSubmitting = false;

  // 2. Estado de búsqueda
  Timer? _debounce;
  List<CustomerModel> _suggestedCustomers = [];
  CustomerModel? _selectedCustomer;
  LocationModel? _manualLocation;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _referenceCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------
  // LÓGICA DE CLIENTES
  // ------------------------------------------------------
  void _onPhoneChanged(String value) {
    if (_selectedCustomer != null && value != _selectedCustomer!.phone) {
      setState(() => _selectedCustomer = null); // Reset si el usuario edita
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.length < 4) {
        if (mounted) setState(() => _suggestedCustomers = []);
        return;
      }
      final results = await context.read<CustomerService>().searchByPhone(
        value,
      );
      if (mounted) setState(() => _suggestedCustomers = results);
    });
  }

  void _selectCustomer(CustomerModel customer) {
    setState(() {
      _selectedCustomer = customer;
      _nameCtrl.text = customer.name;
      _phoneCtrl.text = customer.phone;
      _addressCtrl.text = customer.address ?? '';
      _suggestedCustomers = [];
    });
    FocusScope.of(context).unfocus(); // Cierra el teclado
  }

  // ------------------------------------------------------
  // UI COMPONENTS
  // ------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final settingsService = context.read<SettingsService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Pedido')),
      body: StreamBuilder<double>(
        stream: settingsService.getExchangeRate(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final rate = snapshot.data!;
          return Stack(
            // Stack para que las sugerencias floten
            children: [
              _buildMainForm(cart, rate),
              if (_suggestedCustomers.isNotEmpty) _buildSuggestionsOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainForm(CartProvider cart, double rate) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('CLIENTE'),
        const SizedBox(height: 12),
        _buildTextField(_nameCtrl, 'Nombre del cliente', Icons.person),
        const SizedBox(height: 12),
        _buildPhoneField(), // Campo de teléfono especial
        const SizedBox(height: 16),
        _buildLocationSection(),
        const Divider(height: 40),
        _buildSectionTitle('PAGO'),
        _buildPaymentSelectors(),
        const SizedBox(height: 24),
        _buildOrderSummary(cart),
        const SizedBox(height: 24),
        _buildTotalCard(cart.totalPrice, cart.totalPrice * rate, rate),
        const SizedBox(height: 24),
        _buildConfirmButton(cart, rate),
      ],
    );
  }

  // 3. Widget de sugerencias mejorado
  Widget _buildSuggestionsOverlay() {
    return Positioned(
      top: 180, // Ajustar según posición del campo teléfono
      left: 16,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _suggestedCustomers.length,
            itemBuilder: (context, index) {
              final c = _suggestedCustomers[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(c.name),
                subtitle: Text(c.phone),
                onTap: () => _selectCustomer(c),
              );
            },
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------
  // LÓGICA DE PROCESAMIENTO
  // ------------------------------------------------------

  Future<void> _confirmOrder(CartProvider cart, double rate) async {
    setState(() => _isSubmitting = true);

    try {
      final validationError = await _getValidationError();

      if (validationError != null) {
        _showSnackBar(validationError, isError: true);
        setState(() => _isSubmitting = false);
        return;
      }

      final customerService = context.read<CustomerService>();
      CustomerModel customer;

      if (_selectedCustomer == null) {
        final existing = await customerService.getByPhone(
          _phoneCtrl.text.trim(),
        );
        if (existing != null) {
          customer = existing;
        } else {
          customer = await customerService.create(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            location:
                _manualLocation ??
                LocationModel(
                              latitude: 0, 
            longitude: 0,
                  address: 'Sin GPS',
                ),
          );
        }
      } else {
        customer = _selectedCustomer!;
      }

      customer = await _syncCustomerData(customer, customerService);

      final order = _prepareOrderModel(cart, customer, rate);
      await context.read<OrdersService>().createOrder(order);

      if (mounted) {
        cart.clear();
        Navigator.pop(context);
        _showSnackBar('¡Orden procesada con éxito!');
      }
    } catch (e) {
      _showError('Error crítico: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<CustomerModel> _syncCustomerData(
    CustomerModel c,
    CustomerService service,
  ) async {
    final newAddress = _addressCtrl.text.trim();
    final bool hasNewCoords = _manualLocation != null;
    final bool hasNewAddress = c.address != newAddress;

    if (!hasNewCoords && !hasNewAddress) return c;

    final Map<String, dynamic> updates = {
      if (hasNewAddress) 'address': newAddress,
      if (hasNewCoords) 'location': _manualLocation!.toMap(),
    };

    await service.update(id: c.id, data: updates);

    return c.copyWith(
      address: hasNewAddress ? newAddress : null,
      location: hasNewCoords ? _manualLocation : null,
    );
  }

  OrderModel _prepareOrderModel(
    CartProvider cart,
    CustomerModel customer,
    double rate,
  ) {
    return OrderModel(
      id: '',
      customerId: customer.id,
      customerName: customer.name,
      customerPhone: customer.phone,
      customerAddress: _addressCtrl.text.trim(),
      deliveryLocation: _manualLocation ?? customer.location,
      orderType: 'delivery',
      paymentMethod: _paymentMethod,
      paymentReference: _referenceCtrl.text.trim(),
      currency: _currency,
      exchangeRate: rate,
      totalUsd: cart.totalPrice,
      totalBs: cart.totalPrice * rate,
      profitUsd: cart.items.fold<double>(0.0, (sum, i) => sum + i.totalProfit),
      items: cart.items.map((c) => OrderItemModel.fromCartItem(c)).toList(),
      status: 'pending',
      createdAt: DateTime.now(),
    );
  }

  // ------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------
  Future<String?> _getValidationError() async {
    // 1. Validaciones locales (Rápidas)
    if (_nameCtrl.text.trim().isEmpty) return 'El nombre es requerido';
    if (_phoneCtrl.text.trim().isEmpty) return 'El teléfono es requerido';

    // 2. Validación de referencia (Vacía)
    final bool needsRef =
        _paymentMethod == 'pago móvil' || _paymentMethod == 'zelle';
    final String refValue = _referenceCtrl.text.trim();

    if (needsRef && refValue.isEmpty) {
      return 'Debe ingresar el número de referencia del pago';
    }

    // 3. Validación de referencia (Unicidad en Base de Datos)
    if (needsRef && refValue.isNotEmpty) {
      final ordersService = context.read<OrdersService>();
      final isUnique = await ordersService.isReferenceUnique(refValue);
      if (!isUnique) {
        return 'Esta referencia ya fue utilizada en otro pedido';
      }
    }

    // 4. Validación de ubicación
    if (_manualLocation == null && _selectedCustomer?.location == null) {
      return 'Es necesario fijar la ubicación (Pegar de WhatsApp)';
    }

    return null; // Todo está correcto
  }

  //1. Helpers de Entrada de Texto
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      enabled: !_isSubmitting,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneCtrl,
      enabled: !_isSubmitting,
      keyboardType: TextInputType.phone,
      onChanged: _onPhoneChanged,
      decoration: const InputDecoration(
        labelText: 'Teléfono',
        prefixIcon: Icon(Icons.phone),
        border: OutlineInputBorder(),
        hintText: 'Ej: 04121234567',
      ),
    );
  }

  //2. Selectores de Pago y Moneda
  Widget _buildPaymentSelectors() {
    final bool needsReference =
        _paymentMethod == 'pago móvil' || _paymentMethod == 'zelle';

    return Column(
      children: [
        const SizedBox(height: 8),
        _buildDropdown(
          label: 'Método de pago',
          value: _paymentMethod,
          items: ['efectivo', 'pago móvil', 'zelle'],
          onChanged: (v) => setState(() => _paymentMethod = v!),
        ),
        if (needsReference) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _referenceCtrl,
            enabled: !_isSubmitting,
            textCapitalization: TextCapitalization.characters,
            // Útil para códigos Zelle
            decoration: InputDecoration(
              labelText: _paymentMethod == 'zelle'
                  ? 'Código de confirmación Zelle'
                  : 'Referencia Pago Móvil',
              prefixIcon: const Icon(Icons.receipt_long),
              border: const OutlineInputBorder(),
              hintText: _paymentMethod == 'zelle'
                  ? 'Ej: ABC123XYZ'
                  : 'Ej: 1234',
            ),
          ),
        ],
        const SizedBox(height: 12),
        _buildDropdown(
          label: 'Moneda de pago',
          value: _currency,
          items: ['USD', 'BS'],
          onChanged: (v) => setState(() => _currency = v!),
        ),
      ],
    );
  }

  //3. Resumen y Tarjeta de Totales
  // Lista de Productos con diseño de "Ticket"
  Widget _buildOrderSummary(CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('PRODUCTOS'),
        const SizedBox(height: 8),
        ...cart.items.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${item.quantity}x",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.product.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  "\$${((item.quantity ?? 0) * (item.product.priceUsd ?? 0)).toStringAsFixed(2)}",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Resumen de Totales
  Widget _buildTotalCard(double usd, double bs, double rate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          _row('Tasa de cambio', 'Bs ${rate.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _row('Total USD', '\$${usd.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _row(
            'Total en Bolívares',
            'Bs ${bs.toStringAsFixed(2)}',
            bold: true,
            color: Colors.green.shade900,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 18 : 14,
            color: bold ? Colors.green : Colors.black,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 18 : 14,
            color: bold ? Colors.green : Colors.black,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  //4. Botón de Acción y Notificaciones
  Widget _buildConfirmButton(CartProvider cart, double rate) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isSubmitting
            ? null
            : () {
                if (_manualLocation == null &&
                    (_selectedCustomer?.location == null)) {
                  _showError(
                    'Debe pegar las coordenadas de WhatsApp antes de confirmar.',
                  );
                  return;
                }
                _confirmOrder(cart, rate);
              },
        child: _isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'PROCESAR ORDEN',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  //OTROS
  Widget _buildLocationSection() {
    // Determinamos qué ubicación mostrar en la tarjeta de estado
    final hasManual = _manualLocation != null;
    final hasCustomerLoc = _selectedCustomer?.location != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('UBICACIÓN DE ENTREGA'),
        const SizedBox(height: 8),

        // Input de dirección con botón de pegado SIEMPRE activo
        TextField(
          controller: _addressCtrl,
          enabled: !_isSubmitting,
          decoration: InputDecoration(
            labelText: 'Punto de referencia / Dirección',
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: IconButton(
              icon: const Icon(Icons.content_paste_go, color: Colors.blue),
              tooltip: 'Pegar coordenadas de WhatsApp',
              onPressed: _isSubmitting ? null : _importCoordinatesFromClipboard,
            ),
            border: const OutlineInputBorder(),
            helperText:
                'Copia la ubicación en WhatsApp y presiona el icono azul',
          ),
        ),

        const SizedBox(height: 12),

        // Tarjeta de estado: Prioriza mostrar la ubicación pegada (Manual)
        if (hasManual || hasCustomerLoc)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasManual ? Colors.green.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasManual ? Colors.green.shade200 : Colors.blue.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasManual ? Icons.gps_fixed : Icons.history,
                  color: hasManual ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasManual
                            ? 'Ubicación Nueva (WhatsApp)'
                            : 'Ubicación Histórica del Cliente',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        hasManual
                            ? '${_manualLocation!.latitude}, ${_manualLocation!.longitude}'
                            : '${_selectedCustomer!.location!.latitude}, ${_selectedCustomer!.location!.longitude}' ??
                                  'Sin dirección técnica',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (hasManual) // Botón para "limpiar" y volver a la del cliente si se desea
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _manualLocation = null),
                  ),
              ],
            ),
          )
        else
          const Text(
            '⚠️ Pendiente: Pegar ubicación para delivery',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: _isSubmitting ? null : onChanged,
      decoration: InputDecoration(
        labelText: label,
        enabled: !_isSubmitting,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item.toUpperCase(), style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.1, // Un poco de espacio entre letras mejora el look
        ),
      ),
    );
  }

  Future<void> _importCoordinatesFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData('text/plain');
    final String text = data?.text?.trim() ?? '';

    if (text.isEmpty) return _showError("El portapapeles está vacío");

    try {
      // Soporta: "10.48, -66.90" o links de Google Maps
      final regExp = RegExp(r'(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)');
      final match = regExp.firstMatch(text);

      if (match != null) {
        final double lat = double.parse(match.group(1)!);
        final double lng = double.parse(match.group(2)!);

        setState(() {
          // 1. Definimos el texto una sola vez
          if (_addressCtrl.text.isEmpty) {
            _addressCtrl.text = "Ubicación vía WhatsApp";
          }

          // 2. Asignamos el modelo usando el valor actual del controlador
          _manualLocation = LocationModel(
            latitude: lat, 
            longitude: lng,
            address: _addressCtrl.text,
          );
        });

        _showSnackBar("📍 Coordenadas capturadas");
      } else {
        _showError("No se encontraron coordenadas válidas");
      }
    } catch (e) {
      _showError("Error al procesar el texto");
    }
  }
}
