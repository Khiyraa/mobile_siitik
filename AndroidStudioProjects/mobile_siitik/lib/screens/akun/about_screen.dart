import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Center(
               child: Image.asset(
                 'assets/images/logo2.png', // Ganti dengan path logo Anda
                 width: 100, // Tentukan lebar logo
                 height: 100, // Tentukan tinggi logo
                 fit: BoxFit.contain, // Menjaga agar gambar tidak terdistorsi
               ),
             ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'SI-ITIK',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Versi 1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Tentang Aplikasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'SI-ITIK adalah aplikasi manajemen dan penjualan berbasis web dan mobile '
                  'yang dirancang untuk membantu para peternak itik. Aplikasi ini menyediakan fitur '
                  'untuk penetasan telur, penggemukan itik, dan monitoring proses layering. Dengan antarmuka '
                  'yang sederhana, aplikasi ini dirancang untuk meningkatkan efisiensi dan produktivitas usaha Anda.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kontak Kami',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Email: support@siitik.com\nWebsite: www.siitik.com',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
