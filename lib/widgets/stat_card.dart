import 'package:flutter/material.dart';

/// StatCard — Kartu statistik dengan ikon, judul, nilai, dan gradient pastel.
/// Digunakan di CalendarScreen untuk menampilkan ringkasan siklus.
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Theme.of(context).colorScheme.primary;
    final lightColor = baseColor.withValues(alpha: 0.15);

    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            lightColor,
            baseColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon dalam lingkaran
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: baseColor, size: 22),
            ),
            const SizedBox(height: 10),

            // Nilai (angka besar)
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: baseColor.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 4),

            // Judul
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: baseColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
