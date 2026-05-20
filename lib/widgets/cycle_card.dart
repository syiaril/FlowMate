import 'package:flutter/material.dart';
import 'package:cima_mens/models/cycle_model.dart';
import 'package:cima_mens/utils/date_utils.dart';

/// CycleCard — Kartu indah untuk menampilkan informasi siklus.
/// Menampilkan tanggal mulai, lama haid, panjang siklus, dan prediksi.
class CycleCard extends StatelessWidget {
  final CycleModel cycle;
  final VoidCallback? onDelete;

  const CycleCard({
    super.key,
    required this.cycle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: tanggal mulai & tombol hapus
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.water_drop_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mulai: ${FlowDateUtils.formatDate(cycle.startDate)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${cycle.id.substring(0, 8)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red.shade300,
                      size: 22,
                    ),
                    tooltip: 'Hapus Siklus',
                  ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 14),

            // Detail grid: 2 x 2
            Row(
              children: [
                _DetailItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Lama Haid',
                  value: '${cycle.periodLength} hari',
                  color: const Color(0xFFFF8FAB),
                ),
                const SizedBox(width: 16),
                _DetailItem(
                  icon: Icons.loop_rounded,
                  label: 'Panjang Siklus',
                  value: '${cycle.cycleLength} hari',
                  color: const Color(0xFF81C784),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _DetailItem(
                  icon: Icons.event_rounded,
                  label: 'Haid Berikutnya',
                  value: FlowDateUtils.formatDateShort(cycle.nextPeriodDate),
                  color: const Color(0xFF64B5F6),
                ),
                const SizedBox(width: 16),
                _DetailItem(
                  icon: Icons.star_rounded,
                  label: 'Ovulasi',
                  value: FlowDateUtils.formatDateShort(cycle.ovulationDate),
                  color: const Color(0xFFCE93D8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Item detail kecil dalam kartu siklus
class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
