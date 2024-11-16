// lib/services/telur_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/telur_production.dart';
import 'package:mobile_siitik/services/FirebaseDataAccess.dart';

class TelurService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDataAccess _firebaseDataAccess = FirebaseDataAccess();


  Future<Map<String, dynamic>> getAnalysisPeriodData() async {
    return await _firebaseDataAccess.getAnalysisPeriodData();
  }

  Future<Map<String, dynamic>> getHatchingData() async {
    return await _firebaseDataAccess.getHatchingData();
  }

  Future<Map<String, dynamic>> getFatteningData() async {
    return await _firebaseDataAccess.getFatteningData();
  }

  // Stream untuk mendapatkan data telur terbaru
  Stream<TelurProduction> getTelurProductionStream() {
    final userId = _auth.currentUser?.email;
    if (userId == null) {
      throw Exception('User tidak terautentikasi');
    }

    return _firestore
        .collection('analysis_periods')
        .where('userId', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        // Return default values jika tidak ada data
        return TelurProduction(
          jantan: 150,
          betina: 100,
          periodeIni: 25,
          betinaSebelumnya: 40,
          createdAt: DateTime.now(),
          userId: userId,
        );
      }

      final currentDoc = snapshot.docs.first;
      final currentData = currentDoc.data();

      // Mengambil data periode sebelumnya
      final previousSnapshot = await _firestore
          .collection('analysis_periods')
          .where('userId', isEqualTo: userId)
          .where('created_at', isLessThan: currentData['created_at'])
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      final previousProduction = previousSnapshot.docs.isNotEmpty
          ? previousSnapshot.docs.first.data()['jumlahTelur'] ?? 0.0
          : 0.0;

      return TelurProduction(
        jantan: currentData['jumlahTelur'] ?? 0,
        betina: currentData['jumlahTelurMenetas'] ?? 0,
        periodeIni: (currentData['jumlahTelur'] ?? 0).toDouble(),
        betinaSebelumnya: previousProduction.toDouble(),
        createdAt: (currentData['created_at'] as Timestamp).toDate(),
        userId: userId,
      );
    });
  }

  // Method untuk menyimpan data produksi telur baru
  Future<void> saveTelurProduction({
    required int jumlahTelur,
    required int jumlahTelurMenetas,
  }) async {
    final userId = _auth.currentUser?.email;
    if (userId == null) {
      throw Exception('User tidak terautentikasi');
    }

    // Pertama, simpan analysis type
    await _firestore
        .collection('analysis_types')
        .doc('detail_layer')
        .set({
      'userId': userId,
      'created_at': Timestamp.now(),
    }, SetOptions(merge: true));

    // Kemudian simpan data analisis
    await _firestore
        .collection('analysis_periods')
        .add({
      'userId': userId,
      'jumlahTelur': jumlahTelur,
      'jumlahTelurMenetas': jumlahTelurMenetas,
      'created_at': Timestamp.now(),
    });
  }

  // Method untuk mengupdate data produksi telur
  Future<void> updateTelurProduction({
    required String docId,
    required int jumlahTelur,
    required int jumlahTelurMenetas,
  }) async {
    final userId = _auth.currentUser?.email;
    if (userId == null) {
      throw Exception('User tidak terautentikasi');
    }

    await _firestore
        .collection('analysis_periods')
        .doc(docId)
        .update({
      'jumlahTelur': jumlahTelur,
      'jumlahTelurMenetas': jumlahTelurMenetas,
      'updated_at': Timestamp.now(),
    });
  }

  // Method untuk mendapatkan riwayat produksi telur
  Stream<List<TelurProduction>> getTelurProductionHistory() {
    final userId = _auth.currentUser?.email;
    if (userId == null) {
      throw Exception('User tidak terautentikasi');
    }

    return _firestore
        .collection('analysis_periods')
        .where('userId', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<TelurProduction> productions = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = (data['created_at'] as Timestamp).toDate();

        // Mengambil data periode sebelumnya untuk setiap dokumen
        final previousSnapshot = await _firestore
            .collection('analysis_periods')
            .where('userId', isEqualTo: userId)
            .where('created_at', isLessThan: data['created_at'])
            .orderBy('created_at', descending: true)
            .limit(1)
            .get();

        final previousProduction = previousSnapshot.docs.isNotEmpty
            ? previousSnapshot.docs.first.data()['jumlahTelur'] ?? 0.0
            : 0.0;

        productions.add(TelurProduction(
          jantan: data['jumlahTelur'] ?? 0,
          betina: data['jumlahTelurMenetas'] ?? 0,
          periodeIni: (data['jumlahTelur'] ?? 0).toDouble(),
          betinaSebelumnya: previousProduction.toDouble(),
          createdAt: createdAt,
          userId: userId,
        ));
      }

      return productions;
    });
  }
}