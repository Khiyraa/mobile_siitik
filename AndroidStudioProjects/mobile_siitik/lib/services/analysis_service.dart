// lib/services/analysis_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analysis_data.dart';

class AnalysisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk mendapatkan data analisis periode
  Stream<List<AnalysisData>> getAnalysisPeriodStream(String id_layer) {
    return _firestore
        .collection('detail_penetasan')
        .doc(id_layer)
        .collection('analisis_periode')
        .orderBy('created_at', descending: true)
        .limit(12) // Ambil 12 bulan terakhir
        .snapshots()
        .map((snapshot) {
      // print('Jumlah dokumen ditemukan: ${snapshot.docs[0].data()}');
      return snapshot.docs
          .map((doc) => AnalysisData.fromMap(doc.data()))
          .toList();
    });
  }

  // Fungsi untuk menambah data analisis baru
  Future<void> addAnalysisPeriod(AnalysisData data) async {
    await _firestore.collection('analisis_periode').add(data.toMap());
  }

  // Fungsi untuk mendapatkan detail analisis berdasarkan tipe
  Stream<DocumentSnapshot> getAnalysisTypeStream(String type, String userId) {
    return _firestore.collection('analysis_types').doc(type).snapshots();
  }
}
