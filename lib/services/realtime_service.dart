import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class RealtimeService {
  RealtimeService._internal();
  static final RealtimeService _instance = RealtimeService._internal();
  static RealtimeService get instance => _instance;

  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _moodChannel;
  RealtimeChannel? _messageChannel;

  /// Starts listening to real-time changes on the 'moods' table and 'partner_messages'
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
          
          if (userId != null && userId != _supabase.auth.currentUser?.id) {
            NotificationService.instance.showNotification(
              id: payload.newRecord['id'].hashCode,
              title: 'Update Mood Partner',
              body: 'Partner Anda menambahkan mood baru: $newMood',
            );
          }
        }
        onUpdate();
      },
    )..subscribe();

    _messageChannel = _supabase.channel('public:partner_messages').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'partner_messages',
      callback: (payload) {
        final receiverId = payload.newRecord['receiver_id'] as String?;
        final message = payload.newRecord['message'] as String?;
        final currentUserId = _supabase.auth.currentUser?.id;

        // Only show notification if I am the receiver
        if (receiverId != null && receiverId == currentUserId && message != null) {
          NotificationService.instance.showNotification(
            id: payload.newRecord['id'].hashCode,
            title: 'Pesan dari Partner 💌',
            body: message,
          );
        }
      },
    )..subscribe();
  }

  void stopListening() {
    _moodChannel?.unsubscribe();
    _moodChannel = null;
    _messageChannel?.unsubscribe();
    _messageChannel = null;
  }
}
