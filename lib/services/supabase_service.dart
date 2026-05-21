import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cycle_model.dart';
import '../models/mood_model.dart';

class SupabaseService {
  SupabaseService._internal();
  static final SupabaseService _instance = SupabaseService._internal();
  static SupabaseService get instance => _instance;

  final SupabaseClient _supabase = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // Cycles
  // ---------------------------------------------------------------------------

  Future<List<CycleModel>> getCycles() async {
    try {
      // get_my_partner_id() is checked via RLS, but we just query all we have access to
      final response = await _supabase
          .from('menstrual_cycles')
          .select()
          .order('start_date', ascending: false);
      
      return (response as List<dynamic>)
          .map((data) => CycleModel.fromJson(data))
          .toList();
    } catch (e) {
      print('Error fetching cycles: $e');
      return [];
    }
  }

  Future<void> saveCycle(CycleModel cycle) async {
    try {
      await _supabase.from('menstrual_cycles').insert(cycle.toInsertJson());
    } catch (e) {
      print('Error saving cycle: $e');
      rethrow;
    }
  }

  Future<void> deleteCycle(String id) async {
    try {
      await _supabase.from('menstrual_cycles').delete().eq('id', id);
    } catch (e) {
      print('Error deleting cycle: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Moods & Symptoms
  // ---------------------------------------------------------------------------

  Future<List<MoodEntry>> getMoods() async {
    try {
      final response = await _supabase
          .from('moods')
          .select('*, symptoms(*)')
          .order('created_at', ascending: false);

      final moods = (response as List<dynamic>)
          .map((data) => MoodEntry.fromJson(data))
          .toList();

      return moods;
    } catch (e) {
      print('Error fetching moods: $e');
      return [];
    }
  }

  Future<void> saveMood(MoodEntry entry) async {
    try {
      final insertedMood = await _supabase
          .from('moods')
          .insert(entry.toInsertJson())
          .select()
          .single();
      
      final moodId = insertedMood['id'] as String;
      
      // If there are symptoms, save them to the symptoms table
      if (entry.symptoms.isNotEmpty) {
        final symptomRows = entry.symptoms.map((s) => {
          'symptom': s,
          'mood_id': moodId,
        }).toList();
        await _supabase.from('symptoms').insert(symptomRows);
      }
    } catch (e) {
      print('Error saving mood: $e');
      rethrow;
    }
  }

  Future<void> deleteMood(String id) async {
    try {
      await _supabase.from('moods').delete().eq('id', id);
    } catch (e) {
      print('Error deleting mood: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Profile / Connection
  // ---------------------------------------------------------------------------

  Future<void> updatePartnerId(String partnerId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('profiles')
          .update({'partner_id': partnerId})
          .eq('id', userId);
    } catch (e) {
      print('Error updating partner ID: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Partner Messages (Nudges)
  // ---------------------------------------------------------------------------

  Future<void> sendPartnerMessage(String receiverId, String message) async {
    try {
      final senderId = _supabase.auth.currentUser?.id;
      if (senderId == null) return;

      await _supabase.from('partner_messages').insert({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message': message,
      });
    } catch (e) {
      print('Error sending partner message: $e');
      rethrow;
    }
  }
}
