import 'package:flutter/material.dart';
import 'package:mobile_siitik/screens/dashboard_screen.dart';
import 'package:mobile_siitik/screens/riwayat_screen.dart';
import '../core/constants/app_colors.dart';
import 'account_screen.dart'; // Import halaman AccountScreen
// Import halaman lainnya jika diperlukan

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2; // Untuk melacak halaman yang aktif

  final List<Widget> _pages = [
    Center(child: Text('Link Ke Website')),
    RiwayatScreen(), // Halaman Riwayat
    DashboardScreen(),// Halaman Akun
    Center(child: Text('Notifikasi')),
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
                _buildNavItem('Website', Icons.language, () {

                  setState(() {
                    _currentIndex = 0; // Mengubah halaman aktif
                  });
                  // Navigasi untuk Website bisa ditambahkan nanti
                }),
                _buildNavItem('Riwayat', Icons.history, () {
                  setState(() {
                    _currentIndex = 1; // Mengubah halaman aktif
                  });
                  // Navigasi ke halaman RiwayatScreen
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => RiwayatScreen()),
                  // );
                }),
                _buildNavItem('Logo Itik', Icons.pets, () {
                  setState(() {
                    _currentIndex = 2; // Mengubah halaman aktif
                  });
                  // Tambahkan aksi yang relevan untuk Logo Itik
                }),
                _buildNavItem('Notifikasi', Icons.notifications, () {
                  setState(() {
                    _currentIndex = 3; // Mengubah halaman aktif
                  });
                  // Tambahkan aksi untuk Notifikasi
                }),
                _buildNavItem('Akun', Icons.person, () {
                  setState(() {
                    _currentIndex = 4; // Mengubah halaman aktif
                  });
                  // Tambahkan aksi untuk Akun
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const AccountScreen()),
                  // );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String title, IconData icon, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: AppColors.primary),
          onPressed: onTap,
        ),
        Text(title, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
