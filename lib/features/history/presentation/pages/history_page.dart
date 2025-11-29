import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sueltito/core/config/app_theme.dart';
// import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart';
import 'package:sueltito/features/history/domain/entities/movement.dart';
import 'package:sueltito/core/network/api_client.dart';
import 'package:sueltito/features/auth/presentation/providers/auth_provider.dart';
import 'package:sueltito/core/constants/roles.dart';

// Importamos tus providers nuevos
import '../providers/history_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value?.usuario;
    final title = (user?.perfilActual == Roles.chofer || user?.perfilActual == 'BANCO') ? 'Historial de Cobros' : 'Historial de Pagos';
    print("[HistoryPage] Building History Page for role: ${user?.perfilActual}");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
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
    final historyAsync = ref.watch(historyFutureProvider);


    return historyAsync.when(
      data: (movimientos) {
        if (movimientos.isEmpty) {
          return const Center(child: Text("No tienes movimientos registrados."));
        }
        return RefreshIndicator(
          onRefresh: () async { ref.invalidate(historyFutureProvider); },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: movimientos.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final mov = movimientos[index];
              return _buildHistoryItem(mov);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        final msg = e is ApiException ? e.message : e.toString();
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async { ref.invalidate(historyFutureProvider); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Recargar"),
              ),
            ],
          ),
        );
      },
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