import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'main_screen.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MorpheusApp());
}

class MorpheusColors {
  static const deepSpace = Color(0xFF03010A);
  static const cosmicPurple = Color(0xFF1A0533);
  static const nebulaPurple = Color(0xFF2D1B69);
  static const mysticViolet = Color(0xFF7B2FBE);
  static const dreamPink = Color(0xFFE040FB);
  static const starGold = Color(0xFFFFD700);
  static const moonSilver = Color(0xFFE8E0F0);
  static const glowPurple = Color(0xFF9C27B0);
  static const softLavender = Color(0xFFCE93D8);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [deepSpace, cosmicPurple, Color(0xFF0D0520)],
    stops: [0.0, 0.5, 1.0],
  );
}

class MorpheusApp extends StatelessWidget {
  const MorpheusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morpheus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7B2FBE),
          secondary: Color(0xFFE040FB),
          tertiary: Color(0xFFFFD700),
          surface: Color(0xFF1A0533),
          background: Color(0xFF03010A),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFE8E0F0),
        ),
        textTheme: GoogleFonts.cinzelTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          bodyLarge: GoogleFonts.raleway(
            color: const Color(0xFFE8E0F0),
            fontSize: 16,
          ),
          bodyMedium: GoogleFonts.raleway(
            color: const Color(0xFFCE93D8),
            fontSize: 14,
          ),
          bodySmall: GoogleFonts.raleway(
            color: const Color(0xFFCE93D8),
            fontSize: 12,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFF03010A),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A0533).withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFF7B2FBE).withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
