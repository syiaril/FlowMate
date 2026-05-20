import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cima_mens/providers/settings_provider.dart';
import 'package:cima_mens/screens/home_screen.dart';
import 'package:cima_mens/widgets/pastel_button.dart';

/// OnboardingScreen — Layar onboarding dengan 3 halaman PageView.
/// Halaman 1: Selamat datang
/// Halaman 2: Fitur-fitur
/// Halaman 3: Tombol mulai
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Selesai onboarding → simpan ke settings & navigasi
  Future<void> _completeOnboarding() async {
    await context.read<SettingsProvider>().setOnboardingDone(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // PageView utama
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildWelcomePage(primaryColor),
                  _buildFeaturesPage(primaryColor),
                  _buildGetStartedPage(primaryColor),
                ],
              ),
            ),

            // Dot indicator & tombol
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 28 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? primaryColor
                              : primaryColor.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Tombol navigasi
                  if (_currentPage < 2)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            'Lewati',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        PastelButton(
                          text: 'Lanjut',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: PastelButton(
                        text: 'Mulai Sekarang',
                        icon: Icons.favorite_rounded,
                        onPressed: _completeOnboarding,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Halaman 1 — Selamat datang
  Widget _buildWelcomePage(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ikon utama
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.3),
                  primaryColor.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_rounded,
              size: 60,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 36),

          // Judul
          Text(
            'FlowMate',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Tagline
          Text(
            'Teman setia untuk memahami\nsiklus menstruasi kamu 💕',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Halaman 2 — Fitur-fitur
  Widget _buildFeaturesPage(Color primaryColor) {
    final features = [
      {
        'icon': Icons.calendar_month_rounded,
        'title': 'Kalender Siklus',
        'desc': 'Lacak siklus haid dan prediksi tanggal berikutnya',
      },
      {
        'icon': Icons.emoji_emotions_rounded,
        'title': 'Mood Tracker',
        'desc': 'Catat mood dan gejala harian kamu',
      },
      {
        'icon': Icons.bar_chart_rounded,
        'title': 'Grafik & Statistik',
        'desc': 'Lihat pola siklus kamu dari waktu ke waktu',
      },
      {
        'icon': Icons.notifications_active_rounded,
        'title': 'Pengingat',
        'desc': 'Dapatkan notifikasi sebelum haid tiba',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Fitur Utama',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        f['icon'] as IconData,
                        color: primaryColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            f['desc'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Halaman 3 — Mulai sekarang
  Widget _buildGetStartedPage(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ikon siap
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.25),
                  primaryColor.withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rocket_launch_rounded,
              size: 56,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 36),

          Text(
            'Siap Memulai?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Data kamu tersimpan aman di perangkat.\nTidak ada yang dikirim ke server manapun. 🔒',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
