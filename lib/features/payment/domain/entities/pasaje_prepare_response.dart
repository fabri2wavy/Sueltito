class PasajePrepareResponse {
  final bool continuarFlujo;
  final String mensaje;
  final PasajePrepareResponseData? data;

  PasajePrepareResponse({required this.continuarFlujo, required this.mensaje, required this.data});
}

class PasajePrepareResponseData {
  final String idTramite;
  final String idTramiteBanco;
  final String estadoTramite;
  final String numeroAutorizacion;

  PasajePrepareResponseData({required this.idTramite, required this.idTramiteBanco, required this.estadoTramite, required this.numeroAutorizacion});
}
