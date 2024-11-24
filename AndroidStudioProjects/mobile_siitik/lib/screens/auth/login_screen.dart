import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_siitik/core/constants/app_colors.dart';
import 'package:mobile_siitik/core/constants/app_images.dart';
import 'package:mobile_siitik/services/auth_service.dart';
import 'package:mobile_siitik/widgets//loading_indicator.dart';
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
    // final emailController = TextEditingController();
    // final passwordController = TextEditingController();
    // final usernameController = TextEditingController();

    showDialog(context: context, builder: (context) => const RegisterDialog());
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final userCredential =
        await _authService.signInWithEmailAndPassword(email, password);
        if (userCredential != null) {
          // Navigasi ke halaman dashboard setelah login berhasil
          Navigator.pushReplacementNamed(
              context, '/dashboard'); // '/home' akan membuka DashboardScreen
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
              content: Text('Akun tidak ditemukan.'),
            ),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kata sandi salah.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
              Text('Terjadi kesalahan: email atau password anda salah'),
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

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('Memulai proses login Google di LoginScreen');
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential.user != null) {
        print('Login berhasil: ${userCredential.user!.email}');

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error detail dalam handleGoogleSignIn: $e');
      String errorMessage = 'Gagal login dengan Google';

      if (e is FirebaseAuthException) {
        print('Firebase Auth Error Code: ${e.code}');
        print('Firebase Auth Error Message: ${e.message}');

        switch (e.code) {
          case 'user-cancelled':
            errorMessage = 'Login dibatalkan';
            break;
          case 'account-exists-with-different-credential':
            errorMessage =
            'Akun sudah terdaftar dengan metode login yang berbeda';
            break;
          case 'invalid-credential':
            errorMessage = 'Kredensial tidak valid';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Login dengan Google tidak diaktifkan';
            break;
          case 'user-disabled':
            errorMessage = 'Akun telah dinonaktifkan';
            break;
          case 'user-not-found':
            errorMessage = 'Akun tidak ditemukan';
            break;
          default:
            errorMessage =
                e.message ?? 'Terjadi kesalahan saat login dengan Google';
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // Tambahkan Stack sebagai widget utama
      children: [
        Scaffold(
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
                            height:
                            200, // Sesuaikan dengan ukuran yang diinginkan
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppStrings.loginTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.loginSubtitle,
                        style: const TextStyle(
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
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
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
                      const SizedBox(height: 5),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: const Text(
                          'Lupa Password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // Divider dengan teks
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Atau masuk dengan',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Tombol Google Sign In
                      InkWell(
                        onTap: _handleGoogleSignIn,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/google.png',
                                height: 24,
                                width: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const LoadingIndicator(
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}