import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class WishlistProvider extends ChangeNotifier {
  final Set<int> _productIds = {};
  final _supabase = Supabase.instance.client;

  bool isWishlisted(int productId) => _productIds.contains(productId);
  int get count => _productIds.length;

  Future<void> load(String userId) async {
    try {
      final response = await _supabase
          .from('wishlist')
          .select('product_id')
          .eq('user_id', userId);
      _productIds.clear();
      for (final row in response as List) {
        _productIds.add(row['product_id'] as int);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Wishlist load error: $e');
    }
  }

  Future<void> toggle(Product product, String userId) async {
    if (_productIds.contains(product.id)) {
      _productIds.remove(product.id);
      await _supabase
          .from('wishlist')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', product.id);
    } else {
      _productIds.add(product.id);
      await _supabase.from('wishlist').upsert({
        'user_id': userId,
        'product_id': product.id,
      });
    }
    notifyListeners();
  }
}
