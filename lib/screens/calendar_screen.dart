import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cima_mens/providers/cycle_provider.dart';
import 'package:cima_mens/utils/date_utils.dart';
import 'package:cima_mens/widgets/phase_indicator.dart';
import 'package:cima_mens/widgets/stat_card.dart';
import 'package:cima_mens/screens/input_cycle_screen.dart';

/// CalendarScreen — Tab Beranda utama.
/// Menampilkan TableCalendar dengan marking hari haid/fertile/ovulasi,
/// PhaseIndicator, dan StatCards ringkasan siklus.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final primaryColor = Theme.of(context).colorScheme.primary;
    final hasCycles = cycleProvider.cycles.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cima Mens',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: primaryColor,
              ),
            ),
            Text(
              FlowDateUtils.formatDate(DateTime.now()),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: hasCycles ? _buildContent(cycleProvider, primaryColor) : _buildEmptyState(primaryColor),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openInputCycle(context),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Tambah Siklus',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Konten utama ketika sudah ada data siklus
  Widget _buildContent(CycleProvider cycleProvider, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        children: [
          // Kalender
          _buildCalendar(cycleProvider, primaryColor),
          const SizedBox(height: 20),

          // Indikator fase
          PhaseIndicator(phase: cycleProvider.currentPhase),
          const SizedBox(height: 24),

          // Stat cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Panjang Siklus',
                    value: '${cycleProvider.avgCycleLength.round()}',
                    icon: Icons.loop_rounded,
                    color: const Color(0xFF81C784),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Lama Haid',
                    value: '${cycleProvider.avgPeriodLength.round()}',
                    icon: Icons.water_drop_rounded,
                    color: const Color(0xFFFF8FAB),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Sisa Hari',
                    value: '${cycleProvider.daysUntilNextPeriod}',
                    icon: Icons.timer_rounded,
                    color: const Color(0xFF64B5F6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Info fertile window
          if (cycleProvider.fertileStart != null &&
              cycleProvider.fertileEnd != null)
            _buildInfoCard(
              icon: Icons.spa_rounded,
              title: 'Jendela Subur',
              value:
                  '${FlowDateUtils.formatDateShort(cycleProvider.fertileStart!)} - ${FlowDateUtils.formatDateShort(cycleProvider.fertileEnd!)}',
              color: const Color(0xFF81C784),
            ),

          if (cycleProvider.nextPeriodDate != null)
            _buildInfoCard(
              icon: Icons.event_rounded,
              title: 'Haid Berikutnya',
              value: FlowDateUtils.formatDate(cycleProvider.nextPeriodDate!),
              color: const Color(0xFFFF8FAB),
            ),
        ],
      ),
    );
  }

  /// Membangun TableCalendar dengan custom day builders
  Widget _buildCalendar(CycleProvider cycleProvider, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        locale: 'id_ID',
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        // Styling header
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: primaryColor,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: primaryColor,
          ),
        ),
        // Styling hari
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryColor, width: 2),
          ),
          todayTextStyle: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
          selectedDecoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
          defaultTextStyle: TextStyle(color: Colors.grey.shade700),
          weekendTextStyle: TextStyle(color: Colors.grey.shade500),
        ),
        // Custom day builder untuk marking hari-hari khusus
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, cycleProvider);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, cycleProvider, isToday: true);
          },
        ),
      ),
    );
  }

  /// Membangun sel hari kalender dengan marking warna
  Widget? _buildDayCell(DateTime day, CycleProvider cycleProvider,
      {bool isToday = false}) {
    final latestCycle = cycleProvider.latestCycle;
    if (latestCycle == null) return null;

    final dayOnly = DateTime(day.year, day.month, day.day);
    final startOnly = DateTime(
        latestCycle.startDate.year,
        latestCycle.startDate.month,
        latestCycle.startDate.day);

    // Cek apakah hari ini masuk ke hari haid
    final periodEnd = startOnly.add(Duration(days: latestCycle.periodLength));
    final isPeriodDay =
        !dayOnly.isBefore(startOnly) && dayOnly.isBefore(periodEnd);

    // Cek hari ovulasi
    final ovDay = DateTime(latestCycle.ovulationDate.year,
        latestCycle.ovulationDate.month, latestCycle.ovulationDate.day);
    final isOvulationDay = dayOnly.isAtSameMomentAs(ovDay);

    // Cek jendela subur
    final fertStart = DateTime(latestCycle.fertileStart.year,
        latestCycle.fertileStart.month, latestCycle.fertileStart.day);
    final fertEnd = DateTime(latestCycle.fertileEnd.year,
        latestCycle.fertileEnd.month, latestCycle.fertileEnd.day);
    final isFertileDay = !dayOnly.isBefore(fertStart) &&
        !dayOnly.isAfter(fertEnd) &&
        !isOvulationDay;

    Color? bgColor;
    Color textColor = Colors.grey.shade700;

    if (isPeriodDay) {
      bgColor = const Color(0xFFFFB5C2); // pink
      textColor = Colors.white;
    } else if (isOvulationDay) {
      bgColor = const Color(0xFF64B5F6); // biru
      textColor = Colors.white;
    } else if (isFertileDay) {
      bgColor = const Color(0xFFA5D6A7); // hijau muda
      textColor = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(
                color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: bgColor != null ? textColor : (isToday ? Theme.of(context).colorScheme.primary : Colors.grey.shade700),
            fontWeight: (isToday || bgColor != null)
                ? FontWeight.bold
                : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// Kartu info kecil (fertile window, next period)
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Empty state ketika belum ada siklus
  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                size: 56,
                color: primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Belum Ada Data Siklus',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Mulai lacak siklus menstruasi kamu\ndengan menambahkan data pertama.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => _openInputCycle(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Siklus Pertama'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Buka halaman input siklus
  void _openInputCycle(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const InputCycleScreen()),
    );
  }
}
