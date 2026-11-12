import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../../domain/entities/financial_account_entity.dart';

class FinanceDashboardScreen extends StatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Cargamos las cuentas financieras al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas & Caja - Maru Food'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: financeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : financeProvider.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: ${financeProvider.errorMessage}',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => financeProvider.loadAccounts(),
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      const Text(
                        'Reflejo Contable de Cuentas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Control estricto para separar capital de trabajo y ganancias.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      // Tarjetas de Cuentas (Reposición vs Sueldos)
                      ...financeProvider.accounts.map((account) {
                        return _buildAccountCard(context, account);
                      }),

                      if (financeProvider.accounts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'No hay cuentas contables registradas en el sistema.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  /// Widget para renderizar cada tarjeta de cuenta con diseño diferenciado
  Widget _buildAccountCard(BuildContext context, FinancialAccountEntity account) {
    final isRestocking = account.type == 'restocking';
    final cardColor = isRestocking ? Colors.blue[50] : Colors.green[50];
    final borderColor = isRestocking ? Colors.blue : Colors.green;
    final iconColor = isRestocking ? Colors.blue[800] : Colors.green[800];
    final icon = isRestocking ? Icons.inventory_2_rounded : Icons.payments_rounded;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      account.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isRestocking ? 'Capital de Trabajo' : 'Sueldos / Utilidad',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              account.description,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saldo Actual:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  '\$${account.balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}