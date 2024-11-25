import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_siitik/core/constants/app_colors.dart';
import 'package:mobile_siitik/services/auth_service.dart';

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({Key? key}) : super(key: key);

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      // Validasi email terlebih dahulu
      final String email = emailController.text.trim();
      final String password = passwordController.text.trim();
      final String username = usernameController.text.trim();

      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sudah terdaftar!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Proses registrasi
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update profile
      await userCredential.user?.updateDisplayName(username);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password minimal 6 karakter';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Registrasi dengan email dinonaktifkan';
          break;
        default:
          errorMessage = 'Terjadi kesalahan: ${e.message}';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);

    try {
      // Sign out dulu untuk memastikan dialog pemilihan akun muncul
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ['email', 'profile'],
      ).signIn();

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'user-cancelled',
          message: 'Registrasi dibatalkan oleh user',
        );
      }

      // Cek apakah email sudah terdaftar
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(googleUser.email);
      if (methods.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sudah terdaftar! Silakan login.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Buat akun di Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi dengan Google berhasil!'),
          backgroundColor: Colors.green,
        ),
      );

    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'user-cancelled':
          message = 'Registrasi dibatalkan';
          break;
        case 'account-exists-with-different-credential':
          message = 'Email sudah terdaftar dengan metode lain';
          break;
        case 'invalid-credential':
          message = 'Kredensial tidak valid';
          break;
        case 'operation-not-allowed':
          message = 'Registrasi dengan Google tidak diizinkan';
          break;
        case 'user-disabled':
          message = 'Akun telah dinonaktifkan';
          break;
        default:
          message = 'Terjadi kesalahan saat registrasi: ${e.message}';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('General Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateInputs() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password minimal 6 karakter'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                ),
              ),

              // Title
              const Text(
                'Selamat Datang',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Daftarkan Akunmu Sekarang',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Email Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: emailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'Masukkan Email',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: passwordController,
                  enabled: !_isLoading,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.lock_outline),
                    hintText: 'Masukkan Password',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Username Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: usernameController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.person_outline),
                    hintText: 'Masukkan Username',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.background,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah Punya Akun? '),
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            // Add navigation to login screen if needed
                          },
                    child: Text(
                      'Masuk Sekarang',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Divider
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),

              // Social Media Login
              const Text(
                'Social Media Login',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Google Sign In Button
              GestureDetector(
                onTap: _isLoading ? null : _handleGoogleSignUp,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/google.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }
}
