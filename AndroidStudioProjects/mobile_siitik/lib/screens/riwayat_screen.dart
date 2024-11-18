import 'package:flutter/material.dart';
import 'package:mobile_siitik/core/constants/app_colors.dart';
import 'package:mobile_siitik/widgets/custom_riwayat_card.dart';


class RiwayatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat',
          style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          CustomRiwayatCard(
            icon: Icons.layers,
            title: 'Analisis Layer',
            time: '09:20 PM',
            details: {
              'MOS': '-',
              'R/C Ratio': '-',
              'BEP Harga': '-',
              'BEP Hasil': '-',
              'Laba': '-',
            },
          ),
          CustomRiwayatCard(
            icon: Icons.egg,
            title: 'Analisis Penetasan',
            time: '08:20 PM',
            details: {
              'MOS': '-',
              'R/C Ratio': '-',
              'BEP Harga': '-',
              'BEP Hasil': '-',
              'Laba': '-',
            },
          ),
          CustomRiwayatCard(
            icon: Icons.pets,
            title: 'Analisis Penggemukan',
            time: '07:20 PM',
            details: {
              'MOS': '-',
              'R/C Ratio': '-',
              'BEP Harga': '-',
              'BEP Hasil': '-',
              'Laba': '-',
            },
          ),
        ],
      ),
          ),
    );
  }
}
