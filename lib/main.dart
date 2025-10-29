import 'package:auteurly/features/auth/auth_page.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    // Use the debug provider for testing in an emulator
    androidProvider: AndroidProvider.debug,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      title: 'Auteurly',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFA32626),
        scaffoldBackgroundColor: const Color(0xFF1B1B1B),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFA32626),
          secondary: const Color(0xFFB74141),
          background: const Color(0xFF1B1B1B),
          surface: const Color(0xFF2C2C2C),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Colors.white,
          onSurface: Colors.white,
          error: Colors.redAccent.shade700,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B1B1B),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA32626),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.white70),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          hintStyle: TextStyle(color: Colors.grey[600]),
          labelStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: const Color(0xFFA32626), width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 16.0,
          ),
        ),
        textTheme:
            GoogleFonts.montserratTextTheme(
                  // Apply Secondary font (Montserrat) globally
                  textTheme,
                )
                .copyWith(
                  // Override Headline/Display styles with Primary font (Monoton)
                  displayLarge: GoogleFonts.monoton(
                    textStyle: textTheme.displayLarge,
                    color: Colors.white,
                  ),
                  displayMedium: GoogleFonts.monoton(
                    textStyle: textTheme.displayMedium,
                    color: Colors.white,
                  ),
                  displaySmall: GoogleFonts.monoton(
                    textStyle: textTheme.displaySmall,
                    color: Colors.white,
                  ),
                  headlineLarge: GoogleFonts.monoton(
                    textStyle: textTheme.headlineLarge,
                    color: Colors.white,
                  ),
                  headlineMedium: GoogleFonts.monoton(
                    textStyle: textTheme.headlineMedium,
                    color: Colors.white,
                  ),
                  headlineSmall: GoogleFonts.monoton(
                    textStyle: textTheme.headlineSmall,
                    color: Colors.white,
                  ),
                  // Optionally apply Monoton to titles too
                  /* titleLarge: GoogleFonts.monoton(
                    textStyle: textTheme.titleLarge,
                    color: Colors.white,
                  ),
                  titleMedium: GoogleFonts.monoton(
                    textStyle: textTheme.titleMedium,
                    color: Colors.white,
                  ),
                  titleSmall: GoogleFonts.monoton(
                    textStyle: textTheme.titleSmall,
                    color: Colors.white,
                  ),*/
                )
                .apply(
                  // Ensure default body text is white for dark theme
                  bodyColor: Colors.white,
                  displayColor: Colors
                      .white, // Applies to display*, headline*, title* if color not specified above
                ),

        // ... rest of your theme (appBarTheme, button themes, inputDecorationTheme, etc.) ...
      ),

      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}
