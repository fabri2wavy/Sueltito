import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/constants/app_paths.dart';
import 'package:sueltito/features/payment/domain/enums/payment_status_enum.dart';
import 'package:sueltito/features/payment/presentation/widgets/payment_confirmation_dialog.dart';
import 'package:sueltito/features/payment/domain/entities/pasaje.dart';
import 'package:sueltito/core/constants/pasaje_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- nuevo
import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart'; // <-- nuevo
import 'package:sueltito/core/network/api_client.dart';
import 'package:sueltito/features/payment/infra/datasources/payment_remote_ds.dart';
import 'package:sueltito/features/payment/infra/repositories/payment_repository_impl.dart';
import 'package:sueltito/features/payment/domain/usecases/prepare_pasaje_usecase.dart';
import 'package:sueltito/features/payment/domain/usecases/register_pasaje_usecase.dart';
import 'package:sueltito/features/payment/domain/entities/pasaje_prepare_request.dart';

class MinibusPaymentPage extends ConsumerStatefulWidget {
  const MinibusPaymentPage({super.key});

  @override
  ConsumerState<MinibusPaymentPage> createState() => _MinibusPaymentPageState();
}

class _MinibusPaymentPageState extends ConsumerState<MinibusPaymentPage> {
  Map<String, dynamic>? _conductorData;
  bool _isPreferencial = false;
  final List<Pasaje> _pasajesSeleccionados = [];
  bool _isLoading = false;
  bool _simulateSuccess = true;

  PasajeInfo get _minibusCorto => PasajeConstants.PAP_PASAJES['000001']!;
  PasajeInfo get _minibusLargo => PasajeConstants.PAP_PASAJES['000002']!;
  PasajeInfo get _minibusCortoPref => PasajeConstants.PAP_PASAJES['000005']!;
  PasajeInfo get _minibusLargoPref => PasajeConstants.PAP_PASAJES['000006']!;

  double get precioActualCorto =>
      _isPreferencial ? _minibusCortoPref.tarifa : _minibusCorto.tarifa;
  double get precioActualLargo =>
      _isPreferencial ? _minibusLargoPref.tarifa : _minibusLargo.tarifa;

  double get totalAPagar =>
      _pasajesSeleccionados.fold(0.0, (sum, item) => sum + item.precio);

