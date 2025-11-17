import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:sueltito/core/config/app_theme.dart';
// --- NUEVO: Import para guardar historial ---
import 'package:shared_preferences/shared_preferences.dart';
// --- FIN NUEVO ---

class NfcScanPage extends StatefulWidget {
  const NfcScanPage({super.key});

  @override
  State<NfcScanPage> createState() => _NfcScanPageState();
}

class _NfcScanPageState extends State<NfcScanPage>
    with SingleTickerProviderStateMixin {
  bool scanning = false;
  bool success = false;
  String message = "Acerca el celular al punto de pago";

  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  // --- NUEVO: Variable para el historial ---
  List<Map<String, dynamic>> _ultimasTransacciones = [];
  // --- FIN NUEVO ---

  @override
  void initState() {
    super.initState();

    // Animación del pulso del icono
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // --- NUEVO: Cargar historial al iniciar ---
    _cargarHistorial();
    // --- FIN NUEVO ---

    // auto-start scan breve después de build
    Future.delayed(const Duration(milliseconds: 300), _startScan);
  }

  // --- NUEVO: Función para cargar historial ---
  Future<void> _cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Leemos la lista de JSONs en String
    final List<String> historialJson = prefs.getStringList('historial') ?? [];
    
    // 2. Decodificamos cada String a un Mapa (JSON)
    final List<Map<String, dynamic>> transacciones = historialJson.map((itemString) {
      return json.decode(itemString) as Map<String, dynamic>;
    }).toList();

    // 3. Ordenamos la lista completa por fecha (de más nuevo a más viejo)
    transacciones.sort((a, b) {
      return b['timestamp'].compareTo(a['timestamp']);
    });

    // 4. Guardamos en el estado SOLO LAS ÚLTIMAS 3
    setState(() {
      _ultimasTransacciones = transacciones.take(3).toList();
    });
  }
  // --- FIN NUEVO ---

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- MODIFICADO: Función de escaneo con "Enrutador Inteligente" ---
  Future<void> _startScan() async {
    // Al (re)intentar, volvemos a cargar el historial por si acaso
    _cargarHistorial();

    if (scanning) return;
    setState(() {
      scanning = true;
      success = false;
      message = "Esperando tarjeta...";
    });

    try {
      NFCTag tag = await FlutterNfcKit.poll(timeout: const Duration(seconds: 20));

      if (tag.ndefAvailable != true) {
        setState(() {
          message = "La tarjeta no contiene datos válidos";
          scanning = false;
        });
        await FlutterNfcKit.finish();
        return;
      }

      List<dynamic> records =
          await FlutterNfcKit.readNDEFRecords(cached: false);

      if (records.isEmpty) {
        setState(() {
          message = "El tag está vacío";
          scanning = false;
        });
        await FlutterNfcKit.finish();
        return;
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

      // --- INICIO DE LA LÓGICA DE ENRUTAMIENTO ---
      final String? tipoTransporte = data['servicio']?['tipo_transporte'];
      String? rutaDestino;

      // 2. Decidimos la ruta basada en el código
      switch (tipoTransporte) {
        case '04': // Trufi (basado en tu JSON)
          rutaDestino = '/trufis_payment';
          break;
        case '01': // (¡CONFIRMA ESTE CÓDIGO!)
          rutaDestino = '/minibus_payment';
          break;
        case '02': // (¡CONFIRMA ESTE CÓDIGO!)
          rutaDestino = '/taxi_payment';
          break;
        default:
          // El código no es reconocido
          setState(() {
            message = "Tag de transporte no reconocido";
            scanning = false;
          });
          await FlutterNfcKit.finish();
          return; // No navegamos
      }
      // --- FIN DE LA LÓGICA DE ENRUTAMIENTO ---

      setState(() {
        success = true;
        message = "Lectura correcta";
      });
      HapticFeedback.mediumImpact();

      await Future.delayed(const Duration(milliseconds: 650));
      await FlutterNfcKit.finish();

      if (!mounted) return;

      // Navegamos a la RUTA DINÁMICA
      Navigator.pushReplacementNamed(
        context,
        rutaDestino,
        arguments: data,
      );
    } catch (e) {
      setState(() {
        message = "Error: $e";
        scanning = false;
      });
      try {
        await FlutterNfcKit.finish();
      } catch (_) {}
    }
  }
  // --- FIN DE LA FUNCIÓN _startScan ---

  Widget _buildIconArea() {
    // (Tu código de _buildIconArea no cambia, ya está perfecto)
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
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFD7EFE6), // verde pastel suave
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textBlack),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // "Bienvenido!"
            const SizedBox(height: 6),
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

            // centro: icon + textos + boton
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconArea(),
                    const SizedBox(height: 18),
                    Text(
                      // --- MODIFICADO: Usamos la variable de estado 'message' ---
                      message,
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.textBlack,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    // (Texto "al punto de pago" eliminado para dar prioridad a 'message')
                    const SizedBox(height: 28),

                    // --- MODIFICADO: Botón con Spinner de Carga ---
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
                        minimumSize: const Size(180, 52), // Tamaño fijo
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: scanning
                            // Estado 1: "Escaneando..."
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
                            // Estado 2: "Reintentar"
                            : const Text(
                                "Reintentar",
                                key: ValueKey('retry'),
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    // --- FIN DE LA MODIFICACIÓN ---
                  ],
                ),
              ),
            ),

            // --- MODIFICADO: Tarjeta de historial dinámica ---
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
                    "Últimas Transacciones", // Título actualizado
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Lógica de historial dinámico
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
                  // --- FIN DE LA MODIFICACIÓN ---
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}