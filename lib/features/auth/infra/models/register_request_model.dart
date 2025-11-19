import '../../domain/entities/register_request.dart';

class RegisterRequestModel extends RegisterRequest {
  RegisterRequestModel({
    required super.nombre,
    required super.primerApellido,
    super.segundoApellido,
    required super.nroDocumento,
    required super.tipoDocumento,
    required super.fechaNacimiento,
    required super.celular,
    required super.nroCuenta,
    required super.correo,
    required super.numeroBluetooth,
    required super.numeroImei,
    required super.sistemaOperativo,
    required super.identificadorSistemaOperativo,
    required super.versionSistemaOperativo,
    required super.marca,
    required super.modelo,
    required super.tipoDispositivo,
    required super.dimensionPantalla,
    required super.latitud,
    required super.longitud,
    super.remember,
  });

  // ✅ Factory para convertir entity a model
  factory RegisterRequestModel.fromEntity(RegisterRequest entity) {
    return RegisterRequestModel(
      nombre: entity.nombre,
      primerApellido: entity.primerApellido,
      segundoApellido: entity.segundoApellido,
      nroDocumento: entity.nroDocumento,
      tipoDocumento: entity.tipoDocumento,
      fechaNacimiento: entity.fechaNacimiento,
      celular: entity.celular,
      nroCuenta: entity.nroCuenta,
      correo: entity.correo,
      numeroBluetooth: entity.numeroBluetooth,
      numeroImei: entity.numeroImei,
      sistemaOperativo: entity.sistemaOperativo,
      identificadorSistemaOperativo: entity.identificadorSistemaOperativo,
      versionSistemaOperativo: entity.versionSistemaOperativo,
      marca: entity.marca,
      modelo: entity.modelo,
      tipoDispositivo: entity.tipoDispositivo,
      dimensionPantalla: entity.dimensionPantalla,
      latitud: entity.latitud,
      longitud: entity.longitud,
      remember: entity.remember,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'primer_apellido': primerApellido,
      if (segundoApellido != null) 'segundo_apellido': segundoApellido,
      'nro_documento': nroDocumento,
      'tipo_documento': tipoDocumento,
      'fecha_nacimiento': fechaNacimiento, 
      'celular': celular,
      'nro_cuenta': nroCuenta,
      'correo': correo,
      'numero_bluetooth': numeroBluetooth,
      'numero_imei': numeroImei,
      'sistema_operativo': sistemaOperativo,
      'identificador_sistema_operativo': identificadorSistemaOperativo,
      'version_sistema_operativo': versionSistemaOperativo,
      'marca': marca,
      'modelo': modelo,
      'tipo_dispositivo': tipoDispositivo,
      'dimension_pantalla': dimensionPantalla,
      'latitud': latitud,
      'longitud': longitud,
    };
  }
}
