import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gontran/firebase_options.dart';
import 'package:gontran/views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My-Cypress',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE2F0D9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D4B3E),
          primary: const Color(0xFF2D4B3E),
          secondary: const Color(0xFF4A6B5D),
        ),
        textTheme: TextTheme(
          headlineMedium: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D4B3E),
          ),
          bodyMedium: GoogleFonts.lora(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF4A6B5D),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}