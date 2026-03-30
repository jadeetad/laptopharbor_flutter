import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/product_service.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/laptop_svg_widget.dart';
import '../widgets/auth_bottom_sheet.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  List<Product> _related = [];
  bool _loading = true;
  int _qty = 1;
  int _activeTab = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final product = await ProductService.getProductById(widget.productId);
    if (product != null) {
      final related = await ProductService.getRelated(product.id, product.category);
      if (mounted) setState(() { _product = product; _related = related; _loading = false; });
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();

    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_product == null) return Scaffold(
      appBar: AppBar(),
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Product not found'),
          ElevatedButton(onPressed: () => context.go('/products'), child: const Text('Back to products')),
        ],
      )),
    );

    final p = _product!;

    return Scaffold(
      appBar: const AppNavBar(),
      body: SingleChildScrollView(
        child: Column(children: [
          // Breadcrumb
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              GestureDetector(onTap: () => context.go('/'), child: const Text('Home', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
              const Text(' › ', style: TextStyle(color: AppColors.textMuted)),
              GestureDetector(onTap: () => context.go('/products'), child: const Text('Products', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
              const Text(' › ', style: TextStyle(color: AppColors.textMuted)),
              Text(p.category, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const Text(' › ', style: TextStyle(color: AppColors.textMuted)),
              Flexible(child: Text(p.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Color(int.parse(p.bgColor.replaceFirst('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(children: [
                    Center(child: LaptopSvgWidget(bgColor: p.bgColor, screenColor: p.screenColor, width: 220)),
                    if (p.badge != null)
                      Positioned(top: 12, left: 12, child: _BadgePill(p.badge!)),
                  ]),
                ),
                const SizedBox(height: 20),
                // Brand
                Text(p.brand, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(p.name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Row(children: [
                  StarRating(count: p.rating, reviews: p.reviews, size: 16),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('● In Stock', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ]),
                const SizedBox(height: 14),
                // Price
                Row(children: [
                  if (p.oldPrice != null) ...[
                    Text('\$${p.oldPrice!.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, color: AppColors.textMuted, decoration: TextDecoration.lineThrough)),
                    const SizedBox(width: 8),
                  ],
                  Text('\$${p.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  if (p.oldPrice != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.badgeSale.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                      child: Text('${p.discountPercent}% off', style: const TextStyle(color: AppColors.badgeSale, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ]),
                const SizedBox(height: 16),
                // Key specs
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: p.specs.entries.take(4).map((e) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.key, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(e.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 20),
                // Quantity
                Row(children: [
                  const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () { if (_qty > 1) setState(() => _qty--); }),
                      Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => setState(() => _qty++)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 16),
                // CTAs
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!auth.isLoggedIn) { showAuthBottomSheet(context); return; }
                        for (int i = 0; i < _qty; i++) cart.addItem(p, userId: auth.user!.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added to cart'), backgroundColor: AppColors.accent, duration: const Duration(seconds: 2)),
                        );
                      },
                      icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                      label: const Text('Add to Cart'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        wishlist.isWishlisted(p.id) ? Icons.favorite : Icons.favorite_border,
                        color: wishlist.isWishlisted(p.id) ? Colors.red : AppColors.ink,
                      ),
                      onPressed: () {
                        if (!auth.isLoggedIn) { showAuthBottomSheet(context); return; }
                        wishlist.toggle(p, auth.user!.id);
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                // Trust badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _TrustBadge(Icons.verified_outlined, '2-Year Warranty'),
                    _TrustBadge(Icons.local_shipping_outlined, 'Free Delivery'),
                    _TrustBadge(Icons.replay_outlined, '30-Day Returns'),
                  ],
                ),
                const SizedBox(height: 24),
                // Tabs
                Row(children: [
                  _Tab('Description', 0 == _activeTab, () => setState(() => _activeTab = 0)),
                  _Tab('Specifications', 1 == _activeTab, () => setState(() => _activeTab = 1)),
                  _Tab('Reviews', 2 == _activeTab, () => setState(() => _activeTab = 2)),
                ]),
                const SizedBox(height: 16),
                if (_activeTab == 0) Text(p.description, style: const TextStyle(fontSize: 15, height: 1.7, color: AppColors.ink)),
                if (_activeTab == 1) Column(
                  children: p.specs.entries.map((e) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: Row(children: [
                      Expanded(flex: 2, child: Text(e.key[0].toUpperCase() + e.key.substring(1), style: const TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(flex: 3, child: Text(e.value, style: const TextStyle(color: AppColors.textMuted))),
                    ]),
                  )).toList(),
                ),
                if (_activeTab == 2) Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(children: [
                      StarRating(count: p.rating, reviews: p.reviews, size: 20),
                      const SizedBox(height: 8),
                      const Text('Reviews coming soon', style: TextStyle(color: AppColors.textMuted)),
                    ]),
                  ),
                ),
                // Related
                if (_related.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text('More in ${p.category}', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _related.length,
                      itemBuilder: (_, i) => SizedBox(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ProductCard(product: _related[i]),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const AppFooter(),
        ]),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: active ? AppColors.accent : Colors.transparent, width: 2)),
      ),
      child: Text(label, style: TextStyle(
        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        color: active ? AppColors.accent : AppColors.textMuted,
      )),
    ),
  );
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, size: 22, color: AppColors.accent),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
  ]);
}

class _BadgePill extends StatelessWidget {
  final String label;
  const _BadgePill(this.label);

  Color get _color {
    switch (label.toUpperCase()) {
      case 'HOT': return AppColors.badgeHot;
      case 'NEW': return AppColors.badgeNew;
      case 'SALE': return AppColors.badgeSale;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
  );
}
