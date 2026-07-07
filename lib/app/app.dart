import 'package:flutter/material.dart';
import '../core/router/app_router.dart';

/// Root widget aplikasi.
/// Konfigurasi [MaterialApp] dipusatkan di sini.
class DiesMaintenanceApp extends StatelessWidget {
  const DiesMaintenanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      title: 'Dies Maintenance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF059669)),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      // ── Router ─────────────────────────────────────────────────
      initialRoute: AppRouter.initialRoute,
      routes: AppRouter.routes,
    );
  }
}
