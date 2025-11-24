import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Riverpod
import 'package:go_router/go_router.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/core/constants/app_paths.dart';

// 2. Tus imports de Clean Architecture
import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart';
import 'package:sueltito/features/history/domain/entities/movement.dart';
import 'package:sueltito/features/history/presentation/providers/history_provider.dart';

// 3. Cambiamos a ConsumerStatefulWidget
class NfcScanPage extends ConsumerStatefulWidget {
  const NfcScanPage({super.key});

  @override
  ConsumerState<NfcScanPage> createState() => _NfcScanPageState();
}

class _NfcScanPageState extends ConsumerState<NfcScanPage>
    with SingleTickerProviderStateMixin {
  
  bool scanning = false;
  bool success = false;
  bool hasError = false; 
  String message = "Buscando punto de pago..."; 

  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  // 4. Usamos la entidad real 'Movement' en lugar de Map
  List<Movement> _ultimasTransacciones = [];
  bool _isLoadingHistory = true;

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

    // 5. Cargamos el historial REAL al iniciar (usando callback para asegurar contexto)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarHistorialReal();
    });

    // Iniciamos escaneo siempre
    Future.delayed(const Duration(milliseconds: 300), _startScan);
  }

  // 6. Método para traer datos de la API
  Future<void> _cargarHistorialReal() async {
    try {
      final user = ref.read(authProvider).value?.usuario;
      if (user == null) return;

      // Llamamos al UseCase que ya configuramos
      final getHistoryUseCase = ref.read(getPassengerHistoryUseCaseProvider);
      
      // Petición a la API
      final historial = await getHistoryUseCase.call(user.id);

      if (mounted) {
        setState(() {
          // Tomamos las 3 últimas
          _ultimasTransacciones = historial.take(3).toList();
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      print("Error cargando historial en NFC Page: $e");
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
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
      
      final String? tipoTransporte = data['servicio']?['tipo_transporte'];
      
      String? rutaDestino;
      switch (tipoTransporte) {
        case '01': rutaDestino = AppPaths.minibusPayment; break;
        case '02': rutaDestino = AppPaths.trufisPayment; break;
        case '03': rutaDestino = AppPaths.taxiPayment; break;
        case '04': rutaDestino = AppPaths.trufisPayment; break; 
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

      // Navegamos y esperamos a que vuelva para recargar historial
      await GoRouter.of(context).push(rutaDestino, extra: data);

      if (mounted) {
        setState(() {
          scanning = false;
          success = false;
        });
        print('[NFC] Reiniciando escaneo tras navegación');
        
        // Al volver, recargamos el historial para ver el nuevo pago (si hubo)
        _cargarHistorialReal();
        _startScan();
      }
    } catch (e) {
      print('[NFC][ERROR] $e');
      
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
              : ScaleTransition( 
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

                    if (!scanning)
                      ElevatedButton(
                        onPressed: _startScan, 
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
                      const SizedBox(height: 52), 
                  ],
                ),
              ),
            ),

            // 7. SECCIÓN DE HISTORIAL REAL
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
                  
                  if (_isLoadingHistory)
                     const Center(child: Padding(
                       padding: EdgeInsets.all(8.0),
                       child: CircularProgressIndicator(),
                     ))
                  else if (_ultimasTransacciones.isEmpty)
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
                    // Renderizamos los objetos 'Movement' reales
                    ..._ultimasTransacciones.map((mov) {
                      // Formateo simple de fecha (ej: 15/11)
                      final dateStr = "${mov.fecha.day}/${mov.fecha.month}";
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mov.transporte, // 'MINIBUS', etc.
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${mov.tramo} • $dateStr", 
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                            Text(
                              "Bs ${mov.monto.toStringAsFixed(2)}",
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