library questapp;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'models/auth_models.dart';
part 'services/session_store.dart';
part 'services/api_client.dart';
part 'widgets/auth_shell.dart';
part 'widgets/shared_components.dart';
part 'widgets/page_placeholders.dart';
part 'widgets/utils.dart';
part 'view/launch_gate.dart';
part 'view/splash_screen.dart';
part 'view/auth/login_screen.dart';
part 'view/auth/register_screen.dart';
part 'view/auth/tutorial_wizard_screen.dart';
part 'view/home/quest_map_screen.dart';
part 'view/home/quest_detail_sheet.dart';
part 'view/quest/quest_result_screen.dart';
part 'view/quest/gps_quest_screen.dart';
part 'view/quest/ar_quest_screen.dart';
part 'view/quest/treasure_hunt_quest_screen.dart';
part 'view/quest/plant_id_quest_screen.dart';
part 'view/leaderboard_screen.dart';
part 'view/voucher_screen.dart';
part 'view/voucher_qr_detail_screen.dart';
part 'view/submit_review_screen.dart';
part 'view/settings/settings_screen.dart';
part 'view/quest/quiz_quest_screen.dart';

void main() {
  runApp(const QuestApp());
}

class QuestApp extends StatelessWidget {
  const QuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0E7A5A),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoQuest',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF7F8F4),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFE8F7EF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/tutorial': (_) => const TutorialWizardScreen(),
        '/quest-map': (_) => const QuestMapScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
      home: const LaunchGate(),
    );
  }
}

class AppAssets {
  static const background = 'assets/images/background.jpg';
  static const logo = 'assets/images/logo.png';
  static const mapHtml = 'assets/map/quest_map.html';
}

class AppPalette {
  static const deepGreen = Color(0xFF0E7A5A);
  static const darkGreen = Color(0xFF0A5A44);
  static const textBody = Color(0xFF2F3A33);
  static const textMuted = Color(0xFF8A8F87);
}

class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.2:8000/api/',
  );
}
