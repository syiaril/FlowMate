import 'package:flutter/material.dart';
import '../models/cycle_model.dart';
import '../services/supabase_service.dart';

class CycleProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;
  List<CycleModel> _cycles = [];

  List<CycleModel> get cycles => _cycles;
  CycleModel? get currentCycle => _cycles.isNotEmpty ? _cycles.first : null;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadCycles() async {
    _isLoading = true;
    notifyListeners();
    
    _cycles = await _supabaseService.getCycles();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveCycle(CycleModel cycle) async {
    await _supabaseService.saveCycle(cycle);
    await loadCycles();
  }

  Future<void> deleteCycle(String id) async {
    await _supabaseService.deleteCycle(id);
    await loadCycles();
  }


  CycleModel? get latestCycle => currentCycle;

  int get avgCycleLength {
    if (_cycles.isEmpty) return 28;
    int total = _cycles.fold(0, (sum, c) => sum + c.cycleLength);
    return total ~/ _cycles.length;
  }

  int get avgPeriodLength {
    if (_cycles.isEmpty) return 5;
    int total = _cycles.fold(0, (sum, c) => sum + c.periodLength);
    return total ~/ _cycles.length;
  }

  DateTime? get nextPeriodDate => currentCycle?.nextPeriodDate;
  DateTime? get fertileStart => currentCycle?.fertileStart;
  DateTime? get fertileEnd => currentCycle?.fertileEnd;

  int get daysUntilNextPeriod {
    if (nextPeriodDate == null) return 0;
    return nextPeriodDate!.difference(DateTime.now()).inDays;
  }

  String get currentPhase {
    if (currentCycle == null) return '';

    final now = DateTime.now();
    final start = currentCycle!.startDate;
    final cycleLength = currentCycle!.cycleLength;
    final periodLength = currentCycle!.periodLength;

    final daysSinceStart = now.difference(start).inDays;

    if (daysSinceStart < 0) return ''; 

    final currentCycleDay = (daysSinceStart % cycleLength) + 1;

    if (currentCycleDay <= periodLength) return 'menstruasi';
    if (currentCycleDay > periodLength && currentCycleDay <= cycleLength - 14 - 3) return 'folikular';
    if (currentCycleDay > cycleLength - 14 - 3 && currentCycleDay <= cycleLength - 14 + 1) return 'ovulasi';
    return 'luteal';
  }
}
