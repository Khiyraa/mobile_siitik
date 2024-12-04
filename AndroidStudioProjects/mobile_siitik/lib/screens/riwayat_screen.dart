import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_siitik/core/constants/app_colors.dart';
import 'package:mobile_siitik/screens/riwayat/detail_periode.dart';
import 'package:mobile_siitik/widgets/custom_riwayat_card.dart';
import 'package:intl/intl.dart';

class RiwayatScreen extends StatelessWidget {
  RiwayatScreen({Key? key}) : super(key: key); // Tambahkan Key

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi untuk menghitung rata-rata dari hasil analisis
  Future<Map<String, double>> calculateAverages(String collectionName) async {
    final userId = _auth.currentUser?.email;

    Map<String, double> defaultValues = {
      'marginOfSafety': 0.0,
      'rcRatio': 0.0,
      'bepHarga': 0.0,
      'bepHasil': 0.0,
      'laba': 0.0,
    };

    try {
      // Khusus untuk penggemukan yang tidak memiliki subcollection

      // if (collectionName == 'detail_penggemukan') {
      //   QuerySnapshot penggemukanDocs =
      //       await _firestore.collection(collectionName).get();

      //   if (penggemukanDocs.docs.isEmpty) return defaultValues;

      //   double totalMos = 0;
      //   double totalRc = 0;
      //   double totalBepHarga = 0;
      //   double totalBepHasil = 0;
      //   double totalLaba = 0;
      //   int count = 0;

      //   for (var doc in penggemukanDocs.docs) {
      //     var data = doc.data() as Map<String, dynamic>;
      //     var analisis = data['hasilAnalisis'] as Map<String, dynamic>?;

      //     if (analisis != null) {
      //       totalMos += analisis['marginOfSafety'] ?? 0;
      //       totalRc += analisis['rcRatio'] ?? 0;
      //       totalBepHarga += analisis['bepHarga'] ?? 0;
      //       totalBepHasil += analisis['bepHasil'] ?? 0;
      //       totalLaba += analisis['laba'] ?? 0;
      //       count++;
      //     }
      //   }

      //   if (count == 0) return defaultValues;

      //   return {
      //     'marginOfSafety': totalMos / count,
      //     'rcRatio': totalRc / count,
      //     'bepHarga': totalBepHarga / count,
      //     'bepHasil': totalBepHasil / count,
      //     'laba': totalLaba / count,
      //   };
      // }

      // Untuk collection dengan subcollection (layer dan penetasan)
      QuerySnapshot mainDocs = await _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      if (mainDocs.docs.isEmpty) return defaultValues;

      double totalMos = 0;
      double totalRc = 0;
      double totalBepHarga = 0;
      double totalBepHasil = 0;
      double totalLaba = 0;
      int totalCount = 0;

      for (var mainDoc in mainDocs.docs) {
        QuerySnapshot periodeDocs = await _firestore
            .collection(collectionName)
            .doc(mainDoc.id)
            .collection('analisis_periode')
            .get();

        for (var doc in periodeDocs.docs) {
          var data = doc.data() as Map<String, dynamic>;
          var analisis = data['hasilAnalisis'] as Map<String, dynamic>?;

          if (analisis != null) {
            totalMos += analisis['marginOfSafety'] ?? 0;
            totalRc += analisis['rcRatio'] ?? 0;
            totalBepHarga += analisis['bepHarga'] ?? 0;
            totalBepHasil += analisis['bepHasil'] ?? 0;
            totalLaba += analisis['laba'] ?? 0;
            totalCount++;
          }
        }
      }

      if (totalCount == 0) return defaultValues;

      return {
        'marginOfSafety': totalMos / totalCount,
        'rcRatio': totalRc / totalCount,
        'bepHarga': totalBepHarga / totalCount,
        'bepHasil': totalBepHasil / totalCount,
        'laba': totalLaba / totalCount,
      };
    } catch (e) {
      print('Error calculating averages: $e');
      return defaultValues;
    }
  }

  // Format angka ke rupiah
  String formatCurrency(double value) {
    try {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(value);
    } catch (e) {
      print('Error formatting currency: $e');
      return 'Rp 0';
    }
  }

  // Format persentase
  String formatPercentage(double value) {
    return '${value.toStringAsFixed(2)}%';
  }

  void _navigateToDetail(
      BuildContext context, String title, String collectionName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPeriodePage(
          title: title,
          collectionName: collectionName,
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context,
    String title,
    IconData icon,
    Future<Map<String, double>> averagesFuture,
    String collectionName,
  ) {
    return FutureBuilder<Map<String, double>>(
      future: averagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data...'),
                ],
              ),
            ),
          );
        }

        final averages = snapshot.data ??
            {
              'marginOfSafety': 0.0,
              'rcRatio': 0.0,
              'bepHarga': 0.0,
              'bepHasil': 0.0,
              'laba': 0.0,
            };

        return InkWell(
          // Ganti GestureDetector dengan InkWell untuk efek ripple
          onTap: () => _navigateToDetail(context, title, collectionName),
          child: CustomRiwayatCard(
            icon: icon,
            title: title,
            time: DateFormat('HH:mm').format(DateTime.now()),
            details: {
              'MOS': formatPercentage(averages['marginOfSafety']!),
              'R/C Ratio': averages['rcRatio']!.toStringAsFixed(2),
              'BEP Harga': formatCurrency(averages['bepHarga']!),
              'BEP Hasil': averages['bepHasil']!.toStringAsFixed(2),
              'Laba': formatCurrency(averages['laba']!),
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildAnalysisCard(
                context,
                'Analisis Layer',
                Icons.layers,
                calculateAverages('detail_layer'),
                'detail_layer',
              ),
              _buildAnalysisCard(
                context,
                'Analisis Penetasan',
                Icons.egg,
                calculateAverages('detail_penetasan'),
                'detail_penetasan',
              ),
              _buildAnalysisCard(
                context,
                'Analisis Penggemukan',
                Icons.dashboard_rounded,
                calculateAverages('detail_penggemukan'),
                'detail_penggemukan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
