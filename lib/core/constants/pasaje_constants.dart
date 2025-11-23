class PasajeInfo {
  final String codigo;
  final String nombre;
  final double tarifa;
  final String tipoTransporte;

  const PasajeInfo({
    required this.codigo,
    required this.nombre,
    required this.tarifa,
    required this.tipoTransporte,
  });
}

class PasajeConstants {
  static const Map<String, PasajeInfo> PAP_PASAJES = {
    '000001': PasajeInfo(codigo: '000001', nombre: 'Tramo Corto', tarifa: 2.40, tipoTransporte: '01'),
    '000002': PasajeInfo(codigo: '000002', nombre: 'Tramo Largo', tarifa: 3.00, tipoTransporte: '01'),
    '000003': PasajeInfo(codigo: '000003', nombre: 'Tramo Corto (Noche)', tarifa: 2.50, tipoTransporte: '01'),
    '000004': PasajeInfo(codigo: '000004', nombre: 'Tramo Largo (Noche)', tarifa: 3.20, tipoTransporte: '01'),
    '000005': PasajeInfo(codigo: '000005', nombre: 'Tramo Corto (Preferencial)', tarifa: 2.00, tipoTransporte: '01'),
    '000006': PasajeInfo(codigo: '000006', nombre: 'Tramo Largo (Preferencial)', tarifa: 2.60, tipoTransporte: '01'),
    '000007': PasajeInfo(codigo: '000007', nombre: 'Zonal', tarifa: 2.50, tipoTransporte: '02'),
    '000008': PasajeInfo(codigo: '000008', nombre: 'Corto', tarifa: 2.80, tipoTransporte: '02'),
    '000009': PasajeInfo(codigo: '000009', nombre: 'Largo', tarifa: 3.30, tipoTransporte: '02'),
    '000010': PasajeInfo(codigo: '000010', nombre: 'Extra Largo', tarifa: 3.50, tipoTransporte: '02'),
    '000011': PasajeInfo(codigo: '000011', nombre: 'Zonal (Noche)', tarifa: 3.00, tipoTransporte: '02'),
    '000012': PasajeInfo(codigo: '000012', nombre: 'Corto (Noche)', tarifa: 3.30, tipoTransporte: '02'),
    '000013': PasajeInfo(codigo: '000013', nombre: 'Largo (Noche)', tarifa: 3.50, tipoTransporte: '02'),
    '000014': PasajeInfo(codigo: '000014', nombre: 'Extra Largo (Noche)', tarifa: 4.00, tipoTransporte: '02'),
    '000015': PasajeInfo(codigo: '000015', nombre: 'Zonal (Preferencial)', tarifa: 2.00, tipoTransporte: '02'),
    '000016': PasajeInfo(codigo: '000016', nombre: 'Corto (Preferencial)', tarifa: 2.50, tipoTransporte: '02'),
    '000017': PasajeInfo(codigo: '000017', nombre: 'Largo (Preferencial)', tarifa: 3.00, tipoTransporte: '02'),
    '000018': PasajeInfo(codigo: '000018', nombre: 'Extra Largo (Preferencial)', tarifa: 3.50, tipoTransporte: '02'),
    '000019': PasajeInfo(codigo: '000019', nombre: 'Trufi Zonal (día)', tarifa: 2.00, tipoTransporte: '04'),
    '000020': PasajeInfo(codigo: '000020', nombre: 'Trufi Zonal (noche)', tarifa: 2.50, tipoTransporte: '04'),
    '000021': PasajeInfo(codigo: '000021', nombre: 'Taxi (dinámico)', tarifa: 0.0, tipoTransporte: '03'),
  };

  static List<PasajeInfo> minibusOptions({bool preferencial = false}) => [
        preferencial ? PAP_PASAJES['000005']! : PAP_PASAJES['000001']!,
        preferencial ? PAP_PASAJES['000006']! : PAP_PASAJES['000002']!,
      ];

  static List<PasajeInfo> trufiOptions({bool preferencial = false}) => [
        preferencial ? PAP_PASAJES['000015']! : PAP_PASAJES['000007']!,
        preferencial ? PAP_PASAJES['000016']! : PAP_PASAJES['000008']!,
        preferencial ? PAP_PASAJES['000017']! : PAP_PASAJES['000009']!,
        preferencial ? PAP_PASAJES['000018']! : PAP_PASAJES['000010']!,
      ];

  static PasajeInfo taxiOption() => PAP_PASAJES['000021']!;
}
