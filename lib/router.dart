import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/deals_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_confirmation_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/support_screen.dart';
import 'screens/auth_screen.dart';

final _protectedRoutes = ['/cart', '/checkout', '/profile', '/orders', '/wishlist'];

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final isLoggedIn = auth.isLoggedIn;
      final path = state.matchedLocation;

      if (_protectedRoutes.any((r) => path.startsWith(r)) && !isLoggedIn) {
        return '/auth?redirect=${Uri.encodeComponent(path)}';
      }
      if (path == '/auth' && isLoggedIn) return '/';
      return null;
    },
    refreshListenable: null, // Handled per-screen via Provider
    routes: [
      GoRoute(path: '/',          builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/products',  builder: (_, state) => ProductListScreen(
        initialCategory: state.uri.queryParameters['cat'],
        initialQuery: state.uri.queryParameters['q'],
      )),
      GoRoute(path: '/products/:id', builder: (_, state) => ProductDetailScreen(
        productId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
      )),
      GoRoute(path: '/deals',     builder: (_, __) => const DealsScreen()),
      GoRoute(path: '/cart',      builder: (_, __) => const CartScreen()),
      GoRoute(path: '/checkout',  builder: (_, __) => const CheckoutScreen()),
      GoRoute(path: '/order-confirmation', builder: (_, state) => OrderConfirmationScreen(
        orderId: state.uri.queryParameters['id'] ?? '',
      )),
      GoRoute(path: '/profile',   builder: (_, __) => const UserProfileScreen()),
      GoRoute(path: '/orders',    builder: (_, __) => const OrderHistoryScreen()),
      GoRoute(path: '/wishlist',  builder: (_, __) => const WishlistScreen()),
      GoRoute(path: '/support',   builder: (_, __) => const SupportScreen()),
      GoRoute(path: '/auth',      builder: (_, state) => AuthScreen(
        redirectTo: state.uri.queryParameters['redirect'],
      )),
    ],
  );
}
