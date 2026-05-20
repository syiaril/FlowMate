import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cima_mens/models/cycle_model.dart';
import 'package:cima_mens/providers/cycle_provider.dart';
import 'package:cima_mens/services/notification_service.dart';
import 'package:cima_mens/utils/constants.dart';
import 'package:cima_mens/utils/date_utils.dart';
import 'package:cima_mens/widgets/pastel_button.dart';

/// InputCycleScreen — Formulir untuk menambahkan data siklus baru.
/// Menampilkan date picker, slider lama haid & panjang siklus,
/// preview prediksi, dan tombol simpan.
class InputCycleScreen extends StatefulWidget {
  const InputCycleScreen({super.key});

  @override
  State<InputCycleScreen> createState() => _InputCycleScreenState();
}

class _InputCycleScreenState extends State<InputCycleScreen> {
  DateTime _startDate = DateTime.now();
  int _periodLength = FlowMateConstants.defaultPeriodLength;
  int _cycleLength = FlowMateConstants.defaultCycleLength;

  /// Hitung prediksi berdasarkan input
  DateTime get _nextPeriod => _startDate.add(Duration(days: _cycleLength));
  DateTime get _ovulation => _nextPeriod.subtract(const Duration(days: 14));
  DateTime get _fertileStart => _ovulation.subtract(const Duration(days: 5));
  DateTime get _fertileEnd => _ovulation.add(const Duration(days: 1));

  /// Pilih tanggal mulai haid
  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Mulai Haid',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  /// Simpan data siklus
  Future<void> _saveCycle() async {
    final cycle = CycleModel(
      userId: 'offline_default', // Handled by Supabase auth if needed
      id: const Uuid().v4(),
      startDate: _startDate,
      periodLength: _periodLength,
      cycleLength: _cycleLength,
    );

    await context.read<CycleProvider>().saveCycle(cycle);

    // Jadwalkan pengingat notifikasi
    try {
      await NotificationService.instance.schedulePeriodReminder(cycle.nextPeriodDate);
    } catch (_) {
      // Notifikasi opsional, jangan crash jika gagal
    }

    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Siklus berhasil disimpan! 🎉'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Tambah Siklus',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Tanggal Mulai =====
            _buildSectionCard(
              title: 'Tanggal Mulai Haid',
              icon: Icons.calendar_today_rounded,
              primaryColor: primaryColor,
              child: InkWell(
                onTap: _pickStartDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_rounded,
                          color: primaryColor, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        FlowDateUtils.formatDate(_startDate),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.edit_calendar_rounded,
                          color: primaryColor.withOpacity(0.5), size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ===== Lama Haid =====
            _buildSectionCard(
              title: 'Lama Haid',
              icon: Icons.water_drop_rounded,
              primaryColor: primaryColor,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_periodLength hari',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        '1 — 10 hari',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _periodLength.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: primaryColor,
                    inactiveColor: primaryColor.withOpacity(0.15),
                    label: '$_periodLength hari',
                    onChanged: (val) {
                      setState(() => _periodLength = val.round());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== Panjang Siklus =====
            _buildSectionCard(
              title: 'Panjang Siklus',
              icon: Icons.loop_rounded,
              primaryColor: primaryColor,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_cycleLength hari',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        '20 — 45 hari',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _cycleLength.toDouble(),
                    min: 20,
                    max: 45,
                    divisions: 25,
                    activeColor: primaryColor,
                    inactiveColor: primaryColor.withOpacity(0.15),
                    label: '$_cycleLength hari',
                    onChanged: (val) {
                      setState(() => _cycleLength = val.round());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== Preview Prediksi =====
            _buildSectionCard(
              title: 'Prediksi',
              icon: Icons.auto_awesome_rounded,
              primaryColor: primaryColor,
              child: Column(
                children: [
                  _predictionRow(
                    'Haid Berikutnya',
                    FlowDateUtils.formatDate(_nextPeriod),
                    Icons.event_rounded,
                    const Color(0xFFFF8FAB),
                  ),
                  const SizedBox(height: 10),
                  _predictionRow(
                    'Ovulasi',
                    FlowDateUtils.formatDate(_ovulation),
                    Icons.star_rounded,
                    const Color(0xFF64B5F6),
                  ),
                  const SizedBox(height: 10),
                  _predictionRow(
                    'Jendela Subur',
                    '${FlowDateUtils.formatDateShort(_fertileStart)} - ${FlowDateUtils.formatDateShort(_fertileEnd)}',
                    Icons.spa_rounded,
                    const Color(0xFF81C784),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ===== Tombol Simpan =====
            SizedBox(
              width: double.infinity,
              child: PastelButton(
                text: 'Simpan Siklus',
                icon: Icons.check_rounded,
                onPressed: _saveCycle,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Baris prediksi
  Widget _predictionRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
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
            color: primaryColor.withOpacity(0.06),
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
