import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cima_mens/models/mood_model.dart';
import 'package:cima_mens/providers/mood_provider.dart';
import 'package:cima_mens/utils/date_utils.dart';
import 'package:cima_mens/widgets/mood_emoji_picker.dart';
import 'package:cima_mens/widgets/symptom_chip.dart';
import 'package:cima_mens/widgets/pastel_button.dart';

/// MoodScreen — Tab Mood Tracker.
/// Memungkinkan user mencatat mood, gejala, dan catatan harian.
class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedMood;
  List<String> _selectedSymptoms = [];
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Pilih tanggal
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Simpan mood entry
  Future<void> _saveMood() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih mood kamu dulu ya! 😊'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final entry = MoodEntry(
      userId: 'offline_default', // Handled by Supabase auth if needed
      id: const Uuid().v4(),
      date: _selectedDate,
      mood: _selectedMood!,
      symptoms: List<String>.from(_selectedSymptoms),
      note: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    await context.read<MoodProvider>().saveMood(entry);

    // Reset form
    setState(() {
      _selectedMood = null;
      _selectedSymptoms = [];
      _notesController.clear();
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Mood berhasil dicatat! 🎉'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Dialog konfirmasi hapus mood
  Future<void> _confirmDeleteMood(BuildContext context, String entryId, MoodProvider moodProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade400,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                'Hapus Catatan?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus catatan mood ini? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade600,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                'Ya, Hapus',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await moodProvider.deleteMood(entryId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Catatan mood berhasil dihapus. 🗑️'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider>();
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Ambil entry untuk tanggal yang dipilih
    final todayEntries = moodProvider.getEntriesForDate(_selectedDate);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mood Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Pemilih Tanggal =====
            _buildDateSelector(primaryColor),
            const SizedBox(height: 20),

            // ===== Mood Picker =====
            _buildSectionCard(
              title: 'Bagaimana Mood Kamu?',
              icon: Icons.emoji_emotions_rounded,
              primaryColor: primaryColor,
              child: MoodEmojiPicker(
                selectedMood: _selectedMood,
                onSelected: (mood) {
                  setState(() => _selectedMood = mood);
                },
              ),
            ),
            const SizedBox(height: 16),

            // ===== Gejala =====
            _buildSectionCard(
              title: 'Gejala yang Dirasakan',
              icon: Icons.healing_rounded,
              primaryColor: primaryColor,
              child: SymptomChips(
                selected: _selectedSymptoms,
                onChanged: (symptoms) {
                  setState(() => _selectedSymptoms = symptoms);
                },
              ),
            ),
            const SizedBox(height: 16),

            // ===== Catatan =====
            _buildSectionCard(
              title: 'Catatan',
              icon: Icons.edit_note_rounded,
              primaryColor: primaryColor,
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tulis catatan tambahan...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: primaryColor.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== Tombol Simpan =====
            SizedBox(
              width: double.infinity,
              child: PastelButton(
                text: 'Simpan Mood',
                icon: Icons.check_rounded,
                onPressed: _saveMood,
              ),
            ),
            const SizedBox(height: 28),

            // ===== Daftar Mood Hari Ini =====
            if (todayEntries.isNotEmpty) ...[
              Text(
                'Catatan ${FlowDateUtils.formatDateShort(_selectedDate)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              ...todayEntries.map((entry) => _buildMoodEntryCard(
                    entry,
                    primaryColor,
                    moodProvider,
                  )),
            ],
          ],
        ),
      ),
    );
  }

  /// Pemilih tanggal horizontal
  Widget _buildDateSelector(Color primaryColor) {
    final today = DateTime.now();
    // Tampilkan 7 hari terakhir
    final days = List.generate(7, (i) {
      return today.subtract(Duration(days: 6 - i));
    });

    const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Tombol kalender untuk tanggal lain
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: 36,
              height: 52,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: primaryColor,
                size: 20,
              ),
            ),
          ),
          // Hari-hari
          ...days.map((day) {
            final isSelected = _selectedDate.year == day.year &&
                _selectedDate.month == day.month &&
                _selectedDate.day == day.day;
            final isToday = today.year == day.year &&
                today.month == day.month &&
                today.day == day.day;

            return GestureDetector(
              onTap: () => setState(() => _selectedDate = day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dayNames[day.weekday - 1],
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? Colors.white
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isToday
                                ? primaryColor
                                : Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Kartu mood entry yang sudah dicatat
  Widget _buildMoodEntryCard(
      MoodEntry entry, Color primaryColor, MoodProvider moodProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji mood & Jam pencatatan
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              entry.mood.startsWith('http')
                  ? Image.network(entry.mood, width: 36, height: 36, fit: BoxFit.contain)
                  : Text(entry.mood, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Text(
                  FlowDateUtils.formatTime(entry.date),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.symptoms.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: entry.symptoms.map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 11,
                            color: primaryColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                if (entry.note != null && entry.note!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    entry.note!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Tombol hapus
          IconButton(
            onPressed: () => _confirmDeleteMood(context, entry.id, moodProvider),
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: Colors.grey.shade400,
            ),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  /// Card section builder
  Widget _buildSectionCard({
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
