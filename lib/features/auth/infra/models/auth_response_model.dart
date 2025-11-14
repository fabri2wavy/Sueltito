import '../../domain/entities/auth_response.dart';
import 'user_model.dart';

class AuthResponseModel extends AuthResponse {
  AuthResponseModel({
    required super.continuarFlujo,
    required super.usuario,
    super.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      continuarFlujo: json['continuar_flujo'] as bool? ?? false,
      message: json['message'] as String?,
      usuario: UserModel.fromJson(
        json['usuario'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final userModel = usuario as UserModel;
    return {
      'continuar_flujo': continuarFlujo,
      'message': message,
      'usuario': userModel.toJson(),
    };
  }

  AuthResponse toEntity() {
    final userModel = usuario as UserModel;
    return AuthResponse(
      continuarFlujo: continuarFlujo,
      message: message,
      usuario: userModel.toEntity(),
    );
  }

  factory AuthResponseModel.fromEntity(AuthResponse entity) {
    return AuthResponseModel(
      continuarFlujo: entity.continuarFlujo,
      message: entity.message,
      usuario: UserModel.fromEntity(entity.usuario),
    );
  }
}