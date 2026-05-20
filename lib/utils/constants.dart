import 'package:flutter/material.dart';

/// Application-wide constants, color palettes, mood/symptom lists,
/// and default values for the FlowMate app.
class FlowMateConstants {
  FlowMateConstants._(); // prevent instantiation

  // ──────────────────────────────────────────────
  // App info
  // ──────────────────────────────────────────────
  static const String appName = 'cima mens';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Kalender Menstruasi Pintar';

  // ──────────────────────────────────────────────
  // Default cycle values
  // ──────────────────────────────────────────────
  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;
  static const int minCycleLength = 21;
  static const int maxCycleLength = 45;
  static const int minPeriodLength = 2;
  static const int maxPeriodLength = 10;

  // ──────────────────────────────────────────────
  // Theme color palettes
  // ──────────────────────────────────────────────

  /// Pink theme (default)
  static const Map<String, Color> pinkPalette = {
    'primary': Color(0xFFE91E63),
    'primaryLight': Color(0xFFF8BBD0),
    'primaryDark': Color(0xFFC2185B),
    'accent': Color(0xFFFF80AB),
    'background': Color(0xFFFCE4EC),
    'surface': Color(0xFFFFFFFF),
    'card': Color(0xFFFFF0F5),
    'onPrimary': Color(0xFFFFFFFF),
    'onBackground': Color(0xFF37474F),
    'textPrimary': Color(0xFF212121),
    'textSecondary': Color(0xFF757575),
  };

  /// Peach theme
  static const Map<String, Color> peachPalette = {
    'primary': Color(0xFFFF8A65),
    'primaryLight': Color(0xFFFFCCBC),
    'primaryDark': Color(0xFFE64A19),
    'accent': Color(0xFFFFAB91),
    'background': Color(0xFFFBE9E7),
    'surface': Color(0xFFFFFFFF),
    'card': Color(0xFFFFF3E0),
    'onPrimary': Color(0xFFFFFFFF),
    'onBackground': Color(0xFF37474F),
    'textPrimary': Color(0xFF212121),
    'textSecondary': Color(0xFF757575),
  };

  /// Lavender theme
  static const Map<String, Color> lavenderPalette = {
    'primary': Color(0xFF9575CD),
    'primaryLight': Color(0xFFD1C4E9),
    'primaryDark': Color(0xFF512DA8),
    'accent': Color(0xFFB39DDB),
    'background': Color(0xFFEDE7F6),
    'surface': Color(0xFFFFFFFF),
    'card': Color(0xFFF3E5F5),
    'onPrimary': Color(0xFFFFFFFF),
    'onBackground': Color(0xFF37474F),
    'textPrimary': Color(0xFF212121),
    'textSecondary': Color(0xFF757575),
  };

  /// Get the palette map for a given theme key.
  static Map<String, Color> getPalette(String themeColor) {
    switch (themeColor) {
      case 'peach':
        return peachPalette;
      case 'lavender':
        return lavenderPalette;
      case 'pink':
      default:
        return pinkPalette;
    }
  }

  // ──────────────────────────────────────────────
  // Mood options (with emojis)
  // ──────────────────────────────────────────────

  static const List<Map<String, String>> moods = [
    {'label': 'Senang', 'emoji': 'https://zrbeutvkhdhiulxdiqzh.supabase.co/storage/v1/object/public/emojis/emoji_1.png'},
    {'label': 'Biasa', 'emoji': 'https://zrbeutvkhdhiulxdiqzh.supabase.co/storage/v1/object/public/emojis/emoji_2.png'},
    {'label': 'Sedih', 'emoji': 'https://zrbeutvkhdhiulxdiqzh.supabase.co/storage/v1/object/public/emojis/emoji_3.png'},
    {'label': 'Marah', 'emoji': 'https://zrbeutvkhdhiulxdiqzh.supabase.co/storage/v1/object/public/emojis/emoji_4.png'},
    {'label': 'Cemas', 'emoji': 'https://zrbeutvkhdhiulxdiqzh.supabase.co/storage/v1/object/public/emojis/emoji_10.png'},
    {'label': 'Lelah', 'emoji': 'https://zrbeutvkhdhiulxdiqzh.supabase.co/storage/v1/object/public/emojis/emoji_6.png'},
    {'label': 'Energik', 'emoji': 'https://zrbeutvkhdhiulxdiqzh.supabase.co/storage/v1/object/public/emojis/emoji_7.png'},
    {'label': 'Sensitif', 'emoji': 'https://zrbeutvkhdhiulxdiqzh.supabase.co/storage/v1/object/public/emojis/emoji_5.png'},
    {'label': 'Romantis', 'emoji': 'https://zrbeutvkhdhiulxdiqzh.supabase.co/storage/v1/object/public/emojis/emoji_9.png'},
    {'label': 'Bingung', 'emoji': 'https://zrbeutvkhdhiulxdiqzh.supabase.co/storage/v1/object/public/emojis/emoji_8.png'},
  ];

