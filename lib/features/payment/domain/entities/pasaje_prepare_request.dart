class TramiteEntity {
  final String tramiteId;
  final String numeroAutorizacion;
  final String codigoOtp;

  TramiteEntity({required this.tramiteId, required this.numeroAutorizacion, required this.codigoOtp});
}

class ServicioEntity {
  final String tipo;
  final String nombre;
  final String tipoIdentificador;
  final String identificador;
  final String codigoEntidad;

  ServicioEntity({required this.tipo, required this.nombre, required this.tipoIdentificador, required this.identificador, required this.codigoEntidad});
}

class TagEntity {
  final String identificador;
  TagEntity({required this.identificador});
}

class UsuarioPagoEntity {
  final String pasajeroId;
  final String conductorId;
  final String pasajeroCuenta;
  final String conductorCuenta;

  UsuarioPagoEntity({required this.pasajeroId, required this.conductorId, required this.pasajeroCuenta, required this.conductorCuenta});
}

class PagoDetalleEntity {
  final String tipoPago;
  PagoDetalleEntity({required this.tipoPago});
}

class PagoEntity {
  final String tipoTransporte;
  final String formaPago;
  final double montoTotal;
  final List<PagoDetalleEntity> detalle;

  PagoEntity({required this.tipoTransporte, required this.formaPago, required this.montoTotal, required this.detalle});
}

class PasajePrepareRequest {
  final TramiteEntity tramite;
  final ServicioEntity servicio;
  final TagEntity tag;
  final UsuarioPagoEntity usuario;
  final PagoEntity pago;
  final String glosa;

  PasajePrepareRequest({required this.tramite, required this.servicio, required this.tag, required this.usuario, required this.pago, required this.glosa});
}
