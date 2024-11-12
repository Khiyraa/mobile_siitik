import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analysis_data.dart';

class AnalysisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<TelurProduction> getTelurProductionStream() {
    return _firestore
        .collection('telur_production')
        .doc('current')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return TelurProduction.fromMap(snapshot.data()!);
      }
      return TelurProduction(
        jantan: 0,
        betina: 0,
        periodeIni: 0,
        betinaSebelumnya: 0,
      );
    });
  }

  Stream<List<AnalysisData>> getAnalysisPeriodStream() {
    return _firestore
        .collection('analysis_periods')
        .orderBy('created_at', descending: true)
        .limit(12) // Ambil 12 bulan terakhir
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AnalysisData.fromMap(doc.data()))
          .toList();
    });
  }
}