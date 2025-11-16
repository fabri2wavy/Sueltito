import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:sueltito/core/config/app_theme.dart';

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

    // auto-start scan breve después de build
    Future.delayed(const Duration(milliseconds: 300), _startScan);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
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

      // éxito visual + vibración
      setState(() {
        success = true;
        message = "Lectura correcta";
      });
      HapticFeedback.mediumImpact();

      await Future.delayed(const Duration(milliseconds: 650));
      await FlutterNfcKit.finish();

      if (!mounted) return;

      // navega reemplazando a la página de pago (mismo comportamiento que antes)
      Navigator.pushReplacementNamed(
        context,
        '/minibus_payment',
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

  Widget _buildIconArea() {
    // AnimatedSwitcher muestra: tick (success) / loader (scanning) / icono (idle)
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
            // "Bienvenido!" top-left como en tu mockup
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
                      "Acerca el celular",
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.textBlack,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "al punto de pago",
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.textBlack.withOpacity(0.65),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
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
                      ),
                      child: Text(
                        scanning ? "Escaneando..." : "Reintentar",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // tarjeta historial (alineada y centrada como en mock)
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
                    "Historial de Pasajes",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Tramo Corto\n2 personas"),
                      Text("Bs 4.80"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Tramo Largo\n1 persona"),
                      Text("Bs 3.00"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Tramo Preferencia\n1 persona"),
                      Text("Bs 2.00"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
