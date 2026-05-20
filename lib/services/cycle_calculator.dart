import 'package:cima_mens/models/cycle_model.dart';

/// Static utility class for menstrual cycle calculations.
///
/// All methods are pure functions — they take input data and return
/// computed results without side effects.
class CycleCalculator {
  CycleCalculator._(); // prevent instantiation

  // ──────────────────────────────────────────────
  // Core date predictions
  // ──────────────────────────────────────────────

  /// Compute the predicted start date of the next period.
  static DateTime computeNextPeriod(DateTime lastPeriodStart, int cycleLength) {
    return lastPeriodStart.add(Duration(days: cycleLength));
  }

  /// Compute the predicted ovulation date.
  /// Ovulation typically occurs 14 days before the next period.
  static DateTime computeOvulation(DateTime lastPeriodStart, int cycleLength) {
    return lastPeriodStart.add(Duration(days: cycleLength - 14));
  }

  /// Compute the fertile window as a (start, end) pair.
  /// Fertile window: 5 days before ovulation → 1 day after ovulation.
  static ({DateTime start, DateTime end}) computeFertileWindow(
    DateTime lastPeriodStart,
    int cycleLength,
  ) {
    final ovulation = computeOvulation(lastPeriodStart, cycleLength);
    return (
      start: ovulation.subtract(const Duration(days: 5)),
      end: ovulation.add(const Duration(days: 1)),
    );
  }

  // ──────────────────────────────────────────────
  // Countdown helpers
  // ──────────────────────────────────────────────

  /// Number of days until the next predicted period from [today].
  /// Returns 0 if the next period date is today, negative if overdue.
  static int daysUntilNextPeriod(
    DateTime lastPeriodStart,
    int cycleLength, {
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();
    final nextPeriod = computeNextPeriod(lastPeriodStart, cycleLength);
    return _daysBetween(
      DateTime(now.year, now.month, now.day),
      DateTime(nextPeriod.year, nextPeriod.month, nextPeriod.day),
    );
  }

  // ──────────────────────────────────────────────
  // Phase detection
  // ──────────────────────────────────────────────

  /// Determine the current menstrual phase relative to [today].
  ///
  /// Returns one of:
  /// - `'menstruasi'`  — bleeding phase (day 1 → periodLength)
  /// - `'folikular'`   — follicular phase (after period → before fertile)
  /// - `'ovulasi'`     — ovulation / fertile window
  /// - `'luteal'`      — luteal phase (after ovulation → before next period)
  static String getCurrentPhase(
    DateTime lastPeriodStart,
    int periodLength,
    int cycleLength, {
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();

    // Normalize to date-only
    final start = DateTime(
      lastPeriodStart.year,
      lastPeriodStart.month,
      lastPeriodStart.day,
    );
    final current = DateTime(now.year, now.month, now.day);

    // Day in current cycle (0-indexed)
    int dayInCycle = _daysBetween(start, current) % cycleLength;
    if (dayInCycle < 0) dayInCycle += cycleLength;

    // Phase boundaries
    final periodEnd = periodLength; // exclusive
    final fertileStart = cycleLength - 19;
    final ovulationDay = cycleLength - 14;
    final fertileEnd = cycleLength - 13; // inclusive

    if (dayInCycle < periodEnd) {
      return 'menstruasi';
    } else if (dayInCycle < fertileStart) {
      return 'folikular';
    } else if (dayInCycle <= fertileEnd) {
      // Within fertile window — distinguish ovulation day
      return (dayInCycle == ovulationDay) ? 'ovulasi' : 'ovulasi';
    } else {
      return 'luteal';
    }
  }

  // ──────────────────────────────────────────────
  // Statistical helpers
  // ──────────────────────────────────────────────

  /// Calculate the average cycle length from a list of cycles.
  /// Cycles should be sorted by startDate ascending.
  /// Returns the default (28) if fewer than 2 cycles are available.
  static double getAverageCycleLength(List<CycleModel> cycles) {
    if (cycles.length < 2) return 28.0;

    // Sort ascending by startDate
    final sorted = List<CycleModel>.from(cycles)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    double totalDays = 0;
    int count = 0;
    for (int i = 1; i < sorted.length; i++) {
      final diff = _daysBetween(sorted[i - 1].startDate, sorted[i].startDate);
      if (diff > 0 && diff <= 60) {
        // Only consider reasonable cycle lengths
        totalDays += diff;
        count++;
      }
    }

    return count > 0 ? totalDays / count : 28.0;
  }

  /// Calculate the average period (bleeding) length.
  /// Returns the default (5) if no cycles are available.
  static double getAveragePeriodLength(List<CycleModel> cycles) {
    if (cycles.isEmpty) return 5.0;

    final total = cycles.fold<int>(
      0,
      (sum, cycle) => sum + cycle.periodLength,
    );
    return total / cycles.length;
  }

  // ──────────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────────

  /// Days between two dates (ignoring time). Positive if [to] is after [from].
  static int _daysBetween(DateTime from, DateTime to) {
    final f = DateTime(from.year, from.month, from.day);
    final t = DateTime(to.year, to.month, to.day);
    return t.difference(f).inDays;
  }
}
