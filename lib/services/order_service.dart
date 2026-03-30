import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/cart_item.dart' show Order;

class OrderService {
  static final _supabase = Supabase.instance.client;

  static Future<String?> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double total,
    String? promoCode,
    double discount = 0,
  }) async {
    try {
      // Create order
      final order = await _supabase.from('orders').insert({
        'user_id': userId,
        'total': total,
        'status': 'pending',
        'promo_code': promoCode,
        'discount': discount,
      }).select().single();

      final orderId = order['id'] as String;

      // Create order items
      await _supabase.from('order_items').insert(
        items.map((item) => {
          'order_id': orderId,
          'product_id': item.product.id,
          'qty': item.qty,
          'price': item.product.price,
        }).toList(),
      );

      return orderId;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Order>> getOrderHistory(String userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*, products(name, brand))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (response as List)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
