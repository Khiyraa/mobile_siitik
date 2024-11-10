import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_siitik/core/constants/app_colors.dart';
import 'package:mobile_siitik/core/constants/app_images.dart';
import 'package:mobile_siitik/services/auth_service.dart';
import 'package:mobile_siitik/widgets/register_dialog.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _showRegisterDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => const RegisterDialog()
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text;
      final password = _passwordController.text;


    try {
    final userCredential = await _authService.signInWithEmailAndPassword(email, password);
    if (userCredential != null) {
    // Navigasi ke halaman utama atau tampilkan pesan sukses
    Navigator.pushReplacementNamed(context, '/home'); // Ganti '/home' dengan nama route halaman utama Anda
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text('Login berhasil!'),
    ),
    );
    } else {
    // Akun tidak ditemukan
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text('Akun tidak ditemukan.'),
    ),
    );
    }
    } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content:
    Text('Akun tidak ditemukan.'),
    ),
    );
    } else if (e.code == 'wrong-password') {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text('Kata sandi salah.'),
    ),
    );
    } else {
    // Handle kesalahan lainnya
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
    content: Text('Terjadi kesalahan: ${e.message}'),
    ),
    );
    }
    } finally {
    setState(() {
    _isLoading = false;
    });
    }
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppImages.logo,
                        height: 250,  // Sesuaikan dengan ukuran yang diinginkan
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    AppStrings.loginTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.loginSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    label: AppStrings.email,
                    controller: _emailController,
                    validator: Validators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: AppStrings.password,
                    controller: _passwordController,
                    validator: Validators.validatePassword,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.darkGrey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: AppStrings.login,
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum punya akun? '),
                      TextButton(
                        onPressed: _showRegisterDialog,
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
