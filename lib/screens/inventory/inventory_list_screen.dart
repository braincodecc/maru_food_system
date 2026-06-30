import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/inventory_service.dart';
import '../../models/inventory_item_model.dart';

class InventoryListScreen extends StatelessWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryService = context.read<InventoryService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/inventory-form');
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<InventoryItemModel>>(
        stream: inventoryService.getItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al cargar inventario'),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No hay insumos registrados',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Mismo margen que productos
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => Navigator.pushNamed(context, '/inventory-form', arguments: item),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icono visual de insumo/materia prima
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50, // Color diferente para distinguir de productos
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.inventory_2_outlined, color: Colors.orange.shade400),
                            ),
                            const SizedBox(width: 12),

                            // Información de Identidad del Insumo
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  // Badge de estado (Activo/Inactivo) para consistencia visual
                                  _buildActiveBadge(item.active),
                                ],
                              ),
                            ),

                            // Datos de Stock Destacados
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.stock.toStringAsFixed(1)} ${item.unit}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: item.stock <= 0 ? Colors.red : Colors.blueGrey.shade800,
                                  ),
                                ),
                                Text(
                                  'Costo: \$${item.costPerUnit.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const Divider(height: 24),

                        // Acciones de Gestión
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Información de "Inversión" en stock
                            Text(
                              'Valor: \$${(item.stock * item.costPerUnit).toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w500),
                            ),

                            // Botón de acción rápida: Editar/Ajustar
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/inventory-form', arguments: item),
                              icon: const Icon(Icons.edit_note, size: 18),
                              label: const Text('AJUSTAR'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActiveBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        active ? "ACTIVO" : "INACTIVO",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: active ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }
}
