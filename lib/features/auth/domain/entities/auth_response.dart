import 'package:sueltito/features/auth/domain/entities/user.dart';

class AuthResponse {
  final bool continuarFlujo;
  final String? message;
  final User usuario;

  AuthResponse({
    required this.continuarFlujo,
    required this.usuario,
    this.message,
  });
}
