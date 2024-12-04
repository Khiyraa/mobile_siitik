import 'package:flutter/material.dart';
import 'package:mobile_siitik/screens//dashboard_screen.dart';
import 'package:mobile_siitik/screens/riwayat_screen.dart';
import 'package:mobile_siitik/screens/notification_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import 'account_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2;

  final List<Widget> _pages = [
    Center(child: Text('Link Ke Website')),
    RiwayatScreen(), // Halaman Riwayat
    DashboardScreen(), // Halaman Akun
    NotificationsPage(),
    AccountScreen(),
    // Halaman Notifikasi
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // Menampilkan halaman berdasarkan index aktif
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem('Website', Icons.language, () async {
                  final Uri uri = Uri.parse('https://siitik-mbkm.research-ai.my.id/');

                  try {
                    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tidak dapat membuka browser'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pastikan Anda memiliki browser web yang terinstal'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    print('Error: $e');
                  }
                }, 0),
                _buildNavItem('Riwayat', Icons.history, () {
                  setState(() {
                    _currentIndex = 1; // Mengubah halaman aktif
                  });
                }, 1),
                _buildNavItemWithImage('Logo Itik', 'assets/images/logo2.png', () {
                  setState(() {
                    _currentIndex = 2; // Mengubah halaman aktif
                  });
                  // Tambahkan aksi yang relevan untuk Logo Itik
                }, 2),
                _buildNavItem('Notifikasi', Icons.notifications, () {
                  setState(() {
                    _currentIndex = 3; // Mengubah halaman aktif
                  });
                  // Tambahkan aksi untuk Notifikasi
                }, 3),
                _buildNavItem('Akun', Icons.person, () {
                  setState(() {
                    _currentIndex = 4; // Mengubah halaman aktif
                  });
                }, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Fungsi untuk membangun item navigasi dengan ikon
  Widget _buildNavItem(String title, IconData icon, VoidCallback onTap, int index) {
    bool isSelected = _currentIndex == index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
          child: IconButton(
            icon: Icon(icon,
                color: isSelected ? Colors.white : AppColors.primary),
            onPressed: onTap,
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

// Fungsi untuk membangun item navigasi dengan gambar
  Widget _buildNavItemWithImage(String title, String imagePath, VoidCallback onTap, int index) {
    bool isSelected = _currentIndex == index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 32, // Sesuaikan ukuran gambar
              height: 32,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

}
