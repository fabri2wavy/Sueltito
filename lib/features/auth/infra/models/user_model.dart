import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.nombre,
    required super.idEntPersona,
    required super.celular,
    required super.correo,
    required super.nroCuenta,
    required super.estado,
    required super.primerApellido,
    required super.segundoApellido,
    required super.nombreCompleto,
    required super.perfiles,
    required super.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final perfilesData = json['perfil'] as List<dynamic>? ?? [];
    final perfiles = perfilesData.map((item) => item.toString()).toList();

    final rolesData = json['roles'] as List<dynamic>? ?? [];
    final roles = rolesData.map((item) => item.toString()).toList();

    return UserModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      idEntPersona: json['id_ent_persona'] as String,
      celular: json['celular'] as String,
      correo: json['correo'] as String,
      nroCuenta: json['nro_cuenta'] as String,
      estado: json['estado'] as String,
      primerApellido: json['primer_apellido'] as String,
      segundoApellido: json['segundo_apellido'] as String,
      nombreCompleto: json['nombre_completo'] as String,
      perfiles: perfiles,
      roles: roles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'id_ent_persona': idEntPersona,
      'celular': celular,
      'correo': correo,
      'nro_cuenta': nroCuenta,
      'estado': estado,
      'primer_apellido': primerApellido,
      'segundo_apellido': segundoApellido,
      'nombre_completo': nombreCompleto,
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
      idEntPersona: idEntPersona,
      celular: celular,
      correo: correo,
      nroCuenta: nroCuenta,
      estado: estado,
      primerApellido: primerApellido,
      segundoApellido: segundoApellido,
      nombreCompleto: nombreCompleto,
    );
  }

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      nombre: entity.nombre,
      idEntPersona: entity.idEntPersona,
      celular: entity.celular,
      correo: entity.correo,
      nroCuenta: entity.nroCuenta,
      estado: entity.estado,
      primerApellido: entity.primerApellido,
      segundoApellido: entity.segundoApellido,
      nombreCompleto: entity.nombreCompleto,
      perfiles: entity.perfiles,
      roles: entity.roles,
    );
  }

  UserModel copyWith({
    String? id,
    String? nombre,
    String? idEntPersona,
    String? celular,
    String? correo,
    String? nroCuenta,
    String? estado,
    String? primerApellido,
    String? segundoApellido,
    String? nombreCompleto,
    List<String>? perfiles,
    List<String>? roles,
  }) {
    return UserModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      idEntPersona: idEntPersona ?? this.idEntPersona,
      celular: celular ?? this.celular,
      correo: correo ?? this.correo,
      nroCuenta: nroCuenta ?? this.nroCuenta,
      estado: estado ?? this.estado,
      primerApellido: primerApellido ?? this.primerApellido,
      segundoApellido: segundoApellido ?? this.segundoApellido,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      perfiles: perfiles ?? this.perfiles,
      roles: roles ?? this.roles,
    );
  }
}
