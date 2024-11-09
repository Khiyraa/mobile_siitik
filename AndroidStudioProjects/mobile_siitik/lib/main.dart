import 'package:flutter/material.dart';
import 'package:mobile_siitik/screens/dashboard_screen.dart';
// import 'core/configs/theme.dart';
import 'screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const
  MyApp());
  }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SI-ITIK',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),  // Route ke LoginScreen
        '/home': (context) => const DashboardScreen(),  // Pastikan dashboard_screen.dart terdaftar di sini
        // '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}