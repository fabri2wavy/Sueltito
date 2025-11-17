import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NfcScanPage extends StatefulWidget {
  const NfcScanPage({super.key});

  @override
  State<NfcScanPage> createState() => _NfcScanPageState();
}

class _NfcScanPageState extends State<NfcScanPage>
    with SingleTickerProviderStateMixin {
  
  // --- 1. ¡LA SOLUCIÓN AL AUTO-ESCANEO! ---
  // Una variable 'static' NUNCA se reinicia, aunque la página se destruya
  // y se vuelva a crear.
  static bool _autoScanPerformed = false;
  // --- FIN DE LA SOLUCIÓN ---

  bool scanning = false;
  bool success = false;
  String message = "Acerca el celular al punto de pago";

  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  List<Map<String, dynamic>> _ultimasTransacciones = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _cargarHistorial();

    // --- 2. LÓGICA DE INICIO MODIFICADA ---
    if (!_autoScanPerformed) {
      // Si es la primera vez, inicia el escaneo automático
      Future.delayed(const Duration(milliseconds: 300), _startScan);
      _autoScanPerformed = true; // Y marca que ya lo hiciste
    } else {
      // Si ya NO es la primera vez, asegúrate de que la UI
      // esté en modo de reposo (mostrando "Acerca el celular...")
      setState(() {
        scanning = false;
        message = "Acerca el celular al punto de pago";
      });
    }
    // --- FIN DE LA MODIFICACIÓN ---
  }

  Future<void> _cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historialJson = prefs.getStringList('historial') ?? [];
    final List<Map<String, dynamic>> transacciones = historialJson.map((itemString) {
      try {
        return json.decode(itemString) as Map<String, dynamic>;
      } catch (e) {
        return <String, dynamic>{}; // Devuelve mapa vacío si hay error
      }
    }).where((map) => map.isNotEmpty).toList(); // Filtra mapas vacíos

    transacciones.sort((a, b) {
      return (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? '');
    });

    setState(() {
      _ultimasTransacciones = transacciones.take(3).toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- 3. FUNCIÓN _startScan CON NAVEGACIÓN Y ERRORES CORREGIDOS ---
// (En tu archivo nfc_scan_page.dart)

Future<void> _startScan() async {
  _cargarHistorial();

  if (scanning) return;
  setState(() {
    scanning = true;
    success = false;
    message = "Esperando tarjeta...";
  });

  try {
    NFCTag tag = await FlutterNfcKit.poll(timeout: const Duration(seconds: 20));

    // (Tu lógica de NDEF, records, y content está perfecta)
    if (tag.ndefAvailable != true) {
      throw Exception("La tarjeta no contiene datos válidos");
    }
    List<dynamic> records =
        await FlutterNfcKit.readNDEFRecords(cached: false);
    if (records.isEmpty) {
      throw Exception("El tag está vacío");
    }
    final rec = records.first;
    String content;
    if (rec.payload is String) {
      content = rec.payload;
    } else if (rec.payload is List<int>) {
      content = utf8.decode(rec.payload);
    } else {
      content = rec.payload.toString();
    }
    final data = json.decode(content);

    // --- ¡AQUÍ ESTÁ LA ACTUALIZACIÓN BASADA EN TU IMAGEN! ---
    
    final String? tipoTransporte = data['servicio']?['tipo_transporte'];
    String? rutaDestino;

    switch (tipoTransporte) {
      case '01': // <-- Código 01 = MINIBUS
        rutaDestino = '/minibus_payment';
        break;
      case '02': // <-- Código 02 = TRUFI
        rutaDestino = '/trufis_payment';
        break;
      case '03': // <-- Código 03 = TAXI
        rutaDestino = '/taxi_payment';
        break;
      default:
        // Si el código es "04" (o cualquier otro), es un error
        throw Exception("Tag de transporte no reconocido");
    }
    // --- FIN DE LA ACTUALIZACIÓN ---

    // (Tu lógica de éxito visual está perfecta)
    setState(() { success = true; message = "Lectura correcta"; });
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 650));
    await FlutterNfcKit.finish();
    if (!mounted) return;

    // (Tu lógica de navegación "await pushNamed" está perfecta)
    await Navigator.pushNamed(
      context,
      rutaDestino,
      arguments: data,
    );

    // (Tu lógica de reseteo de UI está perfecta)
    setState(() {
      scanning = false;
      success = false;
      message = "Acerca el celular al punto de pago";
    });

  } catch (e) {
    // (Tu lógica de 'catch' está perfecta)
    String errorMessage;
    if (e is PlatformException && e.code == '408') {
      errorMessage = "Tiempo de espera agotado. Intenta de nuevo.";
    } else if (e is Exception) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    } else {
      errorMessage = "Error desconocido. Intenta de nuevo.";
    }
    setState(() {
      message = errorMessage;
      scanning = false;
    });
    try {
      await FlutterNfcKit.finish();
    } catch (_) {}
  }
}

  Widget _buildIconArea() {
    // (Tu función está perfecta, se queda igual)
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350), 
      child: success
          ? Icon(
              Icons.check_circle_rounded,
              key: const ValueKey('tick'),
              size: 130,
              color: Colors.green,
            )
          : scanning
              ? SizedBox(
                  key: const ValueKey('loader'),
                  width: 140,
                  height: 140,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    ),
                  ),
                )
              : ScaleTransition(
                  key: const ValueKey('icon'),
                  scale: _pulseAnimation,
                  child: Container(
                    width: 140,
                    height: 140,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.nfc_rounded,
                      size: 84,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // (Tu build está perfecto, se queda igual)
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFD7EFE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textBlack),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Bienvenido!",
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconArea(),
                    const SizedBox(height: 18),
                    Text(
                      message, // Ahora muestra mensajes amigables
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.textBlack,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 34),
                    ElevatedButton(
                      onPressed: scanning ? null : _startScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.7),
                        minimumSize: const Size(180, 52),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: scanning
                            ? const Row(
                                key: ValueKey('scanning'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    "Escaneando...",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              )
                            : const Text(
                                "Reintentar",
                                key: ValueKey('retry'),
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: width * 0.88,
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      spreadRadius: 2)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Últimas Transacciones",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_ultimasTransacciones.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          "Aún no tienes transacciones.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._ultimasTransacciones.map((transaccion) {
                      final String tipo = (transaccion['type'] ?? '...').toUpperCase();
                      final String nombre = transaccion['nombre'] ?? 'Error';
                      final double precio = transaccion['precio'] ?? 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$tipo:\n$nombre",
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              "Bs ${precio.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}