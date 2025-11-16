import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/features/payment/domain/enums/payment_status_enum.dart';

class PaymentStatusPage extends StatefulWidget {
  final PaymentStatus status;

  const PaymentStatusPage({super.key, required this.status});

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  @override
  void initState() {
    super.initState();
    // Temporizador de 3 segundos para redirigir
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Limpia toda la pila de navegación y nos lleva al Home
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/passenger_home',
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = widget.status == PaymentStatus.success;

    final String message = isSuccess
        ? 'Tu pago fue realizado\ndesde Sueltito.'
        : 'Tu pago fue rechazado\ndesde Sueltito.';

    final String imagePath = isSuccess
        ? 'assets/images/page_correct.png'
        : 'assets/images/page_failed.png';

    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 150, height: 150),
            const SizedBox(height: 32),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
