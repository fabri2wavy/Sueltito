class User {
  final String id;
  final String nombre;
  final List<String> perfiles;
  final List<String> roles;

  User({
    required this.id,
    required this.nombre,
    required this.perfiles,
    required this.roles,
  });

  bool get esPasajero => perfiles.contains('PASAJERO');
  bool get esConductor => perfiles.contains('CHOFER');
  
  String? get perfilActual => perfiles.isNotEmpty ? perfiles.first : null;
  
}