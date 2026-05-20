class ProfileModel {
  final String id;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final String role;
  final String? partnerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileModel({
    required this.id,
    this.name,
    this.email,
    this.avatarUrl,
    required this.role,
    this.partnerId,
    this.createdAt,
    this.updatedAt,
  });

  ProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
    String? partnerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      partnerId: partnerId ?? this.partnerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'role': role,
      if (partnerId != null) 'partner_id': partnerId,
    };
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'partner',
      partnerId: json['partner_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }
}
