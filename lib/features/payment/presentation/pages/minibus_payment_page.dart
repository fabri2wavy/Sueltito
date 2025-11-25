import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/constants/app_paths.dart';
import 'package:sueltito/features/payment/domain/entities/pasaje.dart';
import 'package:sueltito/core/constants/pasaje_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart';
import 'package:sueltito/features/payment/presentation/providers/payment_provider.dart';
import 'package:sueltito/features/payment/presentation/widgets/payment_confirmation_dialog.dart';
import 'package:sueltito/features/payment/presentation/widgets/send_button.dart';
import 'package:sueltito/features/payment/domain/enums/payment_status_enum.dart';
import 'package:sueltito/core/services/notification_service.dart';

class MinibusPaymentPage extends ConsumerStatefulWidget {
  const MinibusPaymentPage({super.key});

  @override
  ConsumerState<MinibusPaymentPage> createState() => _MinibusPaymentPageState();
}

class _MinibusPaymentPageState extends ConsumerState<MinibusPaymentPage> {
  PasajeInfo get _minibusCorto => PasajeConstants.PAP_PASAJES['000001']!;
  PasajeInfo get _minibusLargo => PasajeConstants.PAP_PASAJES['000002']!;
  PasajeInfo get _minibusCortoPref => PasajeConstants.PAP_PASAJES['000005']!;
  PasajeInfo get _minibusLargoPref => PasajeConstants.PAP_PASAJES['000006']!;

  double get precioActualCorto {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final isPref = extra == null
        ? false
        : ref.watch(paymentProvider(extra)).isPreferencial;
    return isPref ? _minibusCortoPref.tarifa : _minibusCorto.tarifa;
  }

  double get precioActualLargo {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final isPref = extra == null
        ? false
        : ref.watch(paymentProvider(extra)).isPreferencial;
    return isPref ? _minibusLargoPref.tarifa : _minibusLargo.tarifa;
  }

  double get totalAPagar {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    return extra == null ? 0.0 : ref.watch(paymentProvider(extra)).totalAPagar;
  }


