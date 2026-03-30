import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  int qty;

  CartItem({
    required this.id,
    required this.product,
    required this.qty,
  });

  double get total => product.price * qty;

  factory CartItem.fromJson(Map<String, dynamic> json, Product product) {
    return CartItem(
      id: json['id'] as String,
      product: product,
      qty: json['qty'] as int,
    );
  }
}

class Order {
  final String id;
  final double total;
  final String status;
  final String? promoCode;
  final double discount;
  final DateTime createdAt;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.total,
    required this.status,
    this.promoCode,
    required this.discount,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      promoCode: json['promo_code'] as String?,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: (json['order_items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class OrderItem {
  final String id;
  final int productId;
  final int qty;
  final double price;
  final String? productName;
  final String? productBrand;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.qty,
    required this.price,
    this.productName,
    this.productBrand,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['products'] as Map<String, dynamic>?;
    return OrderItem(
      id: json['id'] as String,
      productId: json['product_id'] as int,
      qty: json['qty'] as int,
      price: (json['price'] as num).toDouble(),
      productName: product?['name'] as String?,
      productBrand: product?['brand'] as String?,
    );
  }
}
