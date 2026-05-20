import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings();

  String get themeColor => _settings.themeColor;
  bool get onboardingDone => _settings.onboardingDone;
  bool get notificationsEnabled => _settings.notificationsEnabled;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = AppSettings(
      themeColor: prefs.getString('themeColor') ?? 'pink',
      onboardingDone: prefs.getBool('onboardingDone') ?? false,
      notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
    );
    notifyListeners();
  }

  Future<void> setThemeColor(String color) async {
    _settings.themeColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeColor', color);
  }

  Future<void> setOnboardingDone(bool done) async {
    _settings.onboardingDone = done;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', done);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _settings.notificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
    
    if (enabled) {
      await NotificationService.instance.requestPermission();
      await NotificationService.instance.scheduleDailyMoodReminder();
    } else {
      await NotificationService.instance.cancelDailyMoodReminder();
    }
  }
}
