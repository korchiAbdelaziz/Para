class OrderLineItem {
  final String id;
  final String productCode;
  final double price;
  final int quantity;

  OrderLineItem({
    required this.id,
    required this.productCode,
    required this.price,
    required this.quantity,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      id: (json['id'] ?? '').toString(),
      productCode: json['productCode'] ?? 'Unknown',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String username;
  final String status;
  final List<OrderLineItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.username,
    required this.status,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: (json['id'] ?? '').toString(),
      orderNumber: json['orderNumber'] ?? 'N/A',
      username: json['username'] ?? 'Anonymous',
      status: json['status'] ?? 'PENDING_VALIDATION',
      items: (json['orderLineItemsList'] as List?)
              ?.map((item) => OrderLineItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}
