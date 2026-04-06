import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DiesMaintenanceApp());
}

class DiesMaintenanceApp extends StatelessWidget {
  const DiesMaintenanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dies Maintenance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF059669)),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        // TODO: Replace with Nunito Sans once Developer Mode is enabled
        // fontFamily: GoogleFonts.nunitoSans().fontFamily,
        useMaterial3: true,
      ),
      home: const DiesMaintenanceDashboard(),
    );
  }
}
