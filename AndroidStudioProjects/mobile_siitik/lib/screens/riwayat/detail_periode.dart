import 'package:firebase_auth/firebase_auth.dart';
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

  // Fungsi untuk memformat tanggal
  String formatDate(Timestamp timestamp) {
    // Mengonversi Timestamp ke DateTime
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy').format(dateTime); // Format tanggal
  }

  Future<List<Map<String, dynamic>>> getDetailPeriode() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final userId = _auth.currentUser?.email;
    List<Map<String, dynamic>> details = [];
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot mainDocs = await _firestore
          .collection(collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('created_at', descending: true) // Pastikan 'created_at' ada dan berisi
          .get();

      for (var mainDoc in mainDocs.docs) {
        QuerySnapshot periodeDocs = await _firestore
            .collection(collectionName)
            .doc(mainDoc.id)
            .collection('analisis_periode')
            .get();

        // Group data by docId
        List<Map<String, dynamic>> periodeList = [];

        for (var doc in periodeDocs.docs) {
          var data = doc.data() as Map<String, dynamic>;

          periodeList.add({
            'periode': data['periode'] ?? 'Tidak ada periode',
            'data': data,
            'id': doc.id,
          });
        }

        // Sort berdasarkan periode dari terkecil ke terbesar
        periodeList.sort((a, b) {
          var periodeA = int.tryParse(a['periode'].toString()) ?? 0;
          var periodeB = int.tryParse(b['periode'].toString()) ?? 0;
          return periodeA.compareTo(periodeB); // ascending order
        });

        details.add({
          'docId': mainDoc.id,
          'periods': periodeList,
        });
      }

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

  String formatPersentase(dynamic value) {
    if (value == null) return '0.00%';
    if (value is String) return '${double.parse(value).toStringAsFixed(2)}%';
    if (value is num) return '${value.toStringAsFixed(2)}%';
    return '0.00%';
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
        child: FutureBuilder<List<Map<String, dynamic>>>( // FutureBuilder to load the data
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
                final docData = details[index];
                final docId = docData['docId'];
                final periodeList = docData['periods'] as List<Map<String, dynamic>>;

                // Informasi umum yang ada di semua analisis
                List<Widget> commonInfo = [];

                for (var periodeData in periodeList) {
                  final data = periodeData['data'] as Map<String, dynamic>;
                  final hasilAnalisis = data['hasilAnalisis'] as Map<String, dynamic>;
                  final penerimaan = data['penerimaan'] as Map<String, dynamic>;

                  commonInfo.add(
                    Card(
                      margin: const EdgeInsets.only(bottom: 20), // Jarak antar analisis
                      color: Colors.white,  // Memberikan warna putih pada card
                      elevation: 15,  // Menambahkan shadow dan memperjelasnya
                      shadowColor: Colors.black.withOpacity(0.8),  // Mengatur warna shadow agar lebih jelas
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0), // Membuat sudut card melengkung
                      ),
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Menampilkan Periode dan Tanggal
                                  Text(
                                    'Periode: ${periodeData['periode']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // Pastikan field created_at adalah Timestamp
                                  Text(
                                    'Tanggal: ${formatDate(data['created_at'])}', // Mengambil tanggal dari field created_at
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              _buildInfoRow(
                                  'R/C Ratio',
                                  hasilAnalisis['rcRatio']?.toStringAsFixed(2) ?? 'N/A'),
                              _buildInfoRow(
                                  'Margin of Safety',
                                  '${hasilAnalisis['marginOfSafety']?.toStringAsFixed(2)}%'),
                              _buildInfoRow(
                                  'Laba',
                                  formatCurrency(hasilAnalisis['laba']?.toDouble() ?? 0)),

                              // Menampilkan informasi spesifik berdasarkan collection
                              if (collectionName == 'detail_penetasan') ...[
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
                                _buildInfoRow(
                                    'Jumlah Telur', '${penerimaan['jumlahTelur']} butir'),
                                _buildInfoRow(
                                    'Telur Menetas', '${penerimaan['jumlahTelurMenetas']} butir'),
                                _buildInfoRow(
                                    'Jumlah DOD', '${penerimaan['jumlahDOD']} ekor'),
                                _buildInfoRow(
                                    'Persentase Penetasan',
                                    formatPersentase(penerimaan['persentase'])),
                                _buildInfoRow(
                                    'Harga DOD',
                                    formatCurrency(penerimaan['hargaDOD']?.toDouble() ?? 0)),
                              ],

                              if (collectionName == 'detail_penggemukan') ...[
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
                                    '${data['pengeluaran']['standardPakan']} gram'),
                                _buildInfoRow(
                                    'Jumlah Pakan', '${data['pengeluaran']['jumlahPakan']} kg'),
                                _buildInfoRow(
                                    'Harga Pakan/kg',
                                    formatCurrency(
                                        data['pengeluaran']['hargaPakan']?.toDouble() ?? 0)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dokumen ID: $docId', // Menampilkan ID dokumen
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    ...commonInfo,
                    const SizedBox(height: 16.0),
                  ],
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
