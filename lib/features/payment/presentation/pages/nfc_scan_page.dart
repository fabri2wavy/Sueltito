import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:sueltito/core/constants/app_paths.dart';

class NfcScanPage extends StatefulWidget {
  const NfcScanPage({super.key});

  @override
  State<NfcScanPage> createState() => _NfcScanPageState();
}

class _NfcScanPageState extends State<NfcScanPage>
    with SingleTickerProviderStateMixin {
  
  // (Ya no necesitamos la variable estática _hasAutoScanned porque SIEMPRE escanea)

  bool scanning = false;
  bool success = false;
  bool hasError = false; 
  String message = "Buscando punto de pago..."; // Mensaje por defecto

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

    // --- CAMBIO 1: SIEMPRE INICIAMOS EL ESCANEO ---
    // No importa si es la 1ra o la 10ma vez, arrancamos el radar.
    Future.delayed(const Duration(milliseconds: 300), _startScan);
    // ----------------------------------------------
  }

  Future<void> _cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historialJson = prefs.getStringList('historial') ?? [];
    
    final List<Map<String, dynamic>> transacciones = historialJson.map((itemString) {
      try {
        return json.decode(itemString) as Map<String, dynamic>;
      } catch (e) {
        return <String, dynamic>{};
      }
    }).where((map) => map.isNotEmpty).toList();

    transacciones.sort((a, b) {
      return (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? '');
    });

    if (mounted) {
      setState(() {
        _ultimasTransacciones = transacciones.take(3).toList();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    print('[NFC] Iniciando escaneo...');
    if (scanning) return;

    setState(() {
      scanning = true;
      success = false;
      hasError = false;
      message = "Acerca el celular al punto de pago...";
    });

    try {
      NFCTag tag = await FlutterNfcKit.poll(timeout: const Duration(seconds: 20));
      print('[NFC] Tag leído: $tag');

      if (tag.ndefAvailable != true) {
        print('[NFC] Tag no tiene NDEF disponible');
        throw Exception("Datos no válidos");
      }

      List<dynamic> records = await FlutterNfcKit.readNDEFRecords(cached: false);
      print('[NFC] Records: $records');

      if (records.isEmpty) {
        print('[NFC] Etiqueta vacía');
        throw Exception("Etiqueta vacía");
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
      print('[NFC] Payload: $content');

      final data = json.decode(content);
      print('[NFC] Data decodificada: $data');

      final String? tipoTransporte = data['servicio']?['tipo_transporte'];
      print('[NFC] Tipo transporte: $tipoTransporte');

      String? rutaDestino;
      switch (tipoTransporte) {
        case '01': rutaDestino = AppPaths.minibusPayment; break;
        case '02': rutaDestino = AppPaths.trufisPayment; break;
        case '04': rutaDestino = AppPaths.trufisPayment; break; // Trufi Zonal
        case '03': rutaDestino = AppPaths.taxiPayment; break;
        default:
          print('[NFC] Transporte desconocido');
          throw Exception("Transporte desconocido");
      }

      setState(() {
        success = true;
        message = "¡Encontrado!";
      });
      print('[NFC] ¡Encontrado! Navegando a $rutaDestino');
      HapticFeedback.mediumImpact();

      await Future.delayed(const Duration(milliseconds: 650));
      await FlutterNfcKit.finish();

      if (!mounted) return;

      GoRouter.of(context).push(rutaDestino, extra: data);

      if (mounted) {
        setState(() {
          scanning = false;
          success = false;
        });
        print('[NFC] Reiniciando escaneo tras navegación');
        _startScan();
      }
    } catch (e, st) {
      print('[NFC][ERROR] $e');
      print('[NFC][STACK] $st');
      String errorMessage;
      if (e is PlatformException && e.code == '408') {
        errorMessage = "Tiempo agotado. ¿Reintentar?";
      } else if (e is Exception) {
        errorMessage = e.toString().replaceAll("Exception: ", "");
      } else {
        errorMessage = "Error de lectura";
      }

      if (mounted) {
        setState(() {
          hasError = true;
          scanning = false;
          message = errorMessage;
        });
      }

      if (hasError) HapticFeedback.heavyImpact();

      try {
        await FlutterNfcKit.finish();
      } catch (_) {}
    }
  }

  Widget _buildIconArea() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: success
          ? Container(
              key: const ValueKey('success'),
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: const Icon(Icons.check_circle_rounded, size: 100, color: Colors.green),
            )
          : hasError
              ? Container(
                  key: const ValueKey('error'),
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: const Icon(Icons.cancel_rounded, size: 100, color: Colors.red),
                )
              : ScaleTransition( // ESTADO ESCANEANDO (Siempre activo)
                  key: const ValueKey('pulse'),
                  scale: _pulseAnimation,
                  child: Container(
                    width: 140,
                    height: 140,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
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
      backgroundColor: const Color(0xFFD7EFE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: AppColors.textBlack),
      ),
      body: SafeArea(
        child: Column(
          children: [
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

            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconArea(),
                    const SizedBox(height: 24),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          message,
                          key: ValueKey(message),
                          style: textTheme.headlineSmall?.copyWith(
                            color: hasError ? Colors.red : AppColors.textBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 34),

                    // --- CAMBIO 3: EL BOTÓN SÓLO APARECE SI NO ESTÁ ESCANEANDO ---
                    // Como ahora siempre escanea, esto significa que el botón 
                    // SOLO aparece si hubo un ERROR (hasError = true).
                    if (!scanning)
                      ElevatedButton(
                        onPressed: _startScan, // Al presionar, reinicia el bucle
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasError ? Colors.red : AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 36, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          minimumSize: const Size(180, 52),
                        ),
                        child: const Text(
                          "Reintentar",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )
                    else
                      // Espacio vacío para mantener la altura cuando no hay botón
                      const SizedBox(height: 52), 
                    // -------------------------------------------------------------
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
                      final String tipo = (transaccion['type'] ?? '...').toString().toUpperCase();
                      final String nombre = transaccion['nombre'] ?? 'Error';
                      final double precio = (transaccion['precio'] is num) 
                          ? (transaccion['precio'] as num).toDouble() 
                          : 0.0;

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