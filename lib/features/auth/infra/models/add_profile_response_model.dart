import '../../domain/entities/add_profile_response.dart';
import '../../domain/entities/perfil_item.dart';

class AddProfileResponseModel extends AddProfileResponse {
  AddProfileResponseModel({required super.tramite, required super.perfil});

  factory AddProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final perfilList = (json['data']?['perfil'] as List<dynamic>?) ?? [];

    final perfilItems = perfilList.map((item) {
      final map = item as Map<String, dynamic>;
      return PerfilItem(
        perfil: map['perfil'] ?? '',
        codEnpRol: map['cod_enp_rol'] ?? '',
        descripcion: map['descripcion'] ?? '',
      );
    }).toList();

    return AddProfileResponseModel(
      tramite: json['data']?['tramite'] ?? '',
      perfil: perfilItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'tramite': tramite,
        'perfil': perfil.map((p) => {
          'perfil': p.perfil,
          'cod_enp_rol': p.codEnpRol,
          'descripcion': p.descripcion,
        }).toList(),
      }
    };
  }

  AddProfileResponse toEntity() {
    return AddProfileResponse(tramite: tramite, perfil: perfil);
  }

  factory AddProfileResponseModel.fromEntity(AddProfileResponse entity) {
    return AddProfileResponseModel(tramite: entity.tramite, perfil: entity.perfil);
  }
}
