import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/register_request.dart';
import 'auth_provider.dart';

// Estado del formulario
class RegisterFormState {
  final String nombre;
  final String primerApellido;
  final String segundoApellido;
  final String ci;
  final DateTime? fechaNacimiento;
  final String celular;
  final String correo;

  RegisterFormState({
    this.nombre = '',
    this.primerApellido = '',
    this.segundoApellido = '',
    this.ci = '',
    this.fechaNacimiento,
    this.celular = '',
    this.correo = '',
  });

  RegisterFormState copyWith({
    String? nombre,
    String? primerApellido,
    String? segundoApellido,
    String? ci,
    DateTime? fechaNacimiento,
    String? celular,
    String? correo,
  }) {
    return RegisterFormState(
      nombre: nombre ?? this.nombre,
      primerApellido: primerApellido ?? this.primerApellido,
      segundoApellido: segundoApellido ?? this.segundoApellido,
      ci: ci ?? this.ci,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      celular: celular ?? this.celular,
      correo: correo ?? this.correo,
    );
  }

  bool get isValid {
    return nombre.isNotEmpty &&
        primerApellido.isNotEmpty &&
        ci.isNotEmpty &&
        fechaNacimiento != null &&
        celular.isNotEmpty &&
        correo.isNotEmpty;
  }
}

// ✅ Notifier (Riverpod 2.0+)
class RegisterFormNotifier extends Notifier<RegisterFormState> {
  @override
  RegisterFormState build() {
    return RegisterFormState();
  }

  void updateNombre(String value) {
    state = state.copyWith(nombre: value);
  }

  void updatePrimerApellido(String value) {
    state = state.copyWith(primerApellido: value);
  }

  void updateSegundoApellido(String value) {
    state = state.copyWith(segundoApellido: value);
  }

  void updateCI(String value) {
    state = state.copyWith(ci: value);
  }

  void updateFechaNacimiento(DateTime value) {
    state = state.copyWith(fechaNacimiento: value);
  }

  void updateCelular(String value) {
    state = state.copyWith(celular: value);
  }

  void updateCorreo(String value) {
    state = state.copyWith(correo: value);
  }

  void reset() {
    state = RegisterFormState();
  }

  // ✅ Obtener información del dispositivo
  Future<Map<String, dynamic>> _getDeviceInfo(BuildContext context) async {
    final deviceInfo = DeviceInfoPlugin();
    
    String sistemaOperativo = '';
    String version = '';
    String marca = '';
    String modelo = '';
    String identificador = '';
    String imei = '';
    String bluetooth = '';
    double lat = 0.0;
    double lon = 0.0;
    String dimension = '';

    // Solicitar permisos de ubicación
    try {
      final locStatus = await Permission.location.request();
      if (!locStatus.isGranted) {
        // No interrumpimos: enviamos vacío
      }
    } catch (_) {}

    // Solicitar permisos de bluetooth
    try {
      await Permission.bluetooth.request();
    } catch (_) {}

    // Obtener info del dispositivo según plataforma
    try {
      if (Platform.isAndroid) {
        sistemaOperativo = 'Android';
        final info = await deviceInfo.androidInfo;
        version = info.version.release ?? '';
        marca = info.brand ?? '';
        modelo = info.model ?? '';
        identificador = 'android_${info.version.sdkInt}';
        
        try {
          // androidId como alternativa a IMEI
          final aid = info.id;
          if (aid.isNotEmpty) {
            imei = aid;
          }
        } catch (_) {}
        
        bluetooth = 'BT-Android-${info.id}';
      } else if (Platform.isIOS) {
        sistemaOperativo = 'iOS';
        final info = await deviceInfo.iosInfo;
        version = info.systemVersion;
        marca = 'Apple';
        modelo = info.utsname.machine;
        identificador = 'ios_${info.systemVersion}';
        
        try {
          // identifierForVendor como alternativa a IMEI
          final idfv = info.identifierForVendor;
          if (idfv != null && idfv.isNotEmpty) {
            imei = idfv;
          }
        } catch (_) {}
        
        bluetooth = 'BT-iOS-${info.identifierForVendor ?? "unknown"}';
      }
    } catch (e) {
      print('[DEBUG] Error obteniendo info del dispositivo: $e');
    }

    // Geolocalización
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = pos.latitude;
        lon = pos.longitude;
      }
    } catch (e) {
      print('[DEBUG] Error obteniendo ubicación: $e');
    }

    // Dimensiones de pantalla
    try {
      final mq = MediaQuery.of(context);
      dimension = "${mq.size.width.toStringAsFixed(0)}x${mq.size.height.toStringAsFixed(0)} px";
    } catch (_) {
      dimension = '';
    }

    return {
      'sistemaOperativo': sistemaOperativo,
      'version': version,
      'marca': marca,
      'modelo': modelo,
      'identificador': identificador,
      'imei': imei,
      'bluetooth': bluetooth,
      'latitud': lat.toString(),
      'longitud': lon.toString(),
      'dimension': dimension,
    };
  }

  // ✅ Acción de registro con info del dispositivo
  Future<void> submitRegister(BuildContext context) async {
    if (!state.isValid) {
      throw Exception('Por favor completa todos los campos requeridos');
    }

    // Obtener info del dispositivo
    final deviceData = await _getDeviceInfo(context);

    final request = RegisterRequest(
      nombre: state.nombre,
      primerApellido: state.primerApellido,
      segundoApellido: state.segundoApellido,
      nroDocumento: state.ci,
      tipoDocumento: 'CI',
      fechaNacimiento: state.fechaNacimiento.toString(),
      celular: state.celular,
      correo: state.correo,
      nroCuenta: state.celular, // TODO: Asignar nroCuenta real
      // Device info obtenido dinámicamente
      numeroBluetooth: deviceData['bluetooth'] ?? '',
      numeroImei: deviceData['imei'] ?? '',
      sistemaOperativo: deviceData['sistemaOperativo'] ?? '',
      identificadorSistemaOperativo: deviceData['identificador'] ?? '',
      versionSistemaOperativo: deviceData['version'] ?? '',
      marca: deviceData['marca'] ?? '',
      modelo: deviceData['modelo'] ?? '',
      tipoDispositivo: 'mobile',
      dimensionPantalla: deviceData['dimension'] ?? '',
      latitud: deviceData['latitud'] ?? '0.0',
      longitud: deviceData['longitud'] ?? '0.0',
    );

    await ref.read(authProvider.notifier).register(request);
  }
}

// ✅ NotifierProvider (Riverpod 2.0+)
final registerFormProvider = NotifierProvider<RegisterFormNotifier, RegisterFormState>(
  RegisterFormNotifier.new,
);