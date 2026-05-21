import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cima_mens/providers/settings_provider.dart';
import 'package:cima_mens/providers/cycle_provider.dart';


import 'package:cima_mens/utils/constants.dart';
import 'package:cima_mens/utils/export_utils.dart';
import 'package:cima_mens/screens/profile/profile_screen.dart';

/// SettingsScreen — Tab Pengaturan.
/// Berisi pilihan tema, notifikasi, profil/akun, dan info app.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Tema Warna =====
            _buildSectionCard(
              context: context,
              title: 'Tema Warna',
              icon: Icons.palette_rounded,
              primaryColor: primaryColor,
              child: _buildThemePicker(context, settingsProvider),
            ),
            const SizedBox(height: 16),

            // ===== Notifikasi =====
            _buildSectionCard(
              context: context,
              title: 'Notifikasi',
              icon: Icons.notifications_rounded,
              primaryColor: primaryColor,
              child: _buildNotificationToggle(
                  context, settingsProvider, primaryColor),
            ),
            const SizedBox(height: 16),

            // ===== Akun =====
            _buildSectionCard(
              context: context,
              title: 'Akun & Profil',
              icon: Icons.person_rounded,
              primaryColor: primaryColor,
              child: _buildAccountSection(context, primaryColor),
            ),
            const SizedBox(height: 16),

            // ===== Data =====
            _buildSectionCard(
              context: context,
              title: 'Data',
              icon: Icons.storage_rounded,
              primaryColor: primaryColor,
              child: _buildDataSection(context, primaryColor),
            ),
            const SizedBox(height: 16),

            // ===== Tentang =====
            _buildAboutCard(context, primaryColor),
          ],
        ),
      ),
    );
  }

  /// Pemilih tema warna — 3 pilihan: Pink, Peach, Lavender
  Widget _buildThemePicker(
      BuildContext context, SettingsProvider settingsProvider) {
    final themes = [
      {
        'name': 'pink',
        'label': 'Pink',
        'color': FlowMateConstants.pinkPalette['primary']!,
      },
      {
        'name': 'peach',
        'label': 'Peach',
        'color': FlowMateConstants.peachPalette['primary']!,
      },
      {
        'name': 'lavender',
        'label': 'Lavender',
        'color': FlowMateConstants.lavenderPalette['primary']!,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: themes.map((theme) {
        final isSelected = settingsProvider.themeColor == theme['name'];
        final color = theme['color'] as Color;

        return GestureDetector(
          onTap: () => settingsProvider.setThemeColor(theme['name'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade200,
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: Column(
              children: [
                // Lingkaran warna
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 22)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  theme['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? color : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Toggle notifikasi & tombol tes notifikasi
  Widget _buildNotificationToggle(BuildContext context,
      SettingsProvider settingsProvider, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                settingsProvider.notificationsEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                color: primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengingat Haid & Mood',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    'Notifikasi harian mood & sebelum haid tiba',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: settingsProvider.notificationsEnabled,
              onChanged: (_) => settingsProvider.setNotificationsEnabled(!settingsProvider.notificationsEnabled),
              activeThumbColor: primaryColor,
            ),
          ],
        ),
      ],
    );
  }


  /// Bagian data: ekspor & reset
  Widget _buildDataSection(BuildContext context, Color primaryColor) {
    return Column(
      children: [
        // Ekspor data
        _buildActionTile(
          context: context,
          icon: Icons.upload_file_rounded,
          title: 'Ekspor Data',
          subtitle: 'Bagikan data dalam format CSV',
          color: const Color(0xFF64B5F6),
          onTap: () async {
            try {
              final cycles = context.read<CycleProvider>().cycles;
              await ExportUtils.shareData(cycles);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal mengekspor: $e'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  /// Bagian Akun
  Widget _buildAccountSection(BuildContext context, Color primaryColor) {
    return Column(
      children: [
        _buildActionTile(
          context: context,
          icon: Icons.manage_accounts_rounded,
          title: 'Pengaturan Profil',
          subtitle: 'Ubah avatar dan hubungkan partner',
          color: primaryColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
      ],
    );
  }

  /// Baris aksi (tile)
  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog konfirmasi reset


  /// Kartu Tentang FlowMate
  Widget _buildAboutCard(BuildContext context, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.1),
            primaryColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'FlowMate',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Versi 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Aplikasi kalender menstruasi yang membantu\nkamu melacak siklus, mood, dan gejala\ndengan tampilan yang lembut dan menyenangkan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            'Dibuat dengan 💕 untuk kamu',
            style: TextStyle(
              fontSize: 12,
              color: primaryColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Card section builder
  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color primaryColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
