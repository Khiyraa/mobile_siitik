import 'package:flutter/material.dart';
import 'package:mobile_siitik/screens/riwayat_screen.dart';
import '../../core/constants/app_colors.dart';
import 'package:mobile_siitik/screens/account_screen.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                // Navigasi untuk Website bisa ditambahkan nanti
              }),
              _buildNavItem('Riwayat', Icons.history, () {
                // Navigasi ke halaman RiwayatScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RiwayatScreen()),
                );
              }),
              _buildNavItem('Logo Itik',
                  Image.asset('assets/images/logo2.png') as IconData, () {
                // Tambahkan aksi yang relevan untuk Logo Itik
              }),
              _buildNavItem('Notifikasi', Icons.notifications, () {
                // Tambahkan aksi untuk Notifikasi
              }),
              _buildNavItem('Akun', Icons.person, () {
                // Tambahkan aksi untuk Akun
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountScreen()),
                );
              }),
            ],
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
