import 'package:flutter/material.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/features/auth/presentation/pages/splash_page.dart';
import 'package:sueltito/features/auth/presentation/pages/welcome_page.dart';
import 'package:sueltito/features/auth/presentation/pages/sign_up_page.dart';
import 'package:sueltito/features/main_navigation/presentation/pages/main_navigation_page.dart';
import 'package:sueltito/features/payment/presentation/pages/minibus_payment_page.dart';
import 'package:sueltito/features/payment/presentation/pages/trufis_payment_page.dart';
import 'package:sueltito/features/payment/presentation/pages/payment_status_page.dart';
import 'package:sueltito/features/payment/domain/enums/payment_status_enum.dart';
import 'package:sueltito/features/payment/presentation/pages/taxi_payment_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sueltito',
      theme: getAppTheme(),
      home: const SplashPage(),
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/sign_up': (context) => const SignUpPage(),
        '/passenger_home': (context) => const MainNavigationPage(),
        '/minibus_payment': (context) => const MinibusPaymentPage(),
        '/trufis_payment': (context) => const TrufiPaymentPage(),
        '/taxi_payment': (context) => const TaxiPaymentPage(),
        '/payment_status': (context) {
          final PaymentStatus status =
              ModalRoute.of(context)!.settings.arguments as PaymentStatus;
          return PaymentStatusPage(status: status);
        },
      },
    );
  }
}
