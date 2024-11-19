import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Bantuan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Pusat Bantuan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.question_answer_outlined),
              title: const Text('Bagaimana cara reset kata sandi?'),
              subtitle: const Text(
                  'Untuk mereset kata sandi, pergi ke halaman "Ubah Kata Sandi" dan ikuti petunjuk.'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Bagaimana cara mengedit profil?'),
              subtitle: const Text(
                  'Pergi ke menu "Edit Profil" untuk mengubah informasi akun Anda.'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Masalah umum lainnya'),
              subtitle: const Text(
                  'Hubungi dukungan kami di support@siitik.com untuk bantuan lebih lanjut.'),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
