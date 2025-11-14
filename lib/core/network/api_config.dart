import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // ✅ Leer desde .env con fallback
  static String get baseUrl => 
      dotenv.env['API_BASE_URL'] ?? 'https://backend-sueltito.onrender.com/api';
  
  static Duration get connectTimeout => Duration(
    milliseconds: int.tryParse(dotenv.env['CONNECT_TIMEOUT'] ?? '10000') ?? 10000,
  );
  
  static Duration get receiveTimeout => Duration(
    milliseconds: int.tryParse(dotenv.env['RECEIVE_TIMEOUT'] ?? '10000') ?? 10000,
  );
}
