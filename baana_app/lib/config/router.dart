import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/register_screen.dart';
import '../screens/login_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/business_profile_screen.dart';
import '../screens/main_layout_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/cart/checkout_screen.dart';
import '../screens/cart/payment_mobile_money_screen.dart';
import '../screens/cart/confirmation_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/dashboard_pro_screen.dart';
import '../screens/profile/notifications_screen.dart';
import '../screens/order/order_history_screen.dart';
import '../screens/order/order_tracking_screen.dart';
import '../screens/profile/subscription_compare_screen.dart';
import '../screens/profile/subscription_payment_screen.dart';
import '../screens/profile/subscription_confirmation_screen.dart';
import '../screens/profile/support_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../config/colors.dart';
import '../config/typography.dart';

/// Configuration du routeur GoRouter pour l'application Baana.
/// Routes initiales : Splash → Onboarding → Register (placeholder)
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash Screen — route initiale, non-popable
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // Onboarding — 3 slides, non-popable (pas de retour vers splash)
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Register
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Login
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // OTP
    GoRoute(
      path: '/otp',
      builder: (context, state) => const OtpScreen(),
    ),

    // Business Profile
    GoRoute(
      path: '/business_profile',
      builder: (context, state) => const BusinessProfileScreen(),
    ),

    // Home / Main Layout
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainLayoutScreen(),
    ),

    // Product Detail
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailScreen(productId: productId);
      },
    ),

    // Cart
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),

    // Checkout
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),

    // Payment Mobile Money
    GoRoute(
      path: '/payment_mobile_money',
      builder: (context, state) => const PaymentMobileMoneyScreen(),
    ),

    // Confirmation
    GoRoute(
      path: '/confirmation',
      builder: (context, state) => const ConfirmationScreen(),
    ),

    // Profile
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/dashboard_pro',
      builder: (context, state) => const DashboardProScreen(),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrderHistoryScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/order_tracking/:id',
      builder: (context, state) {
        final orderId = state.pathParameters['id']!;
        return OrderTrackingScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/subscription_compare',
      builder: (context, state) => const SubscriptionCompareScreen(),
    ),
    GoRoute(
      path: '/subscription_payment',
      builder: (context, state) {
        final plan = state.extra as String? ?? 'mensuel';
        return SubscriptionPaymentScreen(plan: plan);
      },
    ),
    GoRoute(
      path: '/subscription_confirmation',
      builder: (context, state) {
        final plan = state.extra as String? ?? 'mensuel';
        return SubscriptionConfirmationScreen(plan: plan);
      },
    ),
    GoRoute(
      path: '/support',
      builder: (context, state) => const SupportScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
