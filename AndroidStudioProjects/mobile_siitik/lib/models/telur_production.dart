import 'package:cloud_firestore/cloud_firestore.dart';

class TelurProduction {
  final int jantan;
  final int betina;
  final double periodeIni;
  late final double betinaSebelumnya;
  final DateTime createdAt;
  final String userId;
  final Map<String, dynamic>? penerimaan;
  final Map<String, dynamic>? pengeluaran;

  TelurProduction({
    required this.jantan,
    required this.betina,
    required this.periodeIni,
    required this.betinaSebelumnya,
    required this.createdAt,
    required this.userId,
    this.penerimaan,
    this.pengeluaran,
  });

  factory TelurProduction.fromMap(Map<String, dynamic> map) {
    return TelurProduction(
      jantan: map['jumlahTelur'] != null
          ? (map['jumlahTelur'] as num).toInt()
          : 0,
      betina: map['jumlahTelurMenetas'] != null
          ? (map['jumlahTelurMenetas'] as num).toInt()
          : 0,
      periodeIni: 219.0,  // Sesuaikan jika diperlukan
      betinaSebelumnya: map['betinaSebelumnya'] != null
          ? (map['betinaSebelumnya'] as num).toDouble()
          : 0.0,
      createdAt: map['created_at'] != null
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      userId: map['userId'] as String? ?? '',
      penerimaan: map['penerimaan'] as Map<String, dynamic>?,
      pengeluaran: map['pengeluaran'] as Map<String, dynamic>?,
    );
  }

  // Method untuk mengambil data dari koleksi Firestore berdasarkan analysisId dan periodeId terbaru
  static Future<TelurProduction?> getLatestData(String analysisType) async {
    try {
      // Query untuk mengambil dokumen berdasarkan 'created_at' terbaru dari koleksi detail_layer
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('detail_layer')  // Koleksi detail_layer
          .orderBy('created_at', descending: true)  // Urutkan berdasarkan created_at terbaru
          .limit(1)  // Ambil hanya satu dokumen terbaru
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Ambil id analisis terbaru dari dokumen pertama
        String analysisId = querySnapshot.docs.first.id;

        // Ambil koleksi analisis_periode untuk mendapatkan periodeId terbaru
        QuerySnapshot periodeSnapshot = await FirebaseFirestore.instance
            .collection('detail_layer')
            .doc(analysisId)
            .collection('analisis_periode')  // Koleksi analisis_periode
            .orderBy('created_at', descending: true)  // Urutkan berdasarkan periode terbaru
            .limit(1)  // Ambil hanya satu periode terbaru
            .get();

        if (periodeSnapshot.docs.isNotEmpty) {
          // Ambil data periode dari dokumen pertama di analisis_periode
          DocumentSnapshot periodeDoc = periodeSnapshot.docs.first;

          // Debugging: print seluruh data dari periodeDoc untuk verifikasi
          print('Data dokumen periode: ${periodeDoc.data()}');

          var data = periodeDoc.data() as Map<String, dynamic>;

          // Debugging output untuk memverifikasi apakah 'penerimaan' dan 'pengeluaran' ada
          print('Penerimaan di Firestore: ${data['penerimaan']}');
          print('Pengeluaran di Firestore: ${data['pengeluaran']}');

          // Kembalikan data yang telah dipetakan ke dalam model TelurProduction
          return TelurProduction.fromMap(data);
        } else {
          print('Dokumen periodeId terbaru tidak ditemukan');
          return null;
        }
      } else {
        print('Dokumen analysisId terbaru tidak ditemukan');
        return null; // Data tidak ditemukan
      }
    } catch (e) {
      print('Error fetching latest data: $e');
      return null;
    }
  }


  Map<String, dynamic> toMap() {
    return {
      'jumlahTelur': jantan,
      'jumlahTelurMenetas': betina,
      'periodeIni': periodeIni,
      'betinaSebelumnya': betinaSebelumnya,
      'created_at': Timestamp.fromDate(createdAt),
      'userId': userId,
      'penerimaan': penerimaan,
      'pengeluaran': pengeluaran,
    };
  }

  int get totalDucks => jantan + betina;

  double get productionPercentage =>
      totalDucks > 0 ? (periodeIni / totalDucks) * 100 : 0.0;

  double get productionChange {
    if (betinaSebelumnya == 0) return 0.0;
    return ((periodeIni - betinaSebelumnya) / betinaSebelumnya) * 100;
  }

  // Helper method untuk mendapatkan data untuk average card
  Map<String, dynamic> toAverageData() {
    // Print penerimaan untuk memeriksa apakah data diterima dengan benar
    print('Penerimaan: $penerimaan');

    // Print pengeluaran untuk memeriksa apakah data diterima dengan benar
    print('Pengeluaran: $pengeluaran');

    return {
      'penerimaan': penerimaan ?? {
        'totalRevenue': penerimaan?['totalRevenue'] ?? 0.0, // Ambil total revenue jika ada
        'jumlahTelurDihasilkan': penerimaan?['jumlahTelurDihasilkan'] ?? 0.0, // Ambil jumlah telur jika ada
        'persentaseBertelur': penerimaan?['persentaseBertelur'] ?? 0.0, // Ambil persentase bertelur jika ada
      },
      'pengeluaran': pengeluaran ?? {
        'totalCost': pengeluaran?['totalCost'] ?? 0.0, // Ambil total cost jika ada
      },
    };
  }
}
