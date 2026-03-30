import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  static final _supabase = Supabase.instance.client;

  // Fetch all products with optional filters
  static Future<List<Product>> getProducts({
    String? category,
    String? brand,
    String? ram,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
    String sortBy = 'featured',
  }) async {
    var query = _supabase.from('products').select();

    if (category != null && category != 'All') {
      query = query.eq('category', category) as dynamic;
    }
    if (brand != null && brand != 'All') {
      query = query.eq('brand', brand) as dynamic;
    }
    if (minPrice != null) {
      query = query.gte('price', minPrice) as dynamic;
    }
    if (maxPrice != null) {
      query = query.lte('price', maxPrice) as dynamic;
    }

    List<dynamic> response;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      response = await _supabase
          .from('products')
          .select()
          .or('name.ilike.%$searchQuery%,brand.ilike.%$searchQuery%');
    } else {
      response = await query;
    }

    List<Product> products = (response as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();

    // Client-side sort
    switch (sortBy) {
      case 'price-asc':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price-desc':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return products;
  }

  static Future<Product?> getProductById(int id) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', id)
          .single();
      return Product.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Product>> getRelated(int productId, String category) async {
    final response = await _supabase
        .from('products')
        .select()
        .eq('category', category)
        .neq('id', productId)
        .limit(4);
    return (response as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Product>> getDeals() async {
    final response = await _supabase
        .from('products')
        .select()
        .not('old_price', 'is', null);
    return (response as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Product>> getFeatured() async {
    final response = await _supabase
        .from('products')
        .select()
        .order('reviews', ascending: false)
        .limit(4);
    return (response as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
