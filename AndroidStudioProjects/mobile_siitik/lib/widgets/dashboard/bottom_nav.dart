import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({Key? key}) : super(key: key);

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
              _buildNavItem('Website', Icons.language, () {}),
              _buildNavItem('Riwayat', Icons.history, () {}),
              _buildNavItem('Logo Itik', Icons.pets, () {}),
              _buildNavItem('Notifikasi', Icons.notifications, () {}),
              _buildNavItem('Akun', Icons.person, () {}),
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