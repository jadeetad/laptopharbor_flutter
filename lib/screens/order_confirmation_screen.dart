// ─── ORDER CONFIRMATION ───────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  const OrderConfirmationScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F9EE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 44),
              ),
              const SizedBox(height: 24),
              const Text('Order Confirmed!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 10),
              const Text('Thank you for your purchase. Your laptop is on its way.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.6)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Order ID: ', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  Text(orderId.length > 12 ? '${orderId.substring(0, 12)}...' : orderId,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ink)),
                ]),
              ),
              const SizedBox(height: 36),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => context.go('/orders'),
                  child: const Text('View Orders'),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Continue Shopping'),
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
