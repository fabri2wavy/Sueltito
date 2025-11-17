import 'package:flutter/material.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/features/payment/domain/enums/payment_status_enum.dart';
import 'package:sueltito/features/payment/presentation/widgets/payment_confirmation_dialog.dart';
import 'package:sueltito/features/payment/domain/entities/pasaje.dart';

class MinibusPaymentPage extends StatefulWidget {
  const MinibusPaymentPage({super.key});

  @override
  State<MinibusPaymentPage> createState() => _MinibusPaymentPageState();
}

class _MinibusPaymentPageState extends State<MinibusPaymentPage> {
  bool _isPreferencial = false;
  final List<Pasaje> _pasajesSeleccionados = [];
  bool _simulateSuccess = true;

  // --- PRECIOS ESPECÍFICOS PARA MINIBUS (SOLO CORTO Y LARGO) ---
  static const double _precioCorto = 2.40;
  static const double _precioCortoPref = 2.00;
  static const double _precioLargo = 3.00;
  static const double _precioLargoPref = 2.50;

  double get precioActualCorto =>
      _isPreferencial ? _precioCortoPref : _precioCorto;
  double get precioActualLargo =>
      _isPreferencial ? _precioLargoPref : _precioLargo;

  double get totalAPagar =>
      _pasajesSeleccionados.fold(0.0, (sum, item) => sum + item.precio);

  void _addPasaje(String nombre, double precio) {
    setState(() {
      _pasajesSeleccionados.add(Pasaje(nombre: nombre, precio: precio));
    });
  }

  void _removePasaje(int index) {
    setState(() {
      _pasajesSeleccionados.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDriverInfoCard(),
                  const SizedBox(height: 24),
                  _buildFareSelection(context),
                  const SizedBox(height: 24),
                  _buildPayButton(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildSummaryCard(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        'Bienvenido al Minibus\nFabricio',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CEL: 6818794',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Roberto Vasquez Perez',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          const Icon(
            Icons.directions_bus,
            size: 40,
            color: AppColors.textBlack,
          ),
        ],
      ),
    );
  }

  Widget _buildFareSelection(BuildContext context) {
    bool hasCorto = _pasajesSeleccionados.any((p) => p.nombre == 'Tramo Corto');
    bool hasLargo = _pasajesSeleccionados.any((p) => p.nombre == 'Tramo Largo');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Elige tu tramo:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                Text(
                  'Tarifa Preferencial?',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Switch(
                  value: _isPreferencial,
                  onChanged: (value) {
                    setState(() {
                      _isPreferencial = value;
                    });
                  },
                  activeThumbColor: AppColors.primaryGreen,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFareButton(
                context,
                'Corto',
                precioActualCorto,
                () => _addPasaje('Tramo Corto', precioActualCorto),
                isSelected: hasCorto,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFareButton(
                context,
                'Largo',
                precioActualLargo,
                () => _addPasaje('Tramo Largo', precioActualLargo),
                isSelected: hasLargo,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFareButton(
    BuildContext context,
    String label,
    double price,
    VoidCallback onPressed, {
    required bool isSelected,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primaryGreen : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Bs. ${price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    bool hasItems = _pasajesSeleccionados.isNotEmpty;

    return Column(
      children: [
        ElevatedButton(
          onPressed: hasItems
              ? () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) {
                      return PaymentConfirmationDialog(
                        pasajes: _pasajesSeleccionados,
                        total: totalAPagar,
                        onConfirm: () async {
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );

                          final PaymentStatus resultStatus;
                          if (_simulateSuccess) {
                            resultStatus = PaymentStatus.success;
                          } else {
                            resultStatus = PaymentStatus.rejected;
                          }

                          setState(() {
                            _simulateSuccess = !_simulateSuccess;
                          });

                          Navigator.of(dialogContext).pop();

                          Navigator.of(context).pushNamed(
                            '/payment_status',
                            arguments: resultStatus,
                          );

                          if (resultStatus == PaymentStatus.success) {
                            setState(() {
                              _pasajesSeleccionados.clear();
                            });
                          }
                        },
                      );
                    },
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
            backgroundColor: hasItems
                ? const Color.fromARGB(255, 84, 209, 190)
                : Colors.grey[400],
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[500],
          ),
          child: const Icon(Icons.attach_money, size: 35),
        ),
        const SizedBox(height: 8),
        Text(
          'ENVIAR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: hasItems ? AppColors.primaryGreen : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    Map<String, int> pasajeCounts = {};
    for (var pasaje in _pasajesSeleccionados) {
      pasajeCounts[pasaje.nombre] = (pasajeCounts[pasaje.nombre] ?? 0) + 1;
    }

    List<Widget> itemsWidget = pasajeCounts.entries.map((entry) {
      String nombre = entry.key;
      int cantidad = entry.value;
      double precioUnitario = _pasajesSeleccionados
          .firstWhere((p) => p.nombre == nombre)
          .precio;
      double subtotal = cantidad * precioUnitario;

      return _buildSummaryItem(
        context,
        nombre,
        '$cantidad persona${cantidad > 1 ? 's' : ''}',
        subtotal,
        () {
          int indexToRemove = _pasajesSeleccionados.indexWhere(
            (p) => p.nombre == nombre,
          );
          if (indexToRemove != -1) {
            _removePasaje(indexToRemove);
          }
        },
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Selección de Pasajes',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_pasajesSeleccionados.isEmpty)
            const Text(
              'Añade un tramo para comenzar...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ...itemsWidget,
          const Divider(height: 32, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Bs. ${totalAPagar.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String subtitle,
    double subtotal,
    VoidCallback onQuitar,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Bs ${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onQuitar,
                child: Text(
                  'quitar',
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
