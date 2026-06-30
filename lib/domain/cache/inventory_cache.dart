import '../../models/inventory_item_model.dart';

class InventoryCache {
  final Map<String, InventoryItemModel> _map = {};

  void update(List<InventoryItemModel> items) {
    for (final item in items) {
      _map[item.id] = item;
    }
  }

  InventoryItemModel? get(String id) => _map[id];

  Map<String, InventoryItemModel> get map => _map;
}