  // --- NUEVO: Lógica para recibir los datos del NFC ---
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_conductorData == null) {
      final state = GoRouterState.of(context);
      final extra = state.extra;
      if (extra != null && extra is Map<String, dynamic>) {
        setState(() {
          _conductorData = extra;
        });
      } else {
        print("Error: MinibusPaymentPage se abrió sin datos del conductor.");
      }
    }
  }
  // --- FIN NUEVO ---

  void _addPasaje(String nombre, double precio, String codigo) {
    setState(() {
      _pasajesSeleccionados.add(
        Pasaje(nombre: nombre, precio: precio, codigo: codigo),
      );
    });
  }

  void _removePasaje(int index) {
    setState(() {
      _pasajesSeleccionados.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- NUEVO: Muestra un 'cargando' hasta que los datos del NFC lleguen ---
    if (_conductorData == null) {
      return const Scaffold(
        body: Center(
          // Muestra un indicador de carga
          child: CircularProgressIndicator(),
        ),
      );
    }
    // --- FIN NUEVO ---

    // El resto de la UI se construye normal una vez que _conductorData existe
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
                  // --- pasamos los datos del conductor ---
                  _buildDriverInfoCard(_conductorData!),
                  // ------
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
      // ...AppBar
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

  // --- MODIFICADO: Esta función ahora es dinámica y recibe el JSON ---
  Widget _buildDriverInfoCard(Map<String, dynamic> driverData) {
    // 1. Extraemos los bloques (con '?? {}' para evitar errores si no existen)
    final propietario =
        driverData['propietario'] as Map<String, dynamic>? ?? {};
    final servicio = driverData['servicio'] as Map<String, dynamic>? ?? {};

    // 2. Extraemos los datos que queremos mostrar (como hicimos con el Trufi)
    //    El usuario dijo que el JSON no cambia, así que usamos la misma estructura.
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
                // --- MODIFICADO: Mostramos la PLACA ---
                'Placa: $placa',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                // --- MODIFICADO: Mostramos el NOMBRE ---
                nombre,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
              Text(
                // --- NUEVO: Mostramos la RUTA ---
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
  // --- FIN MODIFICADO ---

  Widget _buildFareSelection(BuildContext context) {
    // ... (Tu lógica de _buildFareSelection y _buildFareButton no cambia)
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
                  _isPreferencial
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
                  _isPreferencial
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
    // ...
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
    // usamos ref para leer el usuario logueado
    final currentUser = ref.watch(
      currentUserProvider,
    ); // <-- usa currentUserProvider

    return Column(
      children: [
        ElevatedButton(
      onPressed: hasItems && !_isLoading
              ? () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) {
                      return PaymentConfirmationDialog(
                        pasajes: _pasajesSeleccionados,
                        total: totalAPagar,
                        onConfirm: () async {
                          setState(() { _isLoading = true; });
                          // Datos del conductor sacados del NFC
                          final propietario =
                              _conductorData?['propietario']
                                  as Map<String, dynamic>? ??
                              {};
                          final servicio =
                              _conductorData?['servicio']
                                  as Map<String, dynamic>? ??
                              {};
                          final tag =
                              _conductorData?['tag'] as Map<String, dynamic>? ??
                              {};

                          // Datos del pasajero sacados del currentUser (ref)
                          final pasajeroId = currentUser?.id ?? '';
                          final pasajeroCuenta = currentUser?.celular?? '';

                          // Detalle de pago (solo codigo tipo_pago)
                          final List<Map<String, dynamic>> detalle =
                              _pasajesSeleccionados
                                  .map((p) => {'tipo_pago': p.codigo ?? ''})
                                  .toList();

                          // Monto total (confirmado desde UI)
                          final double montoTotal = totalAPagar;

                          // Armar JSON EXACTO como lo pediste
                          // We build the domain request instead of a raw JSON payload, use the use case below.

                          // Llamamos al UseCase para preparar el pasaje
                          try {
                            final apiClient = ApiClient();
                            final remoteDS = PaymentRemoteDataSourceImpl(apiClient: apiClient);
                            final repository = PaymentRepositoryImpl(remoteDataSource: remoteDS);
                            final usecase = PreparePasajeUseCase(repository);

                            // Build domain request
                            final tramite = TramiteEntity(tramiteId: ' ', numeroAutorizacion: ' ', codigoOtp: ' ');
                            final servicioEntity = ServicioEntity(
                              tipo: servicio['tipo'] ?? servicio['tipo_transporte'] ?? '01',
                              nombre: servicio['nombre'] ?? '',
                              tipoIdentificador: servicio['tipo_identificador'] ?? '',
                              identificador: servicio['identificador'] ?? '',
                              codigoEntidad: servicio['entidad'] ?? servicio['codigo_entidad'] ?? '',
                            );
                            final tagEntity = TagEntity(identificador: tag['tag_uid'] ?? tag['identificador'] ?? '');
                            final usuarioEntity = UsuarioPagoEntity(
                              pasajeroId: pasajeroId,
                              conductorId: propietario['identificador'] ?? '',
                              pasajeroCuenta: pasajeroCuenta,
                              conductorCuenta: propietario['cuenta'] ?? '',
                            );
                            final pagoEntity = PagoEntity(
                              tipoTransporte: servicio['tipo_transporte'] ?? servicio['tipo'] ?? '01',
                              formaPago: '01',
                              montoTotal: montoTotal,
                              detalle: detalle.map((d) => PagoDetalleEntity(tipoPago: d['tipo_pago'] ?? '')).toList(),
                            );

                            final requestDomain = PasajePrepareRequest(
                              tramite: tramite,
                              servicio: servicioEntity,
                              tag: tagEntity,
                              usuario: usuarioEntity,
                              pago: pagoEntity,
                              glosa: 'Pago Pasaje',
                            );

                            // Run use case
                            final response = await usecase(requestDomain);
                            print('Prepare response: ${response.mensaje}');
                            if (response.continuarFlujo) {
                              final registerUsecase = RegisterPasajeUseCase(repository);
                              final tramiteFilled = TramiteEntity(tramiteId: response.data?.idTramite ?? '', numeroAutorizacion: response.data?.numeroAutorizacion ?? '', codigoOtp: '1234');
                              final requestConfirm = PasajePrepareRequest(
                                tramite: tramiteFilled,
                                servicio: servicioEntity,
                                tag: tagEntity,
                                usuario: usuarioEntity,
                                pago: pagoEntity,
                                glosa: 'Pago Pasaje',
                              );
                              final confirmResp = await registerUsecase(requestConfirm);
                              if (confirmResp.continuarFlujo) {
                                final msg = confirmResp.data?.numeroAutorizacion ?? confirmResp.mensaje;
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Confirmado: $msg')));
                              }
                            }
                          } catch (e) {
                            print('Error preparando pasaje: $e');
                            // Optionally show toast/dialog with error
                          } finally {
                            setState(() { _isLoading = false; });
                          }

                          // Simulación de envío + manejo de resultado (igual que antes)
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                          final resultStatus = _simulateSuccess
                              ? PaymentStatus.success
                              : PaymentStatus.rejected;
                          setState(() => _simulateSuccess = !_simulateSuccess);

                          dialogContext.pop();
                          context.go(
                            AppPaths.paymentStatus,
                            extra: resultStatus,
                          );

                          if (resultStatus == PaymentStatus.success) {
                            try {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final List<String> historialJson =
                                  prefs.getStringList('historial') ?? [];
                              final timestamp = DateTime.now()
                                  .toIso8601String();

                              final nuevosItemsJson = _pasajesSeleccionados.map(
                                (pasaje) {
                                  final Map<String, dynamic> transaccion = {
                                    'type': 'minibus',
                                    'timestamp': timestamp,
                                    'nombre': pasaje.nombre,
                                    'precio': pasaje.precio,
                                  };
                                  return json.encode(transaccion);
                                },
                              ).toList();

                              historialJson.addAll(nuevosItemsJson);
                              await prefs.setStringList(
                                'historial',
                                historialJson,
                              );
                            } catch (e) {
                              print("Error al guardar historial: $e");
                            }

                            setState(() {
                              _pasajesSeleccionados.clear();
                            });
                          }
                        },
                        isLoading: _isLoading,
                      );
                    },
                  );
                }
              : null,
          // ... (estilos no cambian)
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
    // ... (Tu _buildSummaryCard y _buildSummaryItem no necesitan cambios)
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
