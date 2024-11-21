// lib/screens/detail_periode_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mobile_siitik/core/constants/app_colors.dart';


class DetailPeriodePage extends StatelessWidget {
  final String title;
  final String collectionName;

  const DetailPeriodePage({
    Key? key,
    required this.title,
    required this.collectionName,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> getDetailPeriode() async {
    List<Map<String, dynamic>> details = [];
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // Untuk collection dengan subcollection (detail_layer dan detail_penetasan)
      if (collectionName != 'detail_penggemukan') {
        // Menggunakan collectionGroup untuk mengambil semua dokumen dalam subcollection analisis_periode
        QuerySnapshot periodeDocs = await _firestore
            .collectionGroup('analisis_periode')
            .orderBy('created_at', descending: true)
            .get();

        for (var doc in periodeDocs.docs) {
          // Dapatkan reference ke dokumen parent
          DocumentReference parentRef = doc.reference.parent.parent!;

          // Periksa apakah dokumen parent berasal dari collection yang kita inginkan
          if (parentRef.parent.id == collectionName) {
            var data = doc.data() as Map<String, dynamic>;
            details.add({
              'periode': data['periode'] ?? 'Tidak ada periode',
              'data': data,
              'id': doc.id,
              'parentId': parentRef.id,
            });
          }
        }
      } else {
        // Untuk detail_penggemukan (tanpa subcollection)
        QuerySnapshot snapshot = await _firestore
            .collection(collectionName)
            .orderBy('created_at', descending: true)
            .get();

        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          details.add({
            'periode': data['periode'] ?? 'Tidak ada periode',
            'data': data,
            'id': doc.id,
          });
        }
      }

      // Sort berdasarkan periode jika diperlukan
      details.sort((a, b) {
        var periodeA = int.tryParse(a['periode'].toString()) ?? 0;
        var periodeB = int.tryParse(b['periode'].toString()) ?? 0;
        return periodeB.compareTo(periodeA); // descending order
      });

      return details;
    } catch (e) {
      print('Error getting detail periode: $e');
      return [];
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: AppColors.background,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getDetailPeriode(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final details = snapshot.data ?? [];

            if (details.isEmpty) {
              return const Center(child: Text('Tidak ada data periode'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: details.length,
              itemBuilder: (context, index) {
                final periodeData = details[index];
                final data = periodeData['data'] as Map<String, dynamic>;
                final hasilAnalisis = data['hasilAnalisis'] as Map<String, dynamic>;
                final penerimaan = data['penerimaan'] as Map<String, dynamic>;

                // Informasi umum yang ada di semua analisis
                List<Widget> commonInfo = [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Periode ${periodeData['periode']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        hasilAnalisis['rcRatio'] >= 1 ? 'Efisien' : 'Tidak Efisien',
                        style: TextStyle(
                          color: hasilAnalisis['rcRatio'] >= 1
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildInfoRow('R/C Ratio',
                      hasilAnalisis['rcRatio']?.toStringAsFixed(2) ?? 'N/A'),
                  _buildInfoRow('Margin of Safety',
                      '${hasilAnalisis['marginOfSafety']?.toStringAsFixed(2)}%'),
                  _buildInfoRow('Laba',
                      formatCurrency(hasilAnalisis['laba']?.toDouble() ?? 0)),
                ];

                // Informasi spesifik berdasarkan jenis analisis
                if (collectionName == 'detail_penetasan') {
                  commonInfo.addAll([
                    const Divider(),
                    Text(
                      'Informasi Penetasan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Jumlah Telur',
                        '${penerimaan['jumlahTelur']} butir'),
                    _buildInfoRow('Telur Menetas',
                        '${penerimaan['jumlahTelurMenetas']} butir'),
                    _buildInfoRow('Jumlah DOD',
                        '${penerimaan['jumlahDOD']} ekor'),
                    _buildInfoRow('Persentase Penetasan',
                        '${penerimaan['persentase']?.toStringAsFixed(2)}%'),
                    _buildInfoRow('Harga DOD',
                        formatCurrency(penerimaan['hargaDOD']?.toDouble() ?? 0)),
                  ]);
                } else if (collectionName == 'detail_penggemukan') {
                  final pengeluaran = data['pengeluaran'] as Map<String, dynamic>;
                  commonInfo.addAll([
                    const Divider(),
                    Text(
                      'Informasi Penggemukan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Jumlah Itik Awal',
                        '${penerimaan['jumlahItikAwal']} ekor'),
                    _buildInfoRow('Jumlah Itik Setelah Mortalitas',
                        '${penerimaan['jumlahItikSetelahMortalitas']} ekor'),
                    _buildInfoRow('Persentase Mortalitas',
                        '${penerimaan['persentaseMortalitas']?.toStringAsFixed(2)}%'),
                    _buildInfoRow('Harga per Itik',
                        formatCurrency(penerimaan['hargaItik']?.toDouble() ?? 0)),
                    const Divider(),
                    Text(
                      'Biaya Produksi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Standar Pakan',
                        '${pengeluaran['standardPakan']} gram'),
                    _buildInfoRow('Jumlah Pakan',
                        '${pengeluaran['jumlahPakan']} kg'),
                    _buildInfoRow('Harga Pakan/kg',
                        formatCurrency(pengeluaran['hargaPakan']?.toDouble() ?? 0)),
                  ]);
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Periode ${periodeData['periode']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                hasilAnalisis['rcRatio'] >= 1 ? 'Efisien' : 'Tidak Efisien',
                                style: TextStyle(
                                  color: hasilAnalisis['rcRatio'] >= 1
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          _buildInfoRow('R/C Ratio',
                              hasilAnalisis['rcRatio']?.toStringAsFixed(2) ?? 'N/A'),
                          _buildInfoRow('Margin of Safety',
                              '${hasilAnalisis['marginOfSafety']?.toStringAsFixed(2)}%'),
                          _buildInfoRow('Laba',
                              formatCurrency(hasilAnalisis['laba']?.toDouble() ?? 0)),
                          if (collectionName == 'detail_penetasan')
                            _buildInfoRow('Persentase Penetasan',
                                '${penerimaan['persentase']?.toStringAsFixed(2)}%'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}