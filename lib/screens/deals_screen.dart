import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});
  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  List<Product> _deals = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final deals = await ProductService.getDeals();
    if (mounted) setState(() { _deals = deals; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavBar(currentRoute: '/deals'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: AppColors.ink,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.badgeSale.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('LIMITED TIME OFFERS',
                            style: TextStyle(color: AppColors.badgeSale, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      ),
                      const SizedBox(height: 12),
                      const Text('Today\'s Deals', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('${_deals.length} laptops on sale — prices updated daily.',
                          style: const TextStyle(color: Colors.white54, fontSize: 14)),
                    ]),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: _deals.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(child: Padding(
                            padding: EdgeInsets.all(48),
                            child: Text('No deals right now. Check back soon!',
                                style: TextStyle(color: AppColors.textMuted)),
                          )),
                        )
                      : SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => ProductCard(product: _deals[i]),
                            childCount: _deals.length,
                          ),
                        ),
                ),
                const SliverToBoxAdapter(child: AppFooter()),
              ],
            ),
    );
  }
}
