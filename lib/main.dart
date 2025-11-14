import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ Importar

// Core
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/features/auth/presentation/pages/login_page.dart';

// Feature: Auth
import 'package:sueltito/features/auth/presentation/pages/splash_page.dart';
import 'package:sueltito/features/auth/presentation/pages/welcome_page.dart';
import 'package:sueltito/features/auth/presentation/pages/sign_up_page.dart';
import 'package:sueltito/features/driver/presentation/pages/driver_home_page.dart';

// Feature: Main Navigation (Shell)
import 'package:sueltito/features/main_navigation/presentation/pages/main_navigation_page.dart';

// Feature: Payment
import 'package:sueltito/features/payment/presentation/pages/minibus_payment_page.dart';

Future<void> main() async {
  // ✅ Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Cargar variables de entorno
  await dotenv.load(fileName: ".env");
  
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
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
      locale: const Locale('es', 'BO'),
      supportedLocales: const [
        Locale('es', 'BO'),
        Locale('es'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/sign_up': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/passenger_home': (context) => const MainNavigationPage(),
        '/minibus_payment': (context) => const MinibusPaymentPage(),
        '/driver_home': (context) => const DriverHomePage(),
      },
    );
  }
}
