import 'package:go_router/go_router.dart';
import 'package:sueltito/core/constants/app_paths.dart';
import 'package:flutter/material.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sueltito/features/payment/presentation/providers/payment_provider.dart';
import 'package:sueltito/features/payment/presentation/widgets/payment_confirmation_dialog.dart';
import 'package:sueltito/features/payment/presentation/widgets/send_button.dart';
import 'package:sueltito/core/services/notification_service.dart';
import 'package:sueltito/features/payment/domain/enums/payment_status_enum.dart';
import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart';

class TaxiPaymentPage extends ConsumerStatefulWidget {
  const TaxiPaymentPage({super.key});

  @override
  ConsumerState<TaxiPaymentPage> createState() => _TaxiPaymentPageState();
}

class _TaxiPaymentPageState extends ConsumerState<TaxiPaymentPage> {
  final TextEditingController _montoController = TextEditingController();
  String? _montoError;

  @override
  void initState() {
    super.initState();
    _montoController.addListener(_actualizarMonto);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GoRouterState.of(context);
    final extra = state.extra;
    if (extra == null || !(extra is Map<String, dynamic>)) {
      print("Error: TaxiPaymentPage se abrió sin datos del conductor.");
    }
  }

  @override
  void dispose() {
    _montoController.removeListener(_actualizarMonto);
    _montoController.dispose();
    super.dispose();
  }

  void _actualizarMonto() {
    double? monto = double.tryParse(_montoController.text);
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra != null) {
      ref.read(paymentProvider(extra).notifier).setMonto(monto);
    }
    setState(() {
      _montoError = monto == null || monto <= 0
          ? (_montoController.text.isNotEmpty ? 'Monto inválido' : null)
          : null;
    });
  }

  double get totalAPagar {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    return extra == null ? 0.0 : ref.watch(paymentProvider(extra)).totalAPagar;
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final paymentState = ref.watch(paymentProvider(extra));
    if (paymentState.conductorData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        'Bienvenido al Taxi\nFabricio',
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
    final String nombreEmpresa = servicio['nombre'] as String? ?? 'Radio Taxi';

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
                nombreEmpresa, 
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          const Icon(Icons.local_taxi, size: 40, color: AppColors.textBlack),
        ],
      ),
    );
  }

  Widget _buildFareSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingrese el monto a Pagar',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _montoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textBlack,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixText: 'Bs ',
            prefixStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            errorText: _montoError,
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra == null) return const SizedBox.shrink();
    final paymentState = ref.watch(paymentProvider(extra));
    bool hasItems = paymentState.selectedPasajes.isNotEmpty;

    return SendButton(
      isEnabled: hasItems,
      isLoading: paymentState.isLoading,
      onPressed: () async {
        if (!mounted) return;
        final currentUser = ref.read(currentUserProvider);
        final pasajeroId = currentUser?.id ?? '';
        final pasajeroCuenta = currentUser?.nroCuenta ?? '';
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
                total: totalAPagar,
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
                    Navigator.of(dialogContext).pop();
                    if (registerResp.continuarFlujo) {
                      notifSvc.showSuccess('Pago ejecutado correctamente');
                      _montoController.clear();
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
                        notifSvc.showError(
                          msg.isNotEmpty
                              ? msg
                              : 'Error en confirmación del pago',
                        );
                      }
                    }
                  } catch (e) {
                    final err = e is ApiException ? e.message : e.toString().replaceAll('Exception: ', '');
                    if (err.contains('http') && (err.endsWith('.png') || err.endsWith('.jpg') || err.endsWith('.jpeg'))) {
                      showDialog(context: context, builder: (_) => Dialog(child: Image.network(err)));
                    } else {
                      notifSvc.showError(err);
                    }
                  }
                },
              );
            },
          );
        } catch (e) {
          final notifSvc = ref.read(notificationServiceProvider);
          final err = e is ApiException ? e.message : e.toString().replaceAll('Exception: ', '');
          notifSvc.showError(err);
        }
      },
      tooltip: hasItems ? null : (_montoError ?? 'Ingrese un monto válido'),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra == null) return const SizedBox.shrink();
    final paymentState = ref.watch(paymentProvider(extra));
    Map<String, int> pasajeCounts = {};
    for (var pasaje in paymentState.selectedPasajes) {
      pasajeCounts[pasaje.nombre] = (pasajeCounts[pasaje.nombre] ?? 0) + 1;
    }

    List<Widget> itemsWidget = pasajeCounts.entries.map((entry) {
      String nombre = entry.key;
      int cantidad = entry.value;
      double precioUnitario = paymentState.selectedPasajes
          .firstWhere((p) => p.nombre == nombre)
          .precio;
      double subtotal = cantidad * precioUnitario;

      return _buildSummaryItem(
        context,
        nombre,
        '$cantidad carrera', 
        subtotal,
        () {
          setState(() {
            ref.read(paymentProvider(extra).notifier).clearPasajes();
            _montoController.clear();
          });
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
          if (paymentState.selectedPasajes.isEmpty)
            const Text(
              'Ingrese un monto para comenzar...',
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
