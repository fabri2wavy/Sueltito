import '../../domain/entities/pasaje_prepare_request.dart';

class TramiteModel {
  final String tramiteId;
  final String numeroAutorizacion;
  final String codigoOtp;

  TramiteModel({required this.tramiteId, required this.numeroAutorizacion, required this.codigoOtp});
  Map<String, dynamic> toJson() => {
    'tramite_id': tramiteId,
    'numero_autorizacion': numeroAutorizacion,
    'codigo_otp': codigoOtp,
  };
}

class ServicioModel {
  final String tipo;
  final String nombre;
  final String tipoIdentificador;
  final String identificador;
  final String codigoEntidad;

  ServicioModel({required this.tipo, required this.nombre, required this.tipoIdentificador, required this.identificador, required this.codigoEntidad});
  Map<String, dynamic> toJson() => {
    'tipo': tipo,
    'nombre': nombre,
    'tipo_identificador': tipoIdentificador,
    'identificador': identificador,
    'codigo_entidad': codigoEntidad,
  };
}

class TagModel {
  final String identificador;
  TagModel({required this.identificador});
  Map<String, dynamic> toJson() => { 'identificador': identificador };
}

class UsuarioPagoModel {
  final String pasajeroId;
  final String conductorId;
  final String pasajeroCuenta;
  final String conductorCuenta;

  UsuarioPagoModel({required this.pasajeroId, required this.conductorId, required this.pasajeroCuenta, required this.conductorCuenta});
  Map<String, dynamic> toJson() => {
    'pasajero_id': pasajeroId,
    'conductor_id': conductorId,
    'pasajero_cuenta': pasajeroCuenta,
    'conductor_cuenta': conductorCuenta,
  };
}

class PagoDetalleModel {
  final String tipoPago;
  PagoDetalleModel({required this.tipoPago});
  Map<String, dynamic> toJson() => {'tipo_pago': tipoPago};
}

class PagoModel {
  final String tipoTransporte;
  final String formaPago;
  final double montoTotal;
  final List<PagoDetalleModel> detalle;

  PagoModel({required this.tipoTransporte, required this.formaPago, required this.montoTotal, required this.detalle});
  Map<String, dynamic> toJson() => {
    'tipo_transporte': tipoTransporte,
    'forma_pago': formaPago,
    'monto_total': montoTotal,
    'detalle': detalle.map((d) => d.toJson()).toList(),
  };
}

class PasajePrepareRequestModel {
  final TramiteModel tramite;
  final ServicioModel servicio;
  final TagModel tag;
  final UsuarioPagoModel usuario;
  final PagoModel pago;
  final String glosa;

  PasajePrepareRequestModel({required this.tramite, required this.servicio, required this.tag, required this.usuario, required this.pago, required this.glosa});

  factory PasajePrepareRequestModel.fromEntity(PasajePrepareRequest e) {
    return PasajePrepareRequestModel(
      tramite: TramiteModel(tramiteId: e.tramite.tramiteId, numeroAutorizacion: e.tramite.numeroAutorizacion, codigoOtp: e.tramite.codigoOtp),
      servicio: ServicioModel(tipo: e.servicio.tipo, nombre: e.servicio.nombre, tipoIdentificador: e.servicio.tipoIdentificador, identificador: e.servicio.identificador, codigoEntidad: e.servicio.codigoEntidad),
      tag: TagModel(identificador: e.tag.identificador),
      usuario: UsuarioPagoModel(pasajeroId: e.usuario.pasajeroId, conductorId: e.usuario.conductorId, pasajeroCuenta: e.usuario.pasajeroCuenta, conductorCuenta: e.usuario.conductorCuenta),
      pago: PagoModel(tipoTransporte: e.pago.tipoTransporte, formaPago: e.pago.formaPago, montoTotal: e.pago.montoTotal, detalle: e.pago.detalle.map((d) => PagoDetalleModel(tipoPago: d.tipoPago)).toList()),
      glosa: e.glosa,
    );
  }

  Map<String, dynamic> toJson() => {
    'tramite': tramite.toJson(),
    'servicio': servicio.toJson(),
    'tag': tag.toJson(),
    'usuario': usuario.toJson(),
    'pago': pago.toJson(),
    'glosa': glosa,
  };
}
