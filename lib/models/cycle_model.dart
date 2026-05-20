/// Model representing a menstrual cycle entry.
class CycleModel {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final int periodLength;
  final int cycleLength;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CycleModel({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.periodLength = 5,
    this.cycleLength = 28,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  DateTime get nextPeriodDate => startDate.add(Duration(days: cycleLength));
  DateTime get ovulationDate => startDate.add(Duration(days: cycleLength - 14));
  DateTime get fertileStart => startDate.add(Duration(days: cycleLength - 19));
  DateTime get fertileEnd => startDate.add(Duration(days: cycleLength - 13));
  DateTime get periodEndDate => startDate.add(Duration(days: periodLength - 1));

  CycleModel copyWith({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? periodLength,
    int? cycleLength,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CycleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      periodLength: periodLength ?? this.periodLength,
      cycleLength: cycleLength ?? this.cycleLength,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T')[0],
      'period_length': periodLength,
      'cycle_length': cycleLength,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// For insert: exclude id, user_id, created_at, updated_at (let DB defaults handle them)
  Map<String, dynamic> toInsertJson() {
    return {
      'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T')[0],
      'period_length': periodLength,
      'cycle_length': cycleLength,
      if (notes != null) 'notes': notes,
    };
  }

  factory CycleModel.fromJson(Map<String, dynamic> json) {
    return CycleModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      periodLength: json['period_length'] as int? ?? 5,
      cycleLength: json['cycle_length'] as int? ?? 28,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }
}