  /// Get the emoji for a mood label.
  static String getMoodEmoji(String mood) {
    final match = moods.firstWhere(
      (m) => m['label'] == mood,
      orElse: () => {'label': mood, 'emoji': 'https://zrbeutvkhdhiulxdiqzh.supabase.co/storage/v1/object/public/emojis/emoji_1.png'},
    );
    return match['emoji']!;
  }

  // ──────────────────────────────────────────────
  // Symptom options
  // ──────────────────────────────────────────────

  static const List<String> symptoms = [
    'Kram Perut',
    'Sakit Kepala',
    'Sakit Punggung',
    'Kembung',
    'Jerawat',
    'Nyeri Payudara',
    'Mual',
    'Pusing',
    'Insomnia',
    'Nafsu Makan Meningkat',
    'Nafsu Makan Menurun',
    'Diare',
    'Sembelit',
    'Kelelahan',
    'Mood Swing',
  ];

  // ──────────────────────────────────────────────
  // Phase labels & descriptions (Bahasa Indonesia)
  // ──────────────────────────────────────────────

  static const Map<String, String> phaseLabels = {
    'menstruasi': 'Menstruasi',
    'folikular': 'Folikular',
    'ovulasi': 'Ovulasi',
    'luteal': 'Luteal',
  };

  static const Map<String, String> phaseDescriptions = {
    'menstruasi': 'Fase menstruasi — tubuhmu sedang membersihkan diri.',
    'folikular':
        'Fase folikular — energi meningkat, tubuh mempersiapkan ovulasi.',
    'ovulasi':
        'Fase ovulasi — masa subur, sel telur dilepaskan dari ovarium.',
    'luteal':
        'Fase luteal — tubuh bersiap untuk menstruasi berikutnya.',
  };

  static const Map<String, String> phaseEmojis = {
    'menstruasi': '🔴',
    'folikular': '🌱',
    'ovulasi': '🥚',
    'luteal': '🌙',
  };

  static const Map<String, Color> phaseColors = {
    'menstruasi': Color(0xFFEF5350),
    'folikular': Color(0xFF66BB6A),
    'ovulasi': Color(0xFFFFCA28),
    'luteal': Color(0xFF7E57C2),
  };

  // ──────────────────────────────────────────────
  // UI Strings (Bahasa Indonesia)
  // ──────────────────────────────────────────────

  static const String strWelcome = 'Selamat Datang di FlowMate!';
  static const String strOnboardingSubtitle =
      'Kalender menstruasi pribadimu yang aman dan mudah digunakan.';
  static const String strStartTracking = 'Mulai Pencatatan';
  static const String strAddPeriod = 'Tambah Menstruasi';
  static const String strAddMood = 'Tambah Mood';
  static const String strSettings = 'Pengaturan';
  static const String strHistory = 'Riwayat';
  static const String strStatistics = 'Statistik';
  static const String strExportData = 'Ekspor Data';
  static const String strClearData = 'Hapus Semua Data';
  static const String strConfirmClear =
      'Apakah kamu yakin ingin menghapus semua data?';
  static const String strCancel = 'Batal';
  static const String strConfirm = 'Konfirmasi';
  static const String strSave = 'Simpan';
  static const String strDelete = 'Hapus';
  static const String strNoData = 'Belum ada data';
  static const String strDaysUntilPeriod = 'hari lagi menstruasi';
  static const String strOnPeriod = 'Sedang menstruasi';
  static const String strSelectDate = 'Pilih Tanggal';
  static const String strPeriodLength = 'Lama Menstruasi (hari)';
  static const String strCycleLength = 'Panjang Siklus (hari)';
  static const String strTheme = 'Tema Warna';
  static const String strNotifications = 'Notifikasi';
  static const String strAbout = 'Tentang Aplikasi';
  static const String strNextPeriod = 'Menstruasi Berikutnya';
  static const String strOvulation = 'Ovulasi';
  static const String strFertileWindow = 'Masa Subur';
  static const String strCurrentPhase = 'Fase Saat Ini';
}
