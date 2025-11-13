import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

// Core
import 'package:sueltito/core/config/app_theme.dart';
// Feature: Auth
import 'package:sueltito/features/auth/presentation/pages/splash_page.dart';
import 'package:sueltito/features/auth/presentation/pages/welcome_page.dart';
import 'package:sueltito/features/auth/presentation/pages/sign_up_page.dart';
// Feature: Main Navigation
import 'package:sueltito/features/main_navigation/presentation/pages/main_navigation_page.dart';
// Pantalla de pago
import 'package:sueltito/features/payment/presentation/pages/minibus_payment_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupNfcListener();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Sueltito',
      theme: getAppTheme(),
      home: const SplashPage(),
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/sign_up': (context) => const SignUpPage(),
        '/passenger_home': (context) => const MainNavigationPage(),
        '/minibus_payment': (context) => const MinibusPaymentPage(),
      },
    );
  }
}

Future<void> _setupNfcListener() async {
  while (true) {
    try {
      print("Esperando tag NFC...");
      NFCTag tag = await FlutterNfcKit.poll(timeout: const Duration(seconds: 20));

      if (tag.ndefAvailable == true) {
        List<dynamic> records = await FlutterNfcKit.readNDEFRecords(cached: false);
        if (records.isNotEmpty) {
          final rec = records.first;
          final payload = rec.payload;
          String tagContent;
          if (payload is String) {
            tagContent = payload;
          } else if (payload is List<int>) {
            tagContent = utf8.decode(payload);
          } else {
            tagContent = payload.toString();
          }

          final Map<String, dynamic> conductorData = json.decode(tagContent);
          print("Tag NFC leído: $conductorData");

          navigatorKey.currentState?.pushNamed(
            '/minibus_payment',
            arguments: conductorData,
          );
        } else {
          print("El tag no contiene registros NDEF.");
        }
      } else {
        print("El tag no soporta NDEF.");
      }

      await FlutterNfcKit.finish();
    } catch (e) {
      print("Error leyendo NFC: $e");
      try {
        await FlutterNfcKit.finish();
      } catch (_) {}
    }

    await Future.delayed(const Duration(seconds: 2));
  }
}
