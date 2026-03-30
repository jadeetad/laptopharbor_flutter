class Product {
  final int id;
  final String brand;
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final int rating;
  final int reviews;
  final String? badge;
  final String bgColor;
  final String screenColor;
  final String description;
  final Map<String, String> specs;

  const Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.category,
    required this.price,
    this.oldPrice,
    required this.rating,
    required this.reviews,
    this.badge,
    required this.bgColor,
    required this.screenColor,
    required this.description,
    required this.specs,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawSpecs = json['specs'];
    Map<String, String> specs = {};
    if (rawSpecs is Map) {
      specs = Map<String, String>.from(
        rawSpecs.map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    }
    return Product(
      id: json['id'] as int,
      brand: json['brand'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      oldPrice: json['old_price'] != null ? (json['old_price'] as num).toDouble() : null,
      rating: json['rating'] as int,
      reviews: json['reviews'] as int,
      badge: json['badge'] as String?,
      bgColor: json['bg_color'] as String? ?? '#111111',
      screenColor: json['screen_color'] as String? ?? '#1A1AFF',
      description: json['description'] as String? ?? '',
      specs: specs,
    );
  }

  int get discountPercent {
    if (oldPrice == null) return 0;
    return ((1 - price / oldPrice!) * 100).round();
  }
}
