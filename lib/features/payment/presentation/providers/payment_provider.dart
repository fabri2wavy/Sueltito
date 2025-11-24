import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/pasaje.dart';
import '../../domain/usecases/prepare_pasaje_usecase.dart';
import '../../domain/usecases/register_pasaje_usecase.dart';
import '../../domain/entities/pasaje_prepare_response.dart';
import '../../infra/datasources/payment_remote_ds.dart';
import '../../infra/repositories/payment_repository_impl.dart';
import '../../domain/entities/pasaje_prepare_request.dart';

class PaymentState {
  final Map<String, dynamic>? conductorData;
  final List<Pasaje> selectedPasajes;
  final bool isPreferencial;
  final bool isLoading;
  final bool simulateSuccess;
  final String? montoError;

  const PaymentState({
    this.conductorData,
    this.selectedPasajes = const [],
    this.isPreferencial = false,
    this.isLoading = false,
    this.simulateSuccess = true,
    this.montoError,
  });

  PaymentState copyWith({
    Map<String, dynamic>? conductorData,
    List<Pasaje>? selectedPasajes,
    bool? isPreferencial,
    bool? isLoading,
    bool? simulateSuccess,
    String? montoError,
  }) {
    return PaymentState(
      conductorData: conductorData ?? this.conductorData,
      selectedPasajes: selectedPasajes ?? this.selectedPasajes,
      isPreferencial: isPreferencial ?? this.isPreferencial,
      isLoading: isLoading ?? this.isLoading,
      simulateSuccess: simulateSuccess ?? this.simulateSuccess,
      montoError: montoError ?? this.montoError,
    );
  }

  double get totalAPagar =>
      selectedPasajes.fold(0.0, (sum, item) => sum + item.precio);
}

class PaymentNotifier
    extends FamilyNotifier<PaymentState, Map<String, dynamic>> {
  late final PreparePasajeUseCase _prepareUsecase;
  late final RegisterPasajeUseCase _registerUsecase;
  PasajePrepareResponse? _lastPrepareResponse;

  @override
  PaymentState build(Map<String, dynamic> conductorData) {
    final apiClient = ApiClient();
    final remoteDS = PaymentRemoteDataSourceImpl(apiClient: apiClient);
    final repository = PaymentRepositoryImpl(remoteDataSource: remoteDS);
    _prepareUsecase = PreparePasajeUseCase(repository);
    _registerUsecase = RegisterPasajeUseCase(repository);
    return PaymentState(conductorData: conductorData);
  }

  void addPasaje(Pasaje pasaje) {
    state = state.copyWith(selectedPasajes: [...state.selectedPasajes, pasaje]);
  }

  void removePasajeAt(int index) {
    final newList = List<Pasaje>.from(state.selectedPasajes);
    if (index >= 0 && index < newList.length) {
      newList.removeAt(index);
      state = state.copyWith(selectedPasajes: newList);
    }
  }

  void clearPasajes() {
    state = state.copyWith(selectedPasajes: []);
  }

  void setPreferencial(bool value) {
    state = state.copyWith(isPreferencial: value);
  }

  void setMonto(double? monto) {
    if (monto == null || monto <= 0) {
      state = state.copyWith(
        montoError: monto == null || monto == 0 ? null : 'Monto inválido',
      );
      if (monto == null || monto == 0) {
        state = state.copyWith(selectedPasajes: []);
      }
      return;
    }
    final taxiPasaje = Pasaje(
      nombre: 'Pasaje Taxi',
      precio: monto,
      codigo: 'taxi',
    );
    state = state.copyWith(selectedPasajes: [taxiPasaje], montoError: null);
  }

  void toggleSimulate() {
    state = state.copyWith(simulateSuccess: !state.simulateSuccess);
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  Future<PasajePrepareResponse> preparePasaje({required String pasajeroId, required String pasajeroCuenta}) async {
    state = state.copyWith(isLoading: true);
    try {
      final propietario = state.conductorData?['propietario'] as Map<String, dynamic>? ?? {};
      final servicio = state.conductorData?['servicio'] as Map<String, dynamic>? ?? {};
      final tag = state.conductorData?['tag'] as Map<String, dynamic>? ?? {};

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
        montoTotal: state.totalAPagar,
        detalle: state.selectedPasajes.map((p) => PagoDetalleEntity(tipoPago: p.codigo ?? '')).toList(),
      );

      final requestDomain = PasajePrepareRequest(
        tramite: tramite,
        servicio: servicioEntity,
        tag: tagEntity,
        usuario: usuarioEntity,
        pago: pagoEntity,
        glosa: 'Pago Pasaje',
      );

      final response = await _prepareUsecase.call(requestDomain);
      _lastPrepareResponse = response;
      return response;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<PasajePrepareResponse> registerPasaje({required String codigoOtp, required String pasajeroId, required String pasajeroCuenta}) async {
    state = state.copyWith(isLoading: true);
    try {
      final propietario = state.conductorData?['propietario'] as Map<String, dynamic>? ?? {};
      final servicio = state.conductorData?['servicio'] as Map<String, dynamic>? ?? {};
      final tag = state.conductorData?['tag'] as Map<String, dynamic>? ?? {};
      final last = _lastPrepareResponse;
      if (last == null) {
        throw Exception('No existe un prepare previo para registrar.');
      }

      final tramiteEntity = TramiteEntity(
        tramiteId: last.data?.idTramite ?? '',
        numeroAutorizacion: last.data?.numeroAutorizacion ?? '',
        codigoOtp: codigoOtp,
      );
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
        montoTotal: state.totalAPagar,
        detalle: state.selectedPasajes.map((p) => PagoDetalleEntity(tipoPago: p.codigo ?? '')).toList(),
      );

      final registerReq = PasajePrepareRequest(
        tramite: tramiteEntity,
        servicio: servicioEntity,
        tag: tagEntity,
        usuario: usuarioEntity,
        pago: pagoEntity,
        glosa: 'Pago Pasaje',
      );

      final resp = await _registerUsecase.call(registerReq);
      if (resp.continuarFlujo) {
        await _saveHistoryIfSuccess(nombre: servicio['nombre'] ?? 'Servicio Desconocido');
        clearPasajes();
      }
      return resp;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveHistoryIfSuccess({required String nombre}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> historialJson = prefs.getStringList('historial') ?? [];
      final String timestamp = DateTime.now().toIso8601String();

      final nuevosItemsJson = state.selectedPasajes.map((pasaje) {
        final Map<String, dynamic> transaccion = {
          'type': nombre,
          'timestamp': timestamp,
          'nombre': pasaje.nombre,
          'precio': pasaje.precio,
        };
        return json.encode(transaccion);
      }).toList();

      historialJson.addAll(nuevosItemsJson);
      await prefs.setStringList('historial', historialJson);
    } catch (e) {
      print('Error guardando historial: $e');
    }
  }
}

final paymentProvider =
    NotifierProvider.family<
      PaymentNotifier,
      PaymentState,
      Map<String, dynamic>
    >(PaymentNotifier.new);
