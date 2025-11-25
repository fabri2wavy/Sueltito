import 'package:flutter/material.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sueltito/features/payment/presentation/providers/payment_provider.dart';
import 'package:sueltito/features/payment/domain/entities/pasaje.dart';

class PaymentConfirmationDialog extends ConsumerStatefulWidget {
  final List<Pasaje> pasajes;
  final double total;
  final void Function(String otp) onConfirm;
  final Map<String, dynamic>? extra;

  const PaymentConfirmationDialog({
    super.key,
    required this.pasajes,
    required this.total,
    required this.onConfirm,
    this.extra,
  });

  @override
  ConsumerState<PaymentConfirmationDialog> createState() => _PaymentConfirmationDialogState();
}

class _PaymentConfirmationDialogState extends ConsumerState<PaymentConfirmationDialog> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> pasajeCounts = {};
    for (final pasaje in widget.pasajes) {
      pasajeCounts[pasaje.nombre] = (pasajeCounts[pasaje.nombre] ?? 0) + 1;
    }

  final isLoading = widget.extra == null ? false : ref.watch(paymentProvider(widget.extra!)).isLoading;
  return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Confirmación de Pago',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Se ha enviado un código OTP a tu celular. Revísalo y escríbelo aquí.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                hintText: 'Introduzca el código OTP.',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            // Items list
            ...pasajeCounts.entries.map((entry) {
              final nombre = entry.key;
              final cantidad = entry.value;
              final precioUnitario = widget.pasajes.firstWhere((p) => p.nombre == nombre).precio;
              final subtotal = cantidad * precioUnitario;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text('$cantidad persona(s)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Bs ${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text('Bs. ${precioUnitario.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final otp = _otpController.text.trim();
                            widget.onConfirm(otp);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white)),
                              const SizedBox(width: 8),
                            ],
                          )
                        : const Text('Pagar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
