import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sueltito/core/config/app_theme.dart';
import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart';
import 'package:sueltito/features/history/domain/entities/movement.dart';

// Importamos tus providers nuevos
import '../providers/history_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  List<Movement> _movimientos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Usamos el callback para asegurar que el contexto esté listo antes de llamar a Riverpod
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarHistorial();
    });
  }

  Future<void> _cargarHistorial() async {
    try {
      // 1. Obtener ID del usuario (de tu AuthProvider existente)
      final user = ref.read(authProvider).value?.usuario;
      
      if (user == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "No se encontró usuario activo";
          });
        }
        return;
      }

      // 2. LIMPIEZA: Aquí pedimos el UseCase listo a Riverpod (Ya no hacemos 'new ApiClient')
      final getHistoryUseCase = ref.read(getPassengerHistoryUseCaseProvider);

      // 3. Ejecutamos el caso de uso
      final lista = await getHistoryUseCase.call(user.id);

      // 4. Actualizar UI
      if (mounted) {
        setState(() {
          _movimientos = lista;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // _errorMessage = e.toString(); // Descomentar para debug
          _errorMessage = "No se pudo cargar el historial.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Pagos',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textBlack),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _cargarHistorial();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text("Recargar"),
            )
          ],
        ),
      );
    }

    if (_movimientos.isEmpty) {
      return const Center(child: Text("No tienes movimientos registrados."));
    }

    return RefreshIndicator(
      onRefresh: _cargarHistorial,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _movimientos.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final mov = _movimientos[index];
          return _buildHistoryItem(mov);
        },
      ),
    );
  }

  Widget _buildHistoryItem(Movement mov) {
    final dateStr = "${mov.fecha.day}/${mov.fecha.month}/${mov.fecha.year}";
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getIconForTransport(mov.transporte),
          color: AppColors.primaryGreen,
        ),
      ),
      title: Text(mov.transporte, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("${mov.tramo} • $dateStr", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      trailing: Text(
        "Bs ${mov.monto.toStringAsFixed(2)}",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textBlack),
      ),
    );
  }

  IconData _getIconForTransport(String tipo) {
    final t = tipo.toUpperCase();
    if (t.contains("TAXI")) return Icons.local_taxi;
    if (t.contains("TRUFI")) return Icons.directions_car;
    if (t.contains("MINIBUS") || t.contains("BUS")) return Icons.directions_bus;
    return Icons.attach_money;
  }
}