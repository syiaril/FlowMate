import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cima_mens/providers/cycle_provider.dart';
import 'package:cima_mens/widgets/cycle_card.dart';
import 'package:cima_mens/screens/input_cycle_screen.dart';
import 'package:cima_mens/screens/cycle_graph_screen.dart';

/// HistoryScreen — Tab Riwayat.
/// Menampilkan daftar CycleCard dari semua siklus yang tersimpan.
/// Mendukung hapus siklus, navigasi ke grafik siklus, dan ekspor CSV.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cycles = cycleProvider.cycles;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Riwayat Siklus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Tombol grafik
          if (cycles.length >= 2)
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const CycleGraphScreen()),
                );
              },
              icon: Icon(Icons.bar_chart_rounded, color: primaryColor),
              tooltip: 'Grafik Siklus',
            ),
        ],
      ),
      body: cycles.isEmpty
          ? _buildEmptyState(context, primaryColor)
          : _buildCycleList(context, cycleProvider, primaryColor),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const InputCycleScreen()),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  /// Daftar siklus
  Widget _buildCycleList(
      BuildContext context, CycleProvider cycleProvider, Color primaryColor) {
    final cycles = cycleProvider.cycles;

    return Column(
      children: [
        // Header ringkasan
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.12),
                primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.analytics_rounded,
                  color: primaryColor, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cycles.length} siklus tercatat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    'Rata-rata siklus: ${cycleProvider.avgCycleLength.round()} hari',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (cycles.length >= 2)
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CycleGraphScreen()),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.show_chart_rounded,
                        color: primaryColor, size: 20),
                  ),
                ),
            ],
          ),
        ),

        // Daftar kartu
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: cycles.length,
            itemBuilder: (context, index) {
              final cycle = cycles[index];
              return CycleCard(
                cycle: cycle,
                onDelete: () =>
                    _confirmDelete(context, cycleProvider, cycle.id),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Dialog konfirmasi hapus
  void _confirmDelete(
      BuildContext context, CycleProvider cycleProvider, String id) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Hapus Siklus?'),
          content: const Text(
            'Data siklus ini akan dihapus secara permanen. Apakah kamu yakin?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                context.read<CycleProvider>().deleteCycle(id);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Siklus berhasil dihapus'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: Text(
                'Hapus',
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Empty state
  Widget _buildEmptyState(BuildContext context, Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 48,
                color: primaryColor.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Riwayat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Siklus yang kamu catat akan\ntampil di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
