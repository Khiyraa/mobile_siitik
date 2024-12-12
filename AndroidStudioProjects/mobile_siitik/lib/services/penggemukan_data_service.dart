import 'package:cloud_firestore/cloud_firestore.dart';

class PenggemukanDataService {
  // Method untuk mengambil data penggemukan berdasarkan periode terbaru
  static Future<List<Map<String, dynamic>>> fetchPenggemukanData() async {
    try {
      // Ambil dokumen terbaru dari koleksi penggemukan
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('detail_penggemukan')
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Ambil ID dari dokumen pertama yang ditemukan
        String analysisId = querySnapshot.docs.first.id;

        // Ambil data periode yang terbaru
        QuerySnapshot periodeSnapshot = await FirebaseFirestore.instance
            .collection('detail_penggemukan')
            .doc(analysisId)
            .collection('analisis_periode')
            .orderBy('created_at', descending: true)
            .limit(1)
            .get();

        if (periodeSnapshot.docs.isNotEmpty) {
          // Ambil data periode pertama
          DocumentSnapshot periodeDoc = periodeSnapshot.docs.first;
          var data = periodeDoc.data() as Map<String, dynamic>;

          // Kembalikan data dalam format yang dibutuhkan oleh widget
          return [
            {
              'penerimaan': data['penerimaan'],
              'pengeluaran': data['pengeluaran'],
              'hasilAnalisis': data['hasilAnalisis'],
            }
          ];
        } else {
          print('Data periode penggemukan tidak ditemukan');
          return [];
        }
      } else {
        print('Data analisis penggemukan tidak ditemukan');
        return [];
      }
    } catch (e) {
      print('Error fetching data from Firestore: $e');
      return [];
    }
  }
}
