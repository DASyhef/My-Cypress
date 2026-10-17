import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:gontran/firebase_options.dart';
import 'package:gontran/services/auth_service.dart';
import 'package:gontran/views/auth_page.dart';
import 'package:gontran/views/dashboard_page.dart';
import 'package:gontran/views/profile_page.dart';

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
    final AuthService authService = AuthService();
    final primaryColor = const Color(0xFF2D4B3E);
    final secondaryColor = const Color(0xFF4A6B5D);

    return MaterialApp(
      title: 'My-Cypress',
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE2F0D9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
        ),
        textTheme: TextTheme(
          headlineMedium: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
          bodyMedium: GoogleFonts.lora(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: secondaryColor,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: authService.userState,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final user = snapshot.data;
          if (user == null) {
            return const AuthPage();
          }

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, docSnapshot) {
              if (docSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (docSnapshot.hasData && docSnapshot.data!.exists) {
                final data = docSnapshot.data!.data() as Map<String, dynamic>?;
                final lastName = data?['lastName'] ?? '';
                final firstName = data?['firstName'] ?? '';

                if (lastName.isEmpty || firstName.isEmpty) {
                  return const ProfilePage();
                }
              }

              return const DashboardPage();
            },
          );
        },
      ),
    );
  }
}