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
      id: json['id'].toString(),
      productCode: json['productCode'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String username;
  final List<OrderLineItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.username,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      orderNumber: json['orderNumber'],
      username: json['username'],
      items: (json['orderLineItemsList'] as List)
          .map((item) => OrderLineItem.fromJson(item))
          .toList(),
    );
  }

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}
