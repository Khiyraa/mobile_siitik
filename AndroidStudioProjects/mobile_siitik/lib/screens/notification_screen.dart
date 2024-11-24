import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mobile_siitik/core/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchAllAnalysisPeriods() async {
    final _firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    List<Map<String, dynamic>> allNotifications = [];

    try {
      // Fetch Penetasan
      final penetasanDocs = await _firestore
          .collection('detail_penetasan')
          .where('userId', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .get();

      for (var mainDoc in penetasanDocs.docs) {
        final periodeDocs = await _firestore
            .collection('detail_penetasan')
            .doc(mainDoc.id)
            .collection('analisis_periode')
            .get();

        for (var doc in periodeDocs.docs) {
          var data = doc.data();
          allNotifications.add({
            ...data,
            'type': 'penetasan',
            'id': doc.id,
          });
        }
      }

      // Fetch Layer
      final layerDocs = await _firestore
          .collection('detail_layer')
          .where('userId', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .get();

      for (var mainDoc in layerDocs.docs) {
        final periodeDocs = await _firestore
            .collection('detail_layer')
            .doc(mainDoc.id)
            .collection('analisis_periode')
            .get();

        for (var doc in periodeDocs.docs) {
          var data = doc.data();
          allNotifications.add({
            ...data,
            'type': 'layer',
            'id': doc.id,
          });
        }
      }

      // Fetch Penggemukan
      final penggemukanDocs = await _firestore
          .collection('detail_penggemukan')
          .where('userId', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .get();

      for (var doc in penggemukanDocs.docs) {
        var data = doc.data();
        allNotifications.add({
          ...data,
          'type': 'penggemukan',
          'id': doc.id,
        });
      }

      // Sort by timestamp
      allNotifications.sort((a, b) {
        final aTime = a['created_at'] as Timestamp;
        final bTime = b['created_at'] as Timestamp;
        return bTime.compareTo(aTime);
      });

      return allNotifications;
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Notifikasi"),
      ),
      body: Container(
        color: AppColors.background,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchAllAnalysisPeriods(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Belum ada notifikasi.'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                // This will trigger a rebuild
                await Future.delayed(Duration.zero);
              },
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final data = snapshot.data![index];
                  final hasilAnalisis = data['hasilAnalisis'] as Map<String, dynamic>? ?? {};
                  final penerimaan = data['penerimaan'] as Map<String, dynamic>? ?? {};
                  final periode = data['periode'] ?? 'Tidak Diketahui';
                  final timestamp = data['created_at'] as Timestamp;
                  final type = data['type'] as String;

                  String title = '';
                  String message = '';
                  bool showNotification = false;

                  // Check conditions for notifications
                  if (hasilAnalisis['marginOfSafety'] != null && hasilAnalisis['marginOfSafety'] < 20) {
                    title = 'Peringatan MOS Rendah';
                    message = 'MOS periode $periode: ${hasilAnalisis['marginOfSafety'].toStringAsFixed(1)}%';
                    showNotification = true;
                  } else if (hasilAnalisis['rcRatio'] != null && hasilAnalisis['rcRatio'] < 1) {
                    title = 'R/C Ratio Tidak Efisien';
                    message = 'R/C Ratio periode $periode: ${hasilAnalisis['rcRatio'].toStringAsFixed(2)}';
                    showNotification = true;
                  }

                  // Type specific checks
                  if (type == 'penggemukan' && penerimaan['persentaseMortalitas'] != null && penerimaan['persentaseMortalitas'] > 5) {
                    title = 'Mortalitas Tinggi';
                    message = 'Mortalitas periode $periode: ${penerimaan['persentaseMortalitas'].toStringAsFixed(1)}%';
                    showNotification = true;
                  }

                  if (!showNotification) return Container();

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: ListTile(
                      leading: Icon(
                        _getIconForType(type),
                        color: _getColorForType(type),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(message),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate()),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: _getSourceBadge(type),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'penetasan':
        return Icons.egg_alt;
      case 'layer':
        return Icons.egg;
      case 'penggemukan':
        return Icons.inventory;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'penetasan':
        return Colors.blue;
      case 'layer':
        return Colors.green;
      case 'penggemukan':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _getSourceBadge(String type) {
    String label = type[0].toUpperCase() + type.substring(1);
    Color color = _getColorForType(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}