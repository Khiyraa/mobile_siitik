import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_siitik/firebase_options.dart';
import 'package:mobile_siitik/screens/auth/login_screen.dart';
import 'package:mobile_siitik/screens/dashboard_screen.dart';
import 'package:mobile_siitik/screens/main_screen.dart';
import 'package:mobile_siitik/screens/splashscreen.dart';

// import 'screens/dashboard_screen.dart';

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
      title: 'SI-ITIK',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(), // Route ke LoginScreen
        '/login': (context) => const LoginScreen(),
        '/home': (context) =>
            MainScreen(),
        // '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}