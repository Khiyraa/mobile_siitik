// lib/widgets/dashboard/info_card.dart
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: const Text(
        'Pengelolaan lingkungan: Pastikan lingkungan peternakan bersih dan nyaman untuk meminimalisir stres pada itik yang dapat mempengaruhi produksi.',
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
