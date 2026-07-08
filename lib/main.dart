import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/session/session_store.dart';
import 'features/auth/data/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final prefs = await SharedPreferences.getInstance();
    final sessionStr = prefs.getString('user_session');
    if (sessionStr != null) {
      final Map<String, dynamic> userMap = jsonDecode(sessionStr) as Map<String, dynamic>;
      final user = AuthUser.fromStoredJson(userMap);
      SessionStore.instance.setSession(user);
    }
  } catch (e) {
    debugPrint('Error loading saved session: $e');
  }

  // Lock orientation to portrait only (untuk tablet)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const DiesMaintenanceApp());
}
