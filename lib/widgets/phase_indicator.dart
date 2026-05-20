import 'package:flutter/material.dart';

/// PhaseIndicator — Indikator lingkaran yang menampilkan fase menstruasi saat ini.
/// Menampilkan nama fase, ikon, dan warna cincin berdasarkan fase.
class PhaseIndicator extends StatelessWidget {
  final String phase;
  final double size;

  const PhaseIndicator({
    super.key,
    required this.phase,
    this.size = 140,
  });

  /// Mendapatkan konfigurasi visual berdasarkan fase siklus
  _PhaseVisual get _visual {
    switch (phase) {
      case 'Menstruasi':
        return _PhaseVisual(
          icon: Icons.water_drop_rounded,
          color: const Color(0xFFFF8FAB),
          gradientColors: [const Color(0xFFFF8FAB), const Color(0xFFFFB5C2)],
          description: 'Fase Menstruasi',
        );
      case 'Folikular':
        return _PhaseVisual(
          icon: Icons.eco_rounded,
          color: const Color(0xFF81C784),
          gradientColors: [const Color(0xFF81C784), const Color(0xFFA5D6A7)],
          description: 'Fase Folikular',
        );
      case 'Ovulasi':
        return _PhaseVisual(
          icon: Icons.star_rounded,
          color: const Color(0xFF64B5F6),
          gradientColors: [const Color(0xFF64B5F6), const Color(0xFF90CAF9)],
          description: 'Fase Ovulasi',
        );
      case 'Luteal':
        return _PhaseVisual(
          icon: Icons.nights_stay_rounded,
          color: const Color(0xFFCE93D8),
          gradientColors: [const Color(0xFFCE93D8), const Color(0xFFE1BEE7)],
          description: 'Fase Luteal',
        );
      default:
        return _PhaseVisual(
          icon: Icons.help_outline_rounded,
          color: const Color(0xFFBDBDBD),
          gradientColors: [const Color(0xFFBDBDBD), const Color(0xFFE0E0E0)],
          description: 'Belum Ada Data',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visual = _visual;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lingkaran utama dengan cincin gradient
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                visual.gradientColors[0],
                visual.gradientColors[1],
                visual.gradientColors[0],
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: visual.color.withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    visual.icon,
                    size: size * 0.28,
                    color: visual.color,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phase.isNotEmpty ? phase : '-',
                    style: TextStyle(
                      fontSize: size * 0.1,
                      fontWeight: FontWeight.bold,
                      color: visual.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Label deskripsi
        Text(
          visual.description,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: visual.color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

/// Kelas helper untuk konfigurasi visual tiap fase
class _PhaseVisual {
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final String description;

  const _PhaseVisual({
    required this.icon,
    required this.color,
    required this.gradientColors,
    required this.description,
  });
}
