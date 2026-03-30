import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/product_service.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Product> _products = [];
  bool _loading = true;
  final _supabase = Supabase.instance.client;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    try {
      final response = await _supabase
          .from('wishlist')
          .select('product_id, products(*)')
          .eq('user_id', auth.user!.id);
      final products = (response as List)
          .map((r) => Product.fromJson(r['products'] as Map<String, dynamic>))
          .toList();
      if (mounted) setState(() { _products = products; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wishlist = context.watch<WishlistProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist (${_products.length})'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/profile')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_border, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Text('Your wishlist is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('Save laptops you love here.', style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: () => context.go('/products'), child: const Text('Browse Products')),
                  ],
                ))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.68,
                    crossAxisSpacing: 12, mainAxisSpacing: 12,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (_, i) => ProductCard(
                    product: _products[i],
                    onTap: () => context.go('/products/${_products[i].id}'),
                  ),
                ),
    );
  }
}
