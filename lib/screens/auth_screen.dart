import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../widgets/laptop_svg_widget.dart';

class AuthScreen extends StatefulWidget {
  final String? redirectTo;
  const AuthScreen({super.key, this.redirectTo});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignIn = true;
  bool _loading = false;
  bool _showPassword = false;

  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose(); _passwordCtrl.dispose();
    _firstNameCtrl.dispose(); _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    String? error;

    if (_isSignIn) {
      error = await auth.signIn(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
    } else {
      error = await auth.signUp(
        email: _emailCtrl.text.trim(), password: _passwordCtrl.text,
        firstName: _firstNameCtrl.text.trim(), lastName: _lastNameCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      context.go(widget.redirectTo ?? '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                padding: EdgeInsets.zero,
                onPressed: () => context.go('/'),
              ),
              const SizedBox(height: 16),
              // Logo
              Row(children: [
                const LogoWidget(size: 32),
                const SizedBox(width: 8),
                const Text('LaptopHarbor',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 32),
              Text(
                _isSignIn ? 'Welcome back.' : 'Create your account.',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _isSignIn
                    ? 'Sign in to access your cart, wishlist and orders.'
                    : 'Join thousands of satisfied customers.',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 36),

              Form(
                key: _formKey,
                child: Column(children: [
                  if (!_isSignIn) ...[
                    Row(children: [
                      Expanded(child: TextFormField(
                        controller: _firstNameCtrl,
                        validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                        decoration: const InputDecoration(hintText: 'First name'),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(
                        controller: _lastNameCtrl,
                        validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                        decoration: const InputDecoration(hintText: 'Last name'),
                      )),
                    ]),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                    decoration: const InputDecoration(hintText: 'Email address'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: !_showPassword,
                    validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, size: 20),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_isSignIn ? 'Sign In' : 'Create Account',
                              style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      _isSignIn ? "Don't have an account? " : 'Already have an account? ',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isSignIn = !_isSignIn),
                      child: Text(
                        _isSignIn ? 'Sign up' : 'Sign in',
                        style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
