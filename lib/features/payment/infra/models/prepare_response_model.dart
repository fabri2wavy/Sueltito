import '../../domain/entities/pasaje_prepare_response.dart';

class PasajePrepareResponseModel {
  final bool continuarFlujo;
  final String mensaje;
  final PasajePrepareResponseDataModel? data;

  PasajePrepareResponseModel({required this.continuarFlujo, required this.mensaje, required this.data});

  factory PasajePrepareResponseModel.fromJson(Map<String, dynamic> json) {
    return PasajePrepareResponseModel(
      continuarFlujo: json['continuar_flujo'] ?? false,
      mensaje: json['mensaje'] ?? '',
      data: json['data'] != null ? PasajePrepareResponseDataModel.fromJson(json['data']) : null,
    );
  }

  PasajePrepareResponse toEntity() {
    return PasajePrepareResponse(
      continuarFlujo: continuarFlujo,
      mensaje: mensaje,
      data: data?.toEntity(),
    );
  }
}

class PasajePrepareResponseDataModel {
  final String idTramite;
  final String idTramiteBanco;
  final String estadoTramite;
  final String numeroAutorizacion;

  PasajePrepareResponseDataModel({required this.idTramite, required this.idTramiteBanco, required this.estadoTramite, required this.numeroAutorizacion});

  factory PasajePrepareResponseDataModel.fromJson(Map<String, dynamic> json) {
    return PasajePrepareResponseDataModel(
      idTramite: json['id_tramite'] ?? '',
      idTramiteBanco: json['id_tramite_banco'] ?? '',
      estadoTramite: json['estado_tramite'] ?? '',
      numeroAutorizacion: json['numero_autorizacion'] ?? '',
    );
  }

  PasajePrepareResponseData toEntity() {
    return PasajePrepareResponseData(
      idTramite: idTramite,
      idTramiteBanco: idTramiteBanco,
      estadoTramite: estadoTramite,
      numeroAutorizacion: numeroAutorizacion,
    );
  }
}
