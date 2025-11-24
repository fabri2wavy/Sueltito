import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:sueltito/core/constants/app_paths.dart';
import 'package:sueltito/features/payment/domain/enums/payment_status_enum.dart';
import 'package:sueltito/features/payment/presentation/widgets/payment_confirmation_dialog.dart';
import 'package:sueltito/features/payment/domain/entities/pasaje.dart';

// --- MODIFICADO: Nombre de clase unificado (del merge) ---
class TrufiPaymentPage extends StatefulWidget {
  const TrufiPaymentPage({super.key});

  @override
  State<TrufiPaymentPage> createState() => _TrufiPaymentPageState();
}

class _TrufiPaymentPageState extends State<TrufiPaymentPage> {
  // --- NUEVO: Variable para guardar los datos del NFC ---
  Map<String, dynamic>? _conductorData;
  // --- FIN NUEVO ---

  bool _isPreferencial = false;
  final List<Pasaje> _pasajesSeleccionados = [];
  bool _simulateSuccess = true;

  // --- MODIFICADO: Precios de Trufi (tomados de tu merge) ---
  static const double _precioZonal = 2.50;
  static const double _precioZonalPref = 2.00;
  static const double _precioLargo = 3.00;
  static const double _precioLargoPref = 2.50;
  static const double _precioCorto = 2.80; // (Este es el precio "Corto" del Trufi)
  static const double _precioCortoPref = 2.30;
  static const double _precioExtraLargo = 3.30;
  static const double _precioExtraLargoPref = 2.80;

  double get precioActualZonal =>
      _isPreferencial ? _precioZonalPref : _precioZonal;
  double get precioActualLargo =>
      _isPreferencial ? _precioLargoPref : _precioLargo;
  double get precioActualCorto =>
      _isPreferencial ? _precioCortoPref : _precioCorto;
  double get precioActualExtraLargo =>
      _isPreferencial ? _precioExtraLargoPref : _precioExtraLargo;
  // --- FIN MODIFICADO ---

  double get totalAPagar =>
      _pasajesSeleccionados.fold(0.0, (sum, item) => sum + item.precio);

