import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';

class SettingsExchangeRateScreen extends StatefulWidget {
  const SettingsExchangeRateScreen({super.key});

  @override
  State<SettingsExchangeRateScreen> createState() => _SettingsExchangeRateScreenState();
}

class _SettingsExchangeRateScreenState extends State<SettingsExchangeRateScreen> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveRate() async {
    final value = double.tryParse(_controller.text);

    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese una tasa válida'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Usamos el servicio desde Provider
      await context.read<SettingsService>().updateExchangeRate(value);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tasa actualizada correctamente'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = context.read<SettingsService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Tasa de Cambio')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<double>(
          // Usamos un Future para cargar el valor inicial una sola vez
          future: settingsService.getExchangeRate().first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Solo asignamos el valor al controlador la primera vez que carga
            if (snapshot.hasData && _controller.text.isEmpty) {
              _controller.text = snapshot.data!.toStringAsFixed(2);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  enabled: !_isSaving,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Tasa USD → BS',
                    prefixIcon: Icon(Icons.currency_exchange),
                    border: OutlineInputBorder(),
                    suffixText: 'Bs',
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveRate,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ACTUALIZAR TASA', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const Spacer(),
                _buildInfoNote(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade800),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Esta tasa se utilizará para calcular los precios en Bolívares en el Punto de Venta.',
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote() {
    return Card(
      color: Colors.amber.shade50,
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'ℹ️ Nota: La tasa se congela al momento de la venta. '
              'Los cambios realizados ahora no afectarán los reportes de ventas pasadas.',
          style: TextStyle(fontSize: 13, color: Colors.orange),
        ),
      ),
    );
  }
}