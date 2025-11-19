class RegisterRequest {
  final String nombre;
  final String primerApellido;
  final String? segundoApellido;
  final String nroDocumento;
  final String tipoDocumento;
  final String fechaNacimiento;
  final String celular;
  final String nroCuenta;
  final String correo;
  final String numeroBluetooth;
  final String numeroImei;
  final String sistemaOperativo;
  final String identificadorSistemaOperativo;
  final String versionSistemaOperativo;
  final String marca;
  final String modelo;
  final String tipoDispositivo;
  final String dimensionPantalla;
  final String latitud;
  final String longitud;
  final bool remember;

  RegisterRequest({
    required this.nombre,
    required this.primerApellido,
    this.segundoApellido,
    required this.nroDocumento,
    required this.tipoDocumento,
    required this.fechaNacimiento,
    required this.celular,
    required this.nroCuenta,
    required this.correo,
    required this.numeroBluetooth,
    required this.numeroImei,
    required this.sistemaOperativo,
    required this.identificadorSistemaOperativo,
    required this.versionSistemaOperativo,
    required this.marca,
    required this.modelo,
    required this.tipoDispositivo,
    required this.dimensionPantalla,
    required this.latitud,
    required this.longitud,
    this.remember = false, 
  });
}