  // --- NUEVO: Lógica para recibir los datos del NFC ---
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_conductorData == null) {
      final state = GoRouterState.of(context);
      final extra = state.extra;
      if (extra != null && extra is Map<String, dynamic>) {
        setState(() {
          _conductorData = extra;
        });
      } else {
        print("Error: TrufiPaymentPage se abrió sin datos del conductor.");
      }
    }
  }
  // --- FIN NUEVO ---

  void _addPasaje(String nombre, double precio) {
    setState(() {
      _pasajesSeleccionados.add(Pasaje(nombre: nombre, precio: precio));
    });
  }

  void _removePasaje(int index) {
    setState(() {
      _pasajesSeleccionados.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- NUEVO: Muestra 'cargando' hasta que los datos del NFC lleguen ---
    if (_conductorData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // --- FIN NUEVO ---

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- MODIFICADO: Le pasamos los datos del conductor ---
                  _buildDriverInfoCard(_conductorData!),
                  // --- FIN MODIFICADO ---
                  const SizedBox(height: 24),
                  _buildFareSelection(context),
                  const SizedBox(height: 24),
                  _buildPayButton(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildSummaryCard(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        'Bienvenido al Trufi\nFabricio', // Título actualizado (de tu merge)
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  // --- MODIFICADO: Tarjeta de conductor dinámica (fusionada) ---
  Widget _buildDriverInfoCard(Map<String, dynamic> driverData) {
    // 1. Extraemos los bloques
    final propietario = driverData['propietario'] as Map<String, dynamic>? ?? {};
    final servicio = driverData['servicio'] as Map<String, dynamic>? ?? {};

    // 2. Extraemos los datos (usando el JSON que ya conocemos)
    final String nombre = propietario['nombre'] as String? ?? 'Conductor no encontrado';
    final String placa = servicio['identificador'] as String? ?? 'S/N';
    final String nombreRuta = servicio['nombre'] as String? ?? 'Ruta desconocida';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Placa: $placa', // Dato dinámico
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 6),
              Text(
                nombre, // Dato dinámico
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
              Text(
                nombreRuta, // Dato dinámico
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          // --- Icono de auto (de tu merge) ---
          const Icon(
            Icons.directions_car, 
            size: 40,
            color: AppColors.textBlack,
          ),
        ],
      ),
    );
  }
  // --- FIN MODIFICADO ---

  // --- MODIFICADO: Selección de 4 tarifas (de tu merge) ---
  Widget _buildFareSelection(BuildContext context) {
    bool hasZonal = _pasajesSeleccionados.any((p) => p.nombre == 'Tramo Zonal');
    bool hasLargo = _pasajesSeleccionados.any((p) => p.nombre == 'Tramo Largo');
    bool hasCorto = _pasajesSeleccionados.any((p) => p.nombre == 'Tramo Corto');
    bool hasExtraLargo = _pasajesSeleccionados.any(
      (p) => p.nombre == 'Tramo Extra Largo',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Elige tu tramo:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                Text(
                  'Tarifa Preferencial?',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Switch(
                  value: _isPreferencial,
                  onChanged: (value) {
                    setState(() {
                      _isPreferencial = value;
                    });
                  },
                  activeThumbColor: AppColors.primaryGreen,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFareButton(
                context,
                'Zonal',
                precioActualZonal,
                () => _addPasaje('Tramo Zonal', precioActualZonal),
                isSelected: hasZonal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFareButton(
                context,
                'Largo',
                precioActualLargo,
                () => _addPasaje('Tramo Largo', precioActualLargo),
                isSelected: hasLargo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFareButton(
                context,
                'Corto',
                precioActualCorto,
                () => _addPasaje('Tramo Corto', precioActualCorto),
                isSelected: hasCorto,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFareButton(
                context,
                'Extra Largo',
                precioActualExtraLargo,
                () => _addPasaje('Tramo Extra Largo', precioActualExtraLargo),
                isSelected: hasExtraLargo,
              ),
            ),
          ],
        ),
      ],
    );
  }
  // --- FIN MODIFICADO ---

  Widget _buildFareButton(
    BuildContext context,
    String label,
    double price,
    VoidCallback onPressed, {
    required bool isSelected,
  }) {
    // --- Estilo de botón (de tu merge) ---
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primaryGreen : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Bs. ${price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --- MODIFICADO: Botón de pago con lógica de guardado ---
  Widget _buildPayButton(BuildContext context) {
    bool hasItems = _pasajesSeleccionados.isNotEmpty;

    return Column(
      children: [
        ElevatedButton(
          onPressed: hasItems
              ? () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) {
                      return PaymentConfirmationDialog(
                        pasajes: _pasajesSeleccionados,
                        total: totalAPagar,
                        onConfirm: () async {
                          // --- NUEVO: PREPARAMOS LOS DATOS ANTES DE PAGAR ---
                          final List<Map<String, dynamic>> pasajesJSON =
                              _pasajesSeleccionados
                                  .map((p) => {
                                        'nombre': p.nombre,
                                        'precio': p.precio,
                                      })
                                  .toList();

                          final Map<String, dynamic> payloadToSend = {
                            'info_conductor': _conductorData, // <-- ¡LOS DATOS DEL NFC!
                            'detalle_pago': {
                              'pasajes': pasajesJSON,
                              'total_pagado': totalAPagar,
                            },
                            'pasajero_id': 'fabricio_id', // (Esto vendrá del login)
                            'timestamp': DateTime.now().toIso8601String(),
                          };
                          
                          print("--- ENVIANDO AL BACKEND (Simulación) ---");
                          print(json.encode(payloadToSend));
                          // await paymentUseCase.execute(payloadToSend);
                          // --- FIN NUEVO ---


                          // (Inicio de tu simulación de pago)
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );

                          final PaymentStatus resultStatus;
                          if (_simulateSuccess) {
                            resultStatus = PaymentStatus.success;
                          } else {
                            resultStatus = PaymentStatus.rejected;
                          }

                          setState(() {
                            _simulateSuccess = !_simulateSuccess;
                          });

                          // 3. Cerrar el diálogo
                          dialogContext.pop();

                          // 4. Navegar con GoRouter
                          context.go(
                            AppPaths.paymentStatus,
                            extra: resultStatus,
                          );
                          // (Fin de tu simulación de pago)


                          // --- NUEVO: GUARDAMOS EN EL HISTORIAL SI EL PAGO FUE EXITOSO ---
                          if (resultStatus == PaymentStatus.success) {
                            
                            try {
                              final prefs = await SharedPreferences.getInstance();
                              final List<String> historialJson = prefs.getStringList('historial') ?? [];
                              final String timestamp = DateTime.now().toIso8601String();
                              
                              final List<String> nuevosItemsJson = _pasajesSeleccionados.map((pasaje) {
                                final Map<String, dynamic> transaccion = {
                                  // ¡¡LA CLAVE ESTÁ AQUÍ!!
                                  'type': 'trufi', //
                                  'timestamp': timestamp,
                                  'nombre': pasaje.nombre,
                                  'precio': pasaje.precio,
                                };
                                return json.encode(transaccion);
                              }).toList();

                              historialJson.addAll(nuevosItemsJson);
                              await prefs.setStringList('historial', historialJson);
                              print("Historial de Trufi guardado!");
                            } catch (e) {
                              print("Error al guardar historial: $e");
                            }
                            // --- FIN NUEVO ---

                            setState(() {
                              _pasajesSeleccionados.clear();
                            });
                          }
                        },
                      );
                    },
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            // ... (tu estilo de botón no cambia)
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
            backgroundColor: hasItems
                ? const Color.fromARGB(255, 84, 209, 190)
                : Colors.grey[400],
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[500],
          ),
          child: const Icon(Icons.attach_money, size: 35),
        ),
        const SizedBox(height: 8),
        Text(
          'ENVIAR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: hasItems ? AppColors.primaryGreen : Colors.grey,
          ),
        ),
      ],
    );
  }
  // --- FIN MODIFICADO ---


  Widget _buildSummaryCard(BuildContext context) {
    // ... (Tu _buildSummaryCard y _buildSummaryItem no necesitan cambios)
    Map<String, int> pasajeCounts = {};
    for (var pasaje in _pasajesSeleccionados) {
      pasajeCounts[pasaje.nombre] = (pasajeCounts[pasaje.nombre] ?? 0) + 1;
    }

    List<Widget> itemsWidget = pasajeCounts.entries.map((entry) {
      String nombre = entry.key;
      int cantidad = entry.value;
      double precioUnitario = _pasajesSeleccionados
          .firstWhere((p) => p.nombre == nombre)
          .precio;
      double subtotal = cantidad * precioUnitario;

      return _buildSummaryItem(
        context,
        nombre,
        '$cantidad persona${cantidad > 1 ? 's' : ''}',
        subtotal,
        () {
          int indexToRemove = _pasajesSeleccionados.indexWhere(
            (p) => p.nombre == nombre,
          );
          if (indexToRemove != -1) {
            _removePasaje(indexToRemove);
          }
        },
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Selección de Pasajes',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_pasajesSeleccionados.isEmpty)
            const Text(
              'Añade un tramo para comenzar...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ...itemsWidget,
          const Divider(height: 32, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Bs. ${totalAPagar.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String subtitle,
    double subtotal,
    VoidCallback onQuitar,
  ) {
    // ... (Esta función no cambia)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Bs ${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onQuitar,
                child: Text(
                  'quitar',
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}