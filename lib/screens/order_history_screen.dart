import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart' show Order;
import '../providers/auth_provider.dart';
import '../services/order_service.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    final orders = await OrderService.getOrderHistory(auth.user!.id);
    if (mounted) setState(() { _orders = orders; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/profile')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Text('No orders yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('Your order history will appear here.', style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: () => context.go('/products'), child: const Text('Shop Now')),
                  ],
                ))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _OrderCard(_orders[i]),
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard(this.order);

  Color get _statusColor {
    switch (order.status) {
      case 'delivered': return Colors.green;
      case 'shipped': return AppColors.accent;
      case 'processing': return Colors.orange;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Order #${order.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(order.status[0].toUpperCase() + order.status.substring(1),
              style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ]),
      const SizedBox(height: 8),
      Text(
        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      const Divider(height: 16),
      ...order.items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Expanded(child: Text(
            '${item.productBrand ?? ''} ${item.productName ?? 'Product'}',
            style: const TextStyle(fontSize: 13),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          )),
          Text('x${item.qty}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(width: 8),
          Text('\$${item.price.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      )),
      const Divider(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
        Text('\$${order.total.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
      ]),
    ]),
  );
}
