class CartItem {
  final String id;
  final String productId;
  final String productCode; // SKU
  final String title;
  final int quantity;
  final double price;
  final String? imageUrl;

  CartItem({
    required this.id,
    required this.productId,
    required this.productCode,
    required this.title,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  CartItem copyWith({
    String? id,
    String? productId,
    String? productCode,
    String? title,
    int? quantity,
    double? price,
    String? imageUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productCode: productCode ?? this.productCode,
      title: title ?? this.title,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
