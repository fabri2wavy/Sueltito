import 'package:sueltito/core/constants/app_paths.dart';
import 'package:sueltito/core/constants/roles.dart';
import 'package:sueltito/core/navigation/domain/entities/route_config.dart';
import 'package:sueltito/core/security/domain/entities/permission.dart';
import 'package:sueltito/features/auth/presentation/pages/splash_page.dart';

// Pages
import 'package:sueltito/features/auth/presentation/pages/welcome_page.dart';
import 'package:sueltito/features/auth/presentation/pages/login_page.dart';
import 'package:sueltito/features/auth/presentation/pages/sign_up_page.dart';
import 'package:sueltito/features/main_navigation/presentation/pages/main_navigation_page.dart';
import 'package:sueltito/features/driver/presentation/pages/driver_home_page.dart';
import 'package:sueltito/features/payment/domain/enums/payment_status_enum.dart';
import 'package:sueltito/features/payment/presentation/pages/minibus_payment_page.dart';
import 'package:sueltito/features/payment/presentation/pages/trufis_payment_page.dart';
import 'package:sueltito/features/payment/presentation/pages/taxi_payment_page.dart';
import 'package:sueltito/features/payment/presentation/pages/payment_status_page.dart';

class RoutePermissions {
  RoutePermissions._();

  static final List<RouteConfig> routes = [
    // ===== PUBLIC ROUTES =====
    RouteConfig(
      path: AppPaths.splash,
      builder: (context, state) => const SplashPage(),
      isPublic: true,
    ),
    RouteConfig(
      path: AppPaths.welcome,
      builder: (context, state) => const WelcomePage(),
      isPublic: true,
    ),
    RouteConfig(
      path: AppPaths.login,
      builder: (context, state) => const LoginPage(),
      isPublic: true,
    ),
    RouteConfig(
      path: AppPaths.signUp,
      builder: (context, state) => const SignUpPage(),
      isPublic: true,
    ),

    // ===== PASSENGER ROUTES =====
    RouteConfig(
      path: AppPaths.passengerHome,
      builder: (context, state) => const MainNavigationPage(),
      permission: const Permission(requiredPerfiles: [Roles.pasajero]),
    ),
    RouteConfig(
      path: AppPaths.minibusPayment,
      builder: (context, state) => const MinibusPaymentPage(),
      permission: const Permission(requiredPerfiles: [Roles.pasajero]),
    ),
    RouteConfig(
      path: AppPaths.trufisPayment,
      builder: (context, state) => const TrufiPaymentPage(),
      permission: const Permission(requiredPerfiles: [Roles.pasajero]),
    ),
    RouteConfig(
      path: AppPaths.taxiPayment,
      builder: (context, state) => const TaxiPaymentPage(),
      permission: const Permission(requiredPerfiles: [Roles.pasajero]),
    ),

    // ===== DRIVER ROUTES =====
    RouteConfig(
      path: AppPaths.driverHome,
      builder: (context, state) => const DriverHomePage(),
      permission: const Permission(requiredPerfiles: [Roles.chofer]),
    ),

    // ===== PAYMENT ROUTES =====
    RouteConfig(
      path: AppPaths.paymentStatus,
      builder: (context, state) {
        final status = state.extra as PaymentStatus;
        return PaymentStatusPage(status: status);
      },
      permission: const Permission(
        requiredPerfiles: [Roles.pasajero, Roles.chofer],
      ),
    ),
  ];

  // ===== HELPERS =====
  static RouteConfig? findByPath(String path) {
    try {
      return routes.firstWhere((r) => r.path == path);
    } catch (_) {
      return null;
    }
  }

  static bool isPublic(String path) =>
      findByPath(path)?.isPublic ?? false;

  static Permission? getPermission(String path) =>
      findByPath(path)?.permission;
}