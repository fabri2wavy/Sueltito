import 'package:sueltito/features/auth/domain/entities/profile_change.dart';

class ProfileChangeResponse {
  final bool continuarFlujo;
  final String? message;
  final ProfileChange profileChange;

  ProfileChangeResponse({
    required this.continuarFlujo,
    required this.profileChange,
    this.message,
  });
}