  void _addPasaje(String nombre, double precio, String codigo) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra == null) return;
    ref
        .read(paymentProvider(extra).notifier)
        .addPasaje(Pasaje(nombre: nombre, precio: precio, codigo: codigo));
  }

  void _removePasaje(int index) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra == null) return;
    ref.read(paymentProvider(extra).notifier).removePasajeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra == null) return const SizedBox.shrink();
    final paymentState = ref.watch(paymentProvider(extra));
    if (paymentState.conductorData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                  _buildDriverInfoCard(paymentState.conductorData!),
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
        onPressed: () => context.pop(),
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

  Widget _buildDriverInfoCard(Map<String, dynamic> driverData) {
    final propietario =
        driverData['propietario'] as Map<String, dynamic>? ?? {};
    final servicio = driverData['servicio'] as Map<String, dynamic>? ?? {};

    final String nombre =
        propietario['nombre'] as String? ?? 'Conductor no encontrado';
    final String placa = servicio['identificador'] as String? ?? 'S/N';
    final String nombreRuta =
        servicio['nombre'] as String? ?? 'Ruta desconocida';

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
              Text(
                'Placa: $placa',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                nombre,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
              Text(
                nombreRuta,
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
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra == null) return const SizedBox.shrink();
    final paymentState = ref.watch(paymentProvider(extra));
    bool hasCorto = paymentState.selectedPasajes.any(
      (p) => p.nombre == 'Tramo Corto',
    );
    bool hasLargo = paymentState.selectedPasajes.any(
      (p) => p.nombre == 'Tramo Largo',
    );

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
                  value: paymentState.isPreferencial,
                  onChanged: (value) {
                    ref
                        .read(paymentProvider(extra).notifier)
                        .setPreferencial(value);
                  },
                  activeColor: AppColors.primaryGreen,
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
                () => _addPasaje(
                  'Tramo Corto',
                  precioActualCorto,
                  paymentState.isPreferencial
                      ? _minibusCortoPref.codigo
                      : _minibusCorto.codigo,
                ),
                isSelected: hasCorto,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFareButton(
                context,
                'Largo',
                precioActualLargo,
                () => _addPasaje(
                  'Tramo Largo',
                  precioActualLargo,
                  paymentState.isPreferencial
                      ? _minibusLargoPref.codigo
                      : _minibusLargo.codigo,
                ),
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
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra == null) return const SizedBox.shrink();
    final paymentState = ref.watch(paymentProvider(extra));
    bool hasItems =
        paymentState.selectedPasajes.isNotEmpty && !paymentState.isLoading;
    final currentUser = ref.watch(
      currentUserProvider,
    ); 

    return SendButton(
      isEnabled: hasItems,
      isLoading: paymentState.isLoading,
      onPressed: () async =>
          _handlePayment(context, currentUser, paymentState, extra),
      tooltip: hasItems ? null : 'Añade un tramo para pagar',
    );
  }

  Future<void> _handlePayment(
    BuildContext context,
    dynamic currentUser,
    PaymentState paymentState,
    Map<String, dynamic> extra,
  ) async {
    final pasajeroId = currentUser?.id ?? '';
    final pasajeroCuenta = currentUser?.celular ?? '';
    final notifSvc = ref.read(notificationServiceProvider);
    try {
      final prepareResp = await ref
          .read(paymentProvider(extra).notifier)
          .preparePasaje(
            pasajeroId: pasajeroId,
            pasajeroCuenta: pasajeroCuenta,
          );
      if (!mounted) return;
      if (!prepareResp.continuarFlujo) {
        notifSvc.showError(prepareResp.mensaje);
        return;
      }
      notifSvc.showSuccess(
        'Se ha enviado un código OTP a tu celular. Revísalo y escríbelo aquí.',
      );
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return PaymentConfirmationDialog(
            pasajes: paymentState.selectedPasajes,
            total: paymentState.totalAPagar,
            extra: extra,
            onConfirm: (otp) async {
              try {
                final registerResp = await ref
                    .read(paymentProvider(extra).notifier)
                    .registerPasaje(
                      codigoOtp: otp,
                      pasajeroId: pasajeroId,
                      pasajeroCuenta: pasajeroCuenta,
                    );
                if (!mounted) return;
                Navigator.of(dialogContext).pop();
                if (registerResp.continuarFlujo) {
                  notifSvc.showSuccess('Pago ejecutado correctamente');
                  context.go(
                    AppPaths.paymentStatus,
                    extra: PaymentStatus.success,
                  );
                } else {
                  final msg = registerResp.mensaje;
                  if (msg.contains('http') &&
                      (msg.endsWith('.png') ||
                          msg.endsWith('.jpg') ||
                          msg.endsWith('.jpeg'))) {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(child: Image.network(msg)),
                    );
                  } else {
                    notifSvc.showError(msg);
                  }
                }
              } catch (e) {
                notifSvc.showError(e.toString());
              }
            },
          );
        },
      );
    } catch (e) {
      notifSvc.showError(e.toString());
    }
  }

  Widget _buildSummaryCard(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final paymentState = extra == null
        ? null
        : ref.watch(paymentProvider(extra));
    Map<String, int> pasajeCounts = {};
    for (var pasaje in paymentState?.selectedPasajes ?? []) {
      pasajeCounts[pasaje.nombre] = (pasajeCounts[pasaje.nombre] ?? 0) + 1;
    }

    List<Widget> itemsWidget = pasajeCounts.entries.map((entry) {
      String nombre = entry.key;
      int cantidad = entry.value;
      double precioUnitario =
          paymentState?.selectedPasajes
              .firstWhere((p) => p.nombre == nombre)
              .precio ??
          0.0;
      double subtotal = cantidad * precioUnitario;

      return _buildSummaryItem(
        context,
        nombre,
        '$cantidad persona${cantidad > 1 ? 's' : ''}',
        subtotal,
        () {
          int indexToRemove =
              paymentState?.selectedPasajes.indexWhere(
                (p) => p.nombre == nombre,
              ) ??
              -1;
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
          if (paymentState?.selectedPasajes.isEmpty ?? true)
            const Text(
              'Añade un tramo para comenzar...',
              textAlign: TextAlign.center,
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
