import 'package:flutter/material.dart';
import 'pages/countdown_home.dart';

void main() {
  runApp(const CountdownApp());
}

class CountdownApp extends StatelessWidget {
  const CountdownApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ramadan Countdown',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF10B981),
          secondary: const Color(0xFFF59E0B),
          surface: const Color(0xFF0F172A),
          error: Colors.red.shade400,
        ),
        fontFamily: 'Poppins',
      ),
      home: const CountdownHome(),
    );
  }
}