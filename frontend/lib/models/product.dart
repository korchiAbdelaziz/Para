class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String sku;
  final String? category;
  final String? imageUrl;
  final List<String> imageUrls;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.sku,
    this.category,
    this.imageUrl,
    this.imageUrls = const [],
    this.stock = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var images = (json['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    return Product(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null ? (json['discountPrice'] as num).toDouble() : null,
      sku: json['productCode'] ?? json['sku'] ?? json['code'] ?? '',
      category: json['category'],
      imageUrl: images.isNotEmpty ? images.first : json['imageUrl'],
      imageUrls: images,
      stock: json['quantity'] ?? 0,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? sku,
    String? category,
    String? imageUrl,
    List<String>? imageUrls,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      stock: stock ?? this.stock,
    );
  }
}
