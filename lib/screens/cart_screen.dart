import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/laptop_svg_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promoCtrl = TextEditingController();
  bool _promoApplied = false;
  bool _promoLoading = false;
  static const _promoCode = 'HARBOR10';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn) context.read<CartProvider>().loadCart(auth.user!.id);
    });
  }

  @override
  void dispose() { _promoCtrl.dispose(); super.dispose(); }

  void _applyPromo() {
    if (_promoCtrl.text.trim().toUpperCase() == _promoCode) {
      setState(() => _promoApplied = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid promo code'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final items = cart.items;
    final subtotal = cart.subtotal;
    final discount = cart.discount(subtotal, _promoApplied);
    final shipping = cart.shipping(subtotal);
    final total = subtotal - discount + shipping;

    return Scaffold(
      appBar: const AppNavBar(currentRoute: '/cart'),
      body: cart.loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? _EmptyCart()
              : Column(children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Your Cart', style: Theme.of(context).textTheme.headlineMedium),
                          Text('${cart.itemCount} item${cart.itemCount != 1 ? 's' : ''} in your cart',
                              style: const TextStyle(color: AppColors.textMuted)),
                        ]),
                        TextButton(
                          onPressed: () => context.go('/products'),
                          child: const Text('← Continue shopping'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        // Cart items
                        ...items.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(children: [
                            Container(
                              width: 80, height: 60,
                              decoration: BoxDecoration(
                                color: Color(int.parse(item.product.bgColor.replaceFirst('#', '0xFF'))),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(child: LaptopSvgWidget(
                                bgColor: item.product.bgColor,
                                screenColor: item.product.screenColor,
                                width: 70,
                              )),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(item.product.brand, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Row(children: [
                                  // Qty controls
                                  Container(
                                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(6)),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      SizedBox(width: 28, height: 28, child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 14,
                                        icon: const Icon(Icons.remove),
                                        onPressed: () => cart.updateQty(item, item.qty - 1, userId: auth.user?.id),
                                      )),
                                      Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      SizedBox(width: 28, height: 28, child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 14,
                                        icon: const Icon(Icons.add),
                                        onPressed: () => cart.updateQty(item, item.qty + 1, userId: auth.user?.id),
                                      )),
                                    ]),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => cart.removeItem(item, userId: auth.user?.id),
                                    child: const Row(children: [
                                      Icon(Icons.delete_outline, size: 14, color: AppColors.textMuted),
                                      SizedBox(width: 4),
                                      Text('Remove', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    ]),
                                  ),
                                ]),
                              ]),
                            ),
                            const SizedBox(width: 8),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text('\$${item.total.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              if (item.qty > 1)
                                Text('\$${item.product.price.toStringAsFixed(0)} each',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ]),
                          ]),
                        )),

                        // Order summary
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Order Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            ),
                            const SizedBox(height: 16),
                            _SummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(0)}'),
                            if (_promoApplied) _SummaryRow('Discount (HARBOR10)', '-\$${discount.toStringAsFixed(0)}', isDiscount: true),
                            _SummaryRow('Shipping', shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(0)}'),
                            if (subtotal <= 2000 && subtotal > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text('Add \$${(2000 - subtotal).toStringAsFixed(0)} more for free shipping',
                                    style: const TextStyle(fontSize: 12, color: AppColors.accent)),
                              ),
                            const Divider(height: 24),
                            // Promo code
                            if (!_promoApplied) Row(children: [
                              Expanded(child: TextField(
                                controller: _promoCtrl,
                                decoration: const InputDecoration(hintText: 'Promo code', isDense: true),
                              )),
                              const SizedBox(width: 10),
                              ElevatedButton(onPressed: _applyPromo, child: const Text('Apply')),
                            ])
                            else
                              const Text('✓ Promo code applied — 10% off!',
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                                Text('\$${total.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.ink)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => context.go('/checkout'),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Proceed to Checkout'),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 16),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Trust row
                            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
                              _TrustItem(Icons.lock_outline, 'Secure checkout'),
                              _TrustItem(Icons.verified_outlined, '2-year warranty'),
                              _TrustItem(Icons.replay_outlined, '30-day returns'),
                            ]),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                ]),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool isDiscount;
  const _SummaryRow(this.label, this.value, {this.isDiscount = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted)),
        Text(value, style: TextStyle(
            color: isDiscount ? Colors.green : AppColors.ink,
            fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14, color: AppColors.textMuted),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
  ]);
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.textMuted),
      const SizedBox(height: 16),
      const Text('Nothing here yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      const Text('Browse our laptops and add something you love', style: TextStyle(color: AppColors.textMuted)),
      const SizedBox(height: 24),
      ElevatedButton(onPressed: () => context.go('/products'), child: const Text('Browse Laptops')),
    ]),
  );
}
