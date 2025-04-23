import 'package:flutter/material.dart';
import 'package:careconnect/onboard/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor:  const Color(0xFF7DB63A),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color.fromARGB(255, 66, 106, 32),
          surface: Colors.white, // Background is white
          onSurface: Colors.black, // Text on background is black
          primary: const Color.fromARGB(255, 135, 193, 68),
          onPrimary: Colors.black, // Text on primary is black
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
          titleSmall: TextStyle(color: Colors.black),
        ),
      ),
      initialRoute: SplashWidget.routeName,
      routes: {SplashWidget.routeName: (context) => const SplashWidget()},
    ),
  );
}
