import 'package:flutter/material.dart';
import '../models/mood_model.dart';
import '../services/supabase_service.dart';
import '../services/realtime_service.dart';

class MoodProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;
  List<MoodEntry> _entries = [];
  List<Map<String, dynamic>> _imageMoods = [];
  bool _isLoading = false;

  List<MoodEntry> get entries => _entries;
  List<Map<String, dynamic>> get imageMoods => _imageMoods;
  bool get isLoading => _isLoading;

  MoodProvider() {
    RealtimeService.instance.startListening(() {
      loadEntries();
    });
  }

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (_imageMoods.isEmpty) {
        _imageMoods = await _supabaseService.getImageMoods();
      }
      _entries = await _supabaseService.getMoods();
    } catch (e) {
      print('Error loading entries: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  MoodEntry? getEntryForDate(DateTime date) {
    try {
      return _entries.firstWhere((e) =>
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day);
    } catch (_) {
      return null;
    }
  }


  List<MoodEntry> getEntriesForDate(DateTime date) {
    return _entries.where((e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day).toList();
  }

  Future<void> saveMood(MoodEntry entry) async {
    await _supabaseService.saveMood(entry);
    await loadEntries();
  }

  Future<void> deleteMood(String id) async {
    await _supabaseService.deleteMood(id);
    await loadEntries();
  }
  
  @override
  void dispose() {
    RealtimeService.instance.stopListening();
    super.dispose();
  }
}
