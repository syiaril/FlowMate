import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cima_mens/providers/auth_provider.dart';
import 'package:cima_mens/providers/settings_provider.dart';
import 'package:cima_mens/services/notification_service.dart';
import 'package:cima_mens/screens/admin/admin_dashboard.dart';
import 'package:cima_mens/screens/calendar_screen.dart';
import 'package:cima_mens/screens/history_screen.dart';
import 'package:cima_mens/screens/mood_screen.dart';
import 'package:cima_mens/screens/settings_screen.dart';
import 'package:cima_mens/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider = context.read<SettingsProvider>();
      if (settingsProvider.notificationsEnabled) {
        await NotificationService.instance.requestPermission();
      }
    });
  }

  final List<Widget> _partnerPages = const [
    CalendarScreen(),
    HistoryScreen(),
    MoodScreen(),
    SettingsScreen(),
  ];

  final List<Widget> _adminPages = const [
    AdminDashboard(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final currentPages = isAdmin ? _adminPages : _partnerPages;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex >= currentPages.length ? 0 : _currentIndex,
        children: currentPages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: isAdmin
                  ? [
                      _buildNavItem(index: 0, icon: Icons.dashboard, label: 'Dashboard', primaryColor: primaryColor),
                      _buildNavItem(index: 1, icon: Icons.person, label: 'Profile', primaryColor: primaryColor),
                      _buildNavItem(index: 2, icon: Icons.settings, label: 'Pengaturan', primaryColor: primaryColor),
                    ]
                  : [
                      _buildNavItem(index: 0, icon: Icons.home_rounded, label: 'Beranda', primaryColor: primaryColor),
                      _buildNavItem(index: 1, icon: Icons.history_rounded, label: 'Riwayat', primaryColor: primaryColor),
                      _buildNavItem(index: 2, icon: Icons.emoji_emotions_rounded, label: 'Mood', primaryColor: primaryColor),
                      _buildNavItem(index: 3, icon: Icons.settings_rounded, label: 'Pengaturan', primaryColor: primaryColor),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color primaryColor,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? primaryColor : Colors.grey.shade400,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
