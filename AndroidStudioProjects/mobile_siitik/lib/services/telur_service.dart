// lib/services/telur_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_siitik/services/FirebaseDataAccess.dart';
import '../models/telur_production.dart';

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
  Stream<TelurProduction> getTelurProductionStream(
      String idLayer, String idPenggemukan) {
    final userId = _auth.currentUser?.email;

    // print(idPenggemukan.toString());
    if (userId == null) {
      throw Exception('User tidak terautentikasi');
    }

    return _firestore
        .collection('detail_layer')
        .doc(idLayer)
        .collection('analisis_periode')
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .handleError((error) {
      print('Error in getTelurProductionStream: $error');
      throw error;
    }).asyncMap((snapshot) async {
      try {
        if (snapshot.docs.isEmpty) {
          return _createDefaultTelurProduction(userId);
        }

        final currentDoc = snapshot.docs.first;
        final currentDataLayer = currentDoc.data();

        final Timestamp currentTimestamp =
            currentDataLayer['created_at'] as Timestamp;
        // print("currentTimestamp : $currentTimestamp");

        // Mengambil data periode sebelumnya dari subcollection yang sama
        final previousSnapshot = await _firestore
            .collection('detail_layer')
            .doc(idLayer)
            .collection('analisis_periode')
            .where('created_at', isLessThan: currentDataLayer['created_at'])
            .orderBy('created_at', descending: true)
            .limit(1)
            .get();

        final penggemukanSnapshot = await _firestore
            .collection('detail_penggemukan')
            .doc(idPenggemukan)
            .collection('analisis_periode')
            .orderBy('created_at', descending: true)
            .limit(1)
            .get();

        Map<String, dynamic> currentDataPenggemukan = {};

        if (penggemukanSnapshot.docs.isNotEmpty) {
          currentDataPenggemukan = penggemukanSnapshot.docs.first.data();
        }

        final previousProduction = previousSnapshot.docs.isNotEmpty
            ? previousSnapshot.docs.first.data()['penerimaan']
                    ['jumlahItikAwal'] ??
                0.0
            : 0.1;

        // print("previousProduction : $previousProduction");

        return _createTelurProduction(
          currentDataLayer: currentDataLayer,
          currentDataPenggemukan: currentDataPenggemukan,
          previousProduction: previousProduction.toDouble(),
          userId: userId,
        );
      } catch (e) {
        print('Error processing telur production data: $e');
        return _createDefaultTelurProduction(userId);
      }
    });
  }

  TelurProduction _createDefaultTelurProduction(String userId) {
    return TelurProduction(
      jantan: 0,
      betina: 0,
      periodeIni: 0,
      betinaSebelumnya: 0,
      createdAt: DateTime.now(),
      userId: userId,
    );
  }

  TelurProduction _createTelurProduction({
    Map<String, dynamic> currentDataLayer = const {},
    Map<String, dynamic> currentDataPenggemukan = const {},
    required double previousProduction,
    required String userId,
  }) {
    final penerimaan = currentDataLayer['penerimaan'] as Map;
    final penerimaanPenggemukan = currentDataPenggemukan['penerimaan'] as Map;
    return TelurProduction(
      jantan: penerimaanPenggemukan['jumlahItikSetelahMortalitas'] ?? 0,
      betina: penerimaan['jumlahItikAwal'] ?? 0,
      periodeIni: (penerimaan['jumlahTelurDihasilkan'] ?? 0).toDouble(),
      betinaSebelumnya: previousProduction,
      createdAt: (currentDataLayer['created_at'] as Timestamp).toDate(),
      userId: userId,
    );
  }

  // Method untuk menyimpan data produksi telur baru
  Future<void> saveTelurProduction({
    required String idLayer,
    required int jumlahTelur,
    required int jumlahTelurMenetas,
  }) async {
    final userId = _auth.currentUser?.email;
    if (userId == null) {
      throw Exception('User tidak terautentikasi');
    }

    try {
      final batch = _firestore.batch();

      // Reference untuk dokumen baru di subcollection
      final newAnalysisPeriodRef = _firestore
          .collection('detail_layer')
          .doc(idLayer)
          .collection('analisis_periode')
          .doc();

      batch.set(newAnalysisPeriodRef, {
        'userId': userId,
        'jumlahTelur': jumlahTelur,
        'jumlahTelurMenetas': jumlahTelurMenetas,
        'created_at': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      print('Error saving telur production: $e');
      throw Exception('Gagal menyimpan data produksi telur');
    }
  }

  // Method untuk mengupdate data produksi telur
  Future<void> updateTelurProduction({
    required String idLayer,
    required String docId,
    required int jumlahTelur,
    required int jumlahTelurMenetas,
  }) async {
    final userId = _auth.currentUser?.email;
    if (userId == null) {
      throw Exception('User tidak terautentikasi');
    }

    try {
      await _firestore
          .collection('detail_layer')
          .doc(idLayer)
          .collection('analisis_periode')
          .doc(docId)
          .update({
        'jumlahTelur': jumlahTelur,
        'jumlahTelurMenetas': jumlahTelurMenetas,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating telur production: $e');
      throw Exception('Gagal mengupdate data produksi telur');
    }
  }

  // Method untuk mendapatkan riwayat produksi telur
  Stream<List<TelurProduction>> getTelurProductionHistory(String idLayer) {
    final userId = _auth.currentUser?.email;
    if (userId == null) {
      throw Exception('User tidak terautentikasi');
    }

    return _firestore
        .collection('detail_layer')
        .doc(idLayer)
        .collection('analisis_periode')
        .where('userId', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .handleError((error) {
      print('Error in getTelurProductionHistory: $error');
      throw error;
    }).map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TelurProduction(
          jantan: data['jumlahTelur'] ?? 0,
          betina: data['jumlahTelurMenetas'] ?? 0,
          periodeIni: (data['jumlahTelur'] ?? 0).toDouble(),
          betinaSebelumnya: 0.0, // Set in a separate operation if needed
          createdAt: (data['created_at'] as Timestamp).toDate(),
          userId: userId,
        );
      }).toList();
    });
  }

  // Method untuk mendapatkan previous production value
  Future<void> updatePreviousProductionValues(
    List<TelurProduction> productions,
    String idLayer,
  ) async {
    final userId = _auth.currentUser?.email;
    if (userId == null) return;

    for (var i = 0; i < productions.length; i++) {
      if (i < productions.length - 1) {
        productions[i].betinaSebelumnya = productions[i + 1].periodeIni;
      }
    }
  }
}
