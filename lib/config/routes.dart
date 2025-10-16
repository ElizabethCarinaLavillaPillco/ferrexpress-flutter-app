import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/ferreteria/ferreteria_detail_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/tracking/order_tracking_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String ferreteriaDetail = '/ferreteria-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderTracking = '/order-tracking';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return _createRoute(const LoginScreen());
      case register:
        return _createRoute(const RegisterScreen());
      case home:
        return _createRoute(const HomeScreen());
      case search:
        return _createRoute(const SearchScreen());
      case ferreteriaDetail:
        return _createRoute(FerreteriaDetailScreen(
          ferreteria: settings.arguments as dynamic,
        ));
      case cart:
        return _createRoute(const CartScreen());
      case checkout:
        return _createRoute(const CheckoutScreen());
      case orderTracking:
        return _createRoute(OrderTrackingScreen(
          orderId: settings.arguments as String,
        ));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }

  static PageRoute _createRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}