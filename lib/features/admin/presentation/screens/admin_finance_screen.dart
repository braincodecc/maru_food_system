import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maru_food_system/app/routes/app_routes.dart';
import 'package:maru_food_system/features/finance/domain/entities/financial_account_entity.dart';
import '../../../identity/identity.dart';
import '../providers/admin_finance_provider.dart';

class AdminFinanceScreen extends StatelessWidget {
  const AdminFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final identityProvider = context.watch<IdentityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas & Caja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await identityProvider.logout();
              // AuthWrapper redirigirá automáticamente al Login
              // Limpiamos todo el historial de navegación y regresamos al AuthWrapper raíz ('/')
              Navigator.pushNamedAndRemoveUntil(
                // Elimina todas las pantallas superiores de la pila
                context,
                AppRoutes.initial,
                (route) =>
                    false, // Elimina todas las pantallas anteriores de la pila
              );
            },
          ),
        ],
      ),
      body: AdminFinanceBody(),
    );
  }
}

class AdminFinanceBody extends StatefulWidget {
  const AdminFinanceBody({super.key});

  @override
  State<AdminFinanceBody> createState() => _AdminFinanceBodyState();
}

class _AdminFinanceBodyState extends State<AdminFinanceBody> {
  @override
  void initState() {
    super.initState();
    // Cargamos las cuentas financieras al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminFinanceProvider>().loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = context.watch<AdminFinanceProvider>();
    Widget content;

    financeProvider.isLoading
        ? content = const Center(child: CircularProgressIndicator())
        : financeProvider.errorMessage != null
        ? content = Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${financeProvider.errorMessage}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          )
        : content = RefreshIndicator(
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
          );
    return content;
  }

  /// Widget para renderizar cada tarjeta de cuenta con diseño diferenciado
  Widget _buildAccountCard(
    BuildContext context,
    FinancialAccountEntity account,
  ) {
    final isRestocking = account.type == 'restocking';
    final cardColor = isRestocking ? Colors.blue[50] : Colors.green[50];
    final borderColor = isRestocking ? Colors.blue : Colors.green;
    final iconColor = isRestocking ? Colors.blue[800] : Colors.green[800];
    final icon = isRestocking
        ? Icons.inventory_2_rounded
        : Icons.payments_rounded;

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: account.balance > 0
                    ? () => _showTransferToBankDialog(context, account)
                    : null,
                icon: const Icon(Icons.account_balance_rounded, size: 18),
                label: Text(
                  isRestocking
                      ? 'Transferir para Reposición'
                      : 'Transferir Sueldos / Utilidad',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: borderColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransferToBankDialog(
    BuildContext context,
    FinancialAccountEntity account,
  ) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(
      // Prellenado con el total disponible
      text: account.balance.toStringAsFixed(2),
    );
    final referenceController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Transferir - ${account.name}'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disponible en caja: \$${account.balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Monto a transferir (\$)',
                      border: const OutlineInputBorder(),
                      suffixIcon: TextButton(
                        onPressed: () {
                          amountController.text = account.balance
                              .toStringAsFixed(2);
                        },
                        child: const Text('Todo'),
                      ),
                    ),
                    validator: (val) {
                      final amount = double.tryParse(val ?? '');
                      if (amount == null || amount <= 0) {
                        return 'Ingresa un monto válido';
                      }
                      if (amount > account.balance) {
                        return 'Supera el saldo disponible';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Referencia Bancaria',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Ingresa la referencia del movimiento'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: account.type == 'restocking'
                          ? 'Detalle (Ej: Compra pan y carne)'
                          : 'Detalle (Ej: Pago quincena)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final amount = double.parse(amountController.text.trim());
                final reference = referenceController.text.trim();
                final notes = notesController.text.trim();

                Navigator.of(dialogContext).pop();

                final success = await context
                    .read<AdminFinanceProvider>()
                    .registerBankTransfer(
                      accountId: account.id,
                      currentBalance: account.balance,
                      amountToTransfer: amount,
                      bankReference: reference,
                      notes: notes,
                    );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Transferencia registrada. Saldo disponible actualizado.'
                          : context.read<AdminFinanceProvider>().errorMessage ??
                                'Error al registrar la transferencia',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar Transferencia'),
            ),
          ],
        );
      },
    );
  }
}
