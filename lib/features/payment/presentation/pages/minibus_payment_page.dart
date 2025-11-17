// --- NUEVO: Imports para JSON y guardado local ---
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// --- FIN NUEVO ---

import 'package:flutter/material.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/features/payment/domain/enums/payment_status_enum.dart';
import 'package:sueltito/features/payment/presentation/widgets/payment_confirmation_dialog.dart';
import 'package:sueltito/features/payment/domain/entities/pasaje.dart';

class MinibusPaymentPage extends StatefulWidget {
  const MinibusPaymentPage({super.key});

  @override
  State<MinibusPaymentPage> createState() => _MinibusPaymentPageState();
}

class _MinibusPaymentPageState extends State<MinibusPaymentPage> {
  // --- NUEVO: Variable para guardar los datos del NFC ---
  Map<String, dynamic>? _conductorData;
  // --- FIN NUEVO ---

  bool _isPreferencial = false;
  final List<Pasaje> _pasajesSeleccionados = [];
  bool _simulateSuccess = true;

  // --- PRECIOS ESPECÍFICOS PARA MINIBUS (SOLO CORTO Y LARGO) ---
  static const double _precioCorto = 2.40;
  static const double _precioCortoPref = 2.00;
  static const double _precioLargo = 3.00;
  static const double _precioLargoPref = 2.50;

  double get precioActualCorto =>
      _isPreferencial ? _precioCortoPref : _precioCorto;
  double get precioActualLargo =>
      _isPreferencial ? _precioLargoPref : _precioLargo;

  double get totalAPagar =>
      _pasajesSeleccionados.fold(0.0, (sum, item) => sum + item.precio);

  // --- NUEVO: Lógica para recibir los datos del NFC ---
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Solo cargamos los datos la primera vez
    if (_conductorData == null) {
      // 1. Obtenemos los argumentos enviados (el JSON del NFC)
      final args = ModalRoute.of(context)?.settings.arguments;

      // 2. Verificamos que no sean nulos y sean un Mapa
      if (args != null && args is Map<String, dynamic>) {
        // 3. Guardamos los datos en el estado
        setState(() {
          _conductorData = args;
        });
      } else {
        // 4. Manejo de error (si se abre la página sin datos)
        print("Error: MinibusPaymentPage se abrió sin datos del conductor.");
        // Opcional: podrías cerrar la página si no hay datos
        // Navigator.of(context).pop();
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
    // --- NUEVO: Muestra un 'cargando' hasta que los datos del NFC lleguen ---
    if (_conductorData == null) {
      return const Scaffold(
        body: Center(
          // Muestra un indicador de carga
          child: CircularProgressIndicator(),
        ),
      );
    }
    // --- FIN NUEVO ---

    // El resto de la UI se construye normal una vez que _conductorData existe
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
                  // --- pasamos los datos del conductor ---
                  _buildDriverInfoCard(_conductorData!),
                  // ------
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
      // ...AppBar
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        'Bienvenido al Minibus\nFabricio',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  // --- MODIFICADO: Esta función ahora es dinámica y recibe el JSON ---
  Widget _buildDriverInfoCard(Map<String, dynamic> driverData) {
    // 1. Extraemos los bloques (con '?? {}' para evitar errores si no existen)
    final propietario = driverData['propietario'] as Map<String, dynamic>? ?? {};
    final servicio = driverData['servicio'] as Map<String, dynamic>? ?? {};

    // 2. Extraemos los datos que queremos mostrar (como hicimos con el Trufi)
    //    El usuario dijo que el JSON no cambia, así que usamos la misma estructura.
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
                // --- MODIFICADO: Mostramos la PLACA ---
                'Placa: $placa',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 6),
              Text(
                // --- MODIFICADO: Mostramos el NOMBRE ---
                nombre,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
              Text(
                // --- NUEVO: Mostramos la RUTA ---
                nombreRuta,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          const Icon(
            Icons.directions_bus,
            size: 40,
            color: AppColors.textBlack,
          ),
        ],
      ),
    );
  }
  // --- FIN MODIFICADO ---

  Widget _buildFareSelection(BuildContext context) {
    // ... (Tu lógica de _buildFareSelection y _buildFareButton no cambia)
    bool hasCorto = _pasajesSeleccionados.any((p) => p.nombre == 'Tramo Corto');
    bool hasLargo = _pasajesSeleccionados.any((p) => p.nombre == 'Tramo Largo');

    return Column(
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
                'Largo',
                precioActualLargo,
                () => _addPasaje('Tramo Largo', precioActualLargo),
                isSelected: hasLargo,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFareButton(
    BuildContext context,
    String label,
    double price,
    VoidCallback onPressed, {
    required bool isSelected,
  }) {
    // ...
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

  // --- MODIFICADO: Añadimos la lógica de envío y guardado ---
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
                          // 1. Preparamos los pasajes
                          final List<Map<String, dynamic>> pasajesJSON =
                              _pasajesSeleccionados
                                  .map((p) => {
                                        'nombre': p.nombre,
                                        'precio': p.precio,
                                      })
                                  .toList();

                          // 2. Creamos el JSON COMPLETO para enviar al backend
                          final Map<String, dynamic> payloadToSend = {
                            'info_conductor': _conductorData, // <-- ¡LOS DATOS DEL NFC!
                            'detalle_pago': {
                              'pasajes': pasajesJSON,
                              'total_pagado': totalAPagar,
                            },
                            'pasajero_id': 'fabricio_id', // (Esto vendrá del login)
                            'timestamp': DateTime.now().toIso8601String(),
                          };
                          
                          // 3. Imprimimos el JSON para depurar
                          print("--- ENVIANDO AL BACKEND (Simulación) ---");
                          print(json.encode(payloadToSend));
                          // Aquí llamarías a tu UseCase:
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

                          Navigator.of(dialogContext).pop();

                          Navigator.of(context).pushNamed(
                            '/payment_status',
                            arguments: resultStatus,
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
                                  'type': 'minibus', // ¡TIPO ESPECÍFICO DE MINIBUS!
                                  'timestamp': timestamp,
                                  'nombre': pasaje.nombre,
                                  'precio': pasaje.precio,
                                };
                                return json.encode(transaccion);
                              }).toList();

                              historialJson.addAll(nuevosItemsJson);
                              await prefs.setStringList('historial', historialJson);
                              print("Historial de Minibus guardado!");
                            } catch (e) {
                              print("Error al guardar historial: $e");
                            }
                            // --- FIN NUEVO ---

                            setState(() {
                              _pasajesSeleccionados.clear();
                            });
                          }
                          // --- FIN MODIFICADO ---
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