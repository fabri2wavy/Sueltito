import '../../domain/entities/profile_change.dart';

class ProfileChangeModel extends ProfileChange {
  ProfileChangeModel({
    required super.mensaje,
    required super.nuevoPerfil,
    required super.anteriorPerfil,
  });

  factory ProfileChangeModel.fromJson(Map<String, dynamic> json) {
    return ProfileChangeModel(
      mensaje: json['mensaje'] ?? '',
      nuevoPerfil: json['nuevo_perfil'] ?? '',
      anteriorPerfil: json['anterior_perfil'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mensaje': mensaje,
      'nuevo_perfil': nuevoPerfil,
      'anterior_perfil': anteriorPerfil,
    };
  }

  ProfileChange toEntity() {
    return ProfileChange(
      mensaje: mensaje,
      nuevoPerfil: nuevoPerfil,
      anteriorPerfil: anteriorPerfil,
    );
  }

  factory ProfileChangeModel.fromEntity(ProfileChange entity) {
    return ProfileChangeModel(
      mensaje: entity.mensaje,
      nuevoPerfil: entity.nuevoPerfil,
      anteriorPerfil: entity.anteriorPerfil,
    );
  }
}
