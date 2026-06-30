import '../models/order_status.dart';

const Map<OrderStatus, List<OrderStatus>> orderFlow = {
  OrderStatus.pending: [
    OrderStatus.paid,
    OrderStatus.cancelled,
  ],
  OrderStatus.paid: [
    OrderStatus.completed,
  ],
  OrderStatus.completed: [
    OrderStatus.delivered,
  ],
};
