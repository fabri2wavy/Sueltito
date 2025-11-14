import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.nombre,
    required super.perfiles,
    required super.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final perfilesData = json['perfil'] as List<dynamic>? ?? [];
    final perfiles = perfilesData.map((item) => item.toString()).toList();

    final rolesData = json['roles'] as List<dynamic>? ?? [];
    final roles = rolesData.map((item) => item.toString()).toList();

    return UserModel(
      id: json['id_ent_usuario'] as String,
      nombre: json['nombre'] as String,
      perfiles: perfiles,
      roles: roles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ent_usuario': id,
      'nombre': nombre,
      'perfil': perfiles, 
      'roles': roles, 
    };
  }

  User toEntity() {
    return User(
      id: id,
      nombre: nombre,
      perfiles: perfiles,
      roles: roles,
    );
  }

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      nombre: entity.nombre,
      perfiles: entity.perfiles,
      roles: entity.roles,
    );
  }
}
