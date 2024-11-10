import 'package:flutter/material.dart';
import 'core/configs/theme.dart';
import 'screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

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
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}