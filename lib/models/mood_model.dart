/// Model representing a mood / symptom journal entry.
class MoodEntry {
  final String id;
  final String userId;
  final DateTime date; // Extracted from created_at in Supabase
  final String mood;
  final String? note;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Symptoms are now fetched from a separate table, but we can store them here 
  // in the client-side model for convenience if needed, though they aren't stored 
  // directly in the moods table in Supabase.
  final List<String> symptoms;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    this.symptoms = const [],
    this.note,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  MoodEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? mood,
    List<String>? symptoms,
    String? note,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      note: note ?? this.note,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mood': mood,
      if (note != null) 'note': note,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  /// For insert: exclude id, user_id, created_at, updated_at (let DB defaults handle them)
  Map<String, dynamic> toInsertJson() {
    return {
      'mood': mood,
      if (note != null) 'note': note,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      // Treat created_at as the date of the mood log
      date: json['created_at'] != null ? DateTime.parse(json['created_at'] as String).toLocal() : DateTime.now(),
      mood: json['mood'] as String,
      symptoms: json['symptoms'] != null
          ? (json['symptoms'] as List<dynamic>)
              .map((s) => s['symptom'] as String)
              .toList()
          : [],
      note: json['note'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String).toLocal() : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String).toLocal() : null,
    );
  }
}
