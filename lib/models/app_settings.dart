/// Application-level settings.
class AppSettings {
  String themeColor;
  bool onboardingDone;
  bool notificationsEnabled;

  AppSettings({
    this.themeColor = 'pink',
    this.onboardingDone = false,
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    String? themeColor,
    bool? onboardingDone,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      themeColor: themeColor ?? this.themeColor,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeColor': themeColor,
      'onboardingDone': onboardingDone,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeColor: json['themeColor'] as String? ?? 'pink',
      onboardingDone: json['onboardingDone'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );
  }
}
