import 'package:flutter/material.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/features/payment/presentation/pages/minibus_payment_page.dart';

class PaymentConfirmationDialog extends StatelessWidget {
  final List<Pasaje> pasajes;
  final double total;
  final VoidCallback onConfirm;

  const PaymentConfirmationDialog({
    super.key,
    required this.pasajes,
    required this.total,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, int> pasajeCounts = {};
    for (var pasaje in pasajes) {
      pasajeCounts[pasaje.nombre] = (pasajeCounts[pasaje.nombre] ?? 0) + 1;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Título
            Text(
              'Confirmación de Pago',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            // 2. Input del Código
            TextField(
              decoration: InputDecoration(
                hintText: 'Introduzca el código que le llegó al celular.',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // 3. Lista de Items (Resumen)
            ...pasajeCounts.entries.map((entry) {
              String nombre = entry.key;
              int cantidad = entry.value;
              // Buscamos precio unitario
              double precioUnitario = pasajes
                  .firstWhere((p) => p.nombre == nombre)
                  .precio;
              double subtotal = cantidad * precioUnitario;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '$cantidad persona(s)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Bs ${subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Bs. ${precioUnitario.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 20),

            // 4. Botones de Acción
            Row(
              children: [
                // Botón Cancelar
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(), // Cierra el diálogo
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                // Botón Pagar
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Pagar'),
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
