import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _loading = false;
  final _supabase = Supabase.instance.client;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.qty);

  double get subtotal => _items.fold(0, (sum, i) => sum + i.total);

  double shipping(double subtotal) => subtotal > 2000 ? 0 : 29;

  double discount(double subtotal, bool promoApplied) =>
      promoApplied ? (subtotal * 0.1).roundToDouble() : 0;

  // Load cart from Supabase for logged-in user
  Future<void> loadCart(String userId) async {
    _loading = true;
    notifyListeners();
    try {
      final response = await _supabase
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', userId);
      _items.clear();
      for (final row in response as List) {
        final product = Product.fromJson(row['products'] as Map<String, dynamic>);
        _items.add(CartItem(
          id: row['id'] as String,
          product: product,
          qty: row['qty'] as int,
        ));
      }
    } catch (e) {
      debugPrint('Cart load error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(Product product, {String? userId}) async {
    final existing = _items.where((i) => i.product.id == product.id);
    if (existing.isNotEmpty) {
      await updateQty(existing.first, existing.first.qty + 1, userId: userId);
      return;
    }
    if (userId != null) {
      try {
        final response = await _supabase.from('cart_items').upsert({
          'user_id': userId,
          'product_id': product.id,
          'qty': 1,
        }).select().single();
        _items.add(CartItem(id: response['id'] as String, product: product, qty: 1));
      } catch (e) {
        debugPrint('Add to cart error: $e');
      }
    } else {
      // Guest: local only
      _items.add(CartItem(id: 'local_${product.id}', product: product, qty: 1));
    }
    notifyListeners();
  }

  Future<void> updateQty(CartItem item, int newQty, {String? userId}) async {
    if (newQty < 1) { await removeItem(item, userId: userId); return; }
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx == -1) return;
    _items[idx].qty = newQty;
    if (userId != null && !item.id.startsWith('local_')) {
      await _supabase.from('cart_items').update({'qty': newQty}).eq('id', item.id);
    }
    notifyListeners();
  }

  Future<void> removeItem(CartItem item, {String? userId}) async {
    _items.removeWhere((i) => i.id == item.id);
    if (userId != null && !item.id.startsWith('local_')) {
      await _supabase.from('cart_items').delete().eq('id', item.id);
    }
    notifyListeners();
  }

  Future<void> clearCart({String? userId}) async {
    _items.clear();
    if (userId != null) {
      await _supabase.from('cart_items').delete().eq('user_id', userId);
    }
    notifyListeners();
  }
}
