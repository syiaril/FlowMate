import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class RealtimeService {
  RealtimeService._internal();
  static final RealtimeService _instance = RealtimeService._internal();
  static RealtimeService get instance => _instance;

  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _moodChannel;

  /// Starts listening to real-time changes on the 'moods' table
  void startListening(Function onUpdate) {
    if (_moodChannel != null) return;

    _moodChannel = _supabase.channel('public:moods').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'moods',
      callback: (payload) {
        // When there is an INSERT, trigger a notification for the Admin
        if (payload.eventType == PostgresChangeEvent.insert) {
          final newMood = payload.newRecord['mood'] as String?;
          final userId = payload.newRecord['user_id'] as String?;
          
          // Basic logic to prevent notifying self
          // Ideally we check if we are the admin and the user_id belongs to the partner
          if (userId != null && userId != _supabase.auth.currentUser?.id) {
            NotificationService.instance.showNotification(
              id: payload.newRecord['id'].hashCode,
              title: 'Update Mood Partner',
              body: 'Partner Anda menambahkan mood baru: $newMood',
            );
          }
        }
        
        // Notify listeners (providers) to fetch the latest data
        onUpdate();
      },
    )..subscribe();
  }

  void stopListening() {
    _moodChannel?.unsubscribe();
    _moodChannel = null;
  }
}
