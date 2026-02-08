class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String? description;
  final double? discount;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description,
    this.discount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: _parseDouble(json['price']),
      imageUrl: json['image_url']?.toString() ?? '',
      description: json['description']?.toString(),
      discount: _parseDouble(json['discount']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}