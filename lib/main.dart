import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cima_mens/services/notification_service.dart';
import 'package:cima_mens/providers/auth_provider.dart';
import 'package:cima_mens/providers/cycle_provider.dart';
import 'package:cima_mens/providers/mood_provider.dart';
import 'package:cima_mens/providers/settings_provider.dart';
import 'package:cima_mens/utils/theme.dart';
import 'package:cima_mens/screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Supabase
  await dotenv.load(fileName: "assets/env");
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  try {
    await NotificationService.instance.init();
  } catch (_) {
    debugPrint('FlowMate: Notification service init failed, continuing...');
  }

  runApp(const FlowMateApp());
}

class FlowMateApp extends StatelessWidget {
  const FlowMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<CycleProvider>(
          create: (_) => CycleProvider()..loadCycles(),
        ),
        ChangeNotifierProvider<MoodProvider>(
          create: (_) => MoodProvider()..loadEntries(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: const _FlowMateAppContent(),
    );
  }
}

class _FlowMateAppContent extends StatelessWidget {
  const _FlowMateAppContent();

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'cima mens',
      debugShowCheckedModeBanner: false,
      theme: FlowMateTheme.getTheme(settingsProvider.themeColor),
      home: const SplashScreen(),
    );
  }
}
