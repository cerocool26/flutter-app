class Product {
  final String id;
  final String name;
  final double price;
  final String? description;
  final int stock;
  final bool isActive;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.stock,
    required this.isActive,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    final double parsedPrice =
        rawPrice is num ? rawPrice.toDouble() : double.tryParse('$rawPrice') ?? 0.0;

    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      price: parsedPrice,
      description: json['description'],
      stock: (json['stock'] is num) ? (json['stock'] as num).toInt() : 0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
