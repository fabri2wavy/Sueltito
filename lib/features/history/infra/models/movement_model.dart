import '../../domain/entities/movement.dart';

class MovementModel extends Movement {
  MovementModel({
    required super.id,
    required super.tramo,
    required super.monto,
    required super.transporte,
    required super.fecha,
  });

  factory MovementModel.fromJson(Map<String, dynamic> json) {
    return MovementModel(
      id: json['id']?.toString() ?? '',
      // El JSON real usa "tramo" (ej: "CORTO")
      tramo: json['tramo']?.toString() ?? 'Sin tramo',
      // El JSON real usa "monto" como String (ej: "2.4")
      monto: double.tryParse(json['monto']?.toString() ?? '0') ?? 0.0,
      // El JSON real usa "transporte" (ej: "MINIBUS/CARRY")
      transporte: json['transporte']?.toString() ?? 'Transporte',
      // El JSON real usa "fecha" (ej: "2025-11-15T13:05:07.474Z")
      fecha: DateTime.tryParse(json['fecha']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}