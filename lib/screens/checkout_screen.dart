import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _addressCtrl    = TextEditingController();
  final _cityCtrl       = TextEditingController();
  final _stateCtrl      = TextEditingController();
  final _zipCtrl        = TextEditingController();
  final _cardCtrl       = TextEditingController();
  final _expiryCtrl     = TextEditingController();
  final _cvvCtrl        = TextEditingController();

  bool _placing = false;
  int _step = 0; // 0 = shipping, 1 = payment, 2 = review

  @override
  void dispose() {
    for (final c in [_firstNameCtrl, _lastNameCtrl, _emailCtrl, _addressCtrl,
      _cityCtrl, _stateCtrl, _zipCtrl, _cardCtrl, _expiryCtrl, _cvvCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    if (auth.user == null) return;

    setState(() => _placing = true);
    final subtotal = cart.subtotal;
    final shipping = cart.shipping(subtotal);
    final total = subtotal + shipping;

    final orderId = await OrderService.placeOrder(
      userId: auth.user!.id,
      items: cart.items.toList(),
      total: total,
    );

    if (!mounted) return;
    setState(() => _placing = false);

    if (orderId != null) {
      await cart.clearCart(userId: auth.user!.id);
      context.go('/order-confirmation?id=$orderId');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order failed. Please try again.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final subtotal = cart.subtotal;
    final shipping = cart.shipping(subtotal);
    final total = subtotal + shipping;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/cart')),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Step indicator
            Row(children: [
              _StepDot(0, 'Shipping', _step),
              _StepLine(_step >= 1),
              _StepDot(1, 'Payment', _step),
              _StepLine(_step >= 2),
              _StepDot(2, 'Review', _step),
            ]),
            const SizedBox(height: 28),

            if (_step == 0) ...[
              _SectionTitle('Shipping information'),
              Row(children: [
                Expanded(child: _Field('First name', _firstNameCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _Field('Last name', _lastNameCtrl)),
              ]),
              const SizedBox(height: 12),
              _Field('Email', _emailCtrl, type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _Field('Street address', _addressCtrl),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _Field('City', _cityCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _Field('State', _stateCtrl)),
              ]),
              const SizedBox(height: 12),
              _Field('ZIP / Postal code', _zipCtrl, type: TextInputType.number),
              const SizedBox(height: 28),
              SizedBox(width: double.infinity,
                child: ElevatedButton(
                  onPressed: () { if (_formKey.currentState!.validate()) setState(() => _step = 1); },
                  child: const Text('Continue to Payment →'),
                )),
            ],

            if (_step == 1) ...[
              _SectionTitle('Payment details'),
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Row(children: [
                  Icon(Icons.lock_outline, size: 14, color: AppColors.textMuted),
                  SizedBox(width: 4),
                  Text('Your payment info is encrypted and secure.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ]),
              ),
              _Field('Card number', _cardCtrl, type: TextInputType.number),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _Field('Expiry (MM/YY)', _expiryCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _Field('CVV', _cvvCtrl, type: TextInputType.number)),
              ]),
              const SizedBox(height: 28),
              Row(children: [
                OutlinedButton(onPressed: () => setState(() => _step = 0), child: const Text('← Back')),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: () { if (_formKey.currentState!.validate()) setState(() => _step = 2); },
                  child: const Text('Review Order →'),
                )),
              ]),
            ],

            if (_step == 2) ...[
              _SectionTitle('Order review'),
              ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Expanded(child: Text('${item.product.brand} ${item.product.name}',
                      style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text('x${item.qty}', style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(width: 12),
                  Text('\$${item.total.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ]),
              )),
              const Divider(height: 24),
              _ReviewRow('Subtotal', '\$${subtotal.toStringAsFixed(0)}'),
              _ReviewRow('Shipping', shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(0)}'),
              const Divider(height: 16),
              _ReviewRow('Total', '\$${total.toStringAsFixed(0)}', bold: true),
              const SizedBox(height: 28),
              Row(children: [
                OutlinedButton(onPressed: () => setState(() => _step = 1), child: const Text('← Back')),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _placing ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.badgeSale,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _placing
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Place Order ✓'),
                  ),
                ),
              ]),
            ],
          ]),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
  );
}

class _Field extends StatelessWidget {
  final String hint;
  final TextEditingController ctrl;
  final TextInputType? type;
  const _Field(this.hint, this.ctrl, {this.type});

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    keyboardType: type,
    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    decoration: InputDecoration(hintText: hint),
  );
}

class _ReviewRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _ReviewRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          fontSize: bold ? 16 : 14)),
      Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          fontSize: bold ? 20 : 14)),
    ]),
  );
}

class _StepDot extends StatelessWidget {
  final int index, current;
  final String label;
  const _StepDot(this.index, this.label, this.current);

  @override
  Widget build(BuildContext context) {
    final done = current > index;
    final active = current == index;
    return Column(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: done || active ? AppColors.accent : AppColors.border,
          shape: BoxShape.circle,
        ),
        child: Center(child: done
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : Text('${index + 1}', style: TextStyle(color: active ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w600, fontSize: 12))),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: active ? AppColors.accent : AppColors.textMuted)),
    ]);
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine(this.active);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 2, margin: const EdgeInsets.only(bottom: 18),
      color: active ? AppColors.accent : AppColors.border,
    ),
  );
}
