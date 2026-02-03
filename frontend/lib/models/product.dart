class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String sku;
  final String? category;
  final String? imageUrl;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.sku,
    this.category,
    this.imageUrl,
    this.stock = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      sku: json['productCode'] ?? json['sku'] ?? json['code'] ?? '',
      category: json['category'],
      imageUrl: json['imageUrl'],
      stock: json['quantity'] ?? 0,
    );
  }
}
