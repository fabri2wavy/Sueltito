import '../../domain/entities/profile_change_response.dart';
import 'profile_change_model.dart';

class ProfileChangeResponseModel extends ProfileChangeResponse {
  ProfileChangeResponseModel({
    required super.continuarFlujo,
    required super.profileChange,
    super.message,
  });

  factory ProfileChangeResponseModel.fromJson(Map<String, dynamic> json) {
    final perfilList = json['perfil'] as List<dynamic>?;
    final perfilJson = perfilList != null && perfilList.isNotEmpty
        ? perfilList.first as Map<String, dynamic>
        : <String, dynamic>{};

    return ProfileChangeResponseModel(
      continuarFlujo: json['continuar_flujo'] ?? false,
      message: json['message'],
      profileChange: ProfileChangeModel.fromJson(perfilJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'continuar_flujo': continuarFlujo,
      'message': message,
      'perfil': [(profileChange as ProfileChangeModel).toJson()],
    };
  }

  ProfileChangeResponse toEntity() {
    return ProfileChangeResponse(
      continuarFlujo: continuarFlujo,
      message: message,
      profileChange: (profileChange as ProfileChangeModel).toEntity(),
    );
  }

  factory ProfileChangeResponseModel.fromEntity(ProfileChangeResponse entity) {
    return ProfileChangeResponseModel(
      continuarFlujo: entity.continuarFlujo,
      message: entity.message,
      profileChange: ProfileChangeModel.fromEntity(entity.profileChange),
    );
  }
}
