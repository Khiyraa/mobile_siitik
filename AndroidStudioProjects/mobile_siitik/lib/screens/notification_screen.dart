import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mobile_siitik/core/constants/app_colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Notifikasi"),
      ),
      body: Container(
        color: AppColors.background,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collectionGroup('analisis_periode')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Terjadi kesalahan.'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Belum ada notifikasi.'));
            }

            final notifications = _generateNotifications(snapshot.data!.docs);

            return ListView.separated(
              // Gunakan ListView.separated untuk memberikan pemisah
              itemCount: notifications.length,
              separatorBuilder: (context, index) =>
                  const Divider(), // Tambahkan pemisah
              itemBuilder: (context, index) {
                return Card(
                  // Bungkus ListTile dengan Card
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(Icons.notification_important),
                    title: Text(notifications[index]['title']!),
                    subtitle: Text(notifications[index]['message']!),
                    trailing: Text(notifications[index]['source']!),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Map<String, String>> _generateNotifications(
      List<QueryDocumentSnapshot> docs) {
    final List<Map<String, String>> notifications = [];

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Ambil timestamp dari dokumen
      final timestamp = data['created_at'] as Timestamp?;
      final formattedTime = timestamp != null
          ? DateFormat('d MMM yyyy, HH:mm').format(timestamp.toDate())
          : 'Waktu tidak tersedia';

      // Analisis dari berbagai koleksi
      if (data.containsKey('hasilAnalisis')) {
        final hasilAnalisis =
            data['hasilAnalisis'] as Map<String, dynamic>? ?? {};
        final penerimaan = data['penerimaan'] as Map<String, dynamic>? ?? {};
        final periode = data['periode'] as String? ?? 'Tidak Diketahui';

        // Contoh kriteria untuk penetasan
        if ((hasilAnalisis['marginOfSafety'] as num? ?? 0) < 10) {
          notifications.add({
            'title': 'Margin of Safety Rendah',
            'message':
                'Margin of Safety pada periode $periode terlalu rendah! ($formattedTime)',
            'source': 'Penetasan',
          });
        }

        // Contoh kriteria untuk penggemukan
        if ((penerimaan['persentaseMortalitas'] as num? ?? 0) > 50) {
          notifications.add({
            'title': 'Mortalitas Tinggi',
            'message':
                'Tingkat kematian itik sangat tinggi (${penerimaan['persentaseMortalitas']}%)! ($formattedTime)',
            'source': 'Penggemukan',
          });
        }

        // Contoh kriteria untuk layer
        if ((hasilAnalisis['laba'] as num? ?? 0) < 0) {
          notifications.add({
            'title': 'Laba Negatif',
            'message':
                'Proses pada periode $periode mengalami kerugian! ($formattedTime)',
            'source': 'Layer',
          });
        }
      }
    }

    return notifications;
  }
}
