import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/telur_production.dart';

class TelurService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _telurCollection =>
      _firestore.collection('telur_production');

  // Stream untuk mendapatkan data produksi telur terbaru
  Stream<TelurProduction> getTelurProductionStream() {
    return _telurCollection
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        // Return data default jika belum ada data
        return TelurProduction(
          jantan: 0,
          betina: 0,
          periodeIni: 0,
          betinaSebelumnya: 0,
          createdAt: DateTime.now(),
          userId: '',
        );
      }
      return TelurProduction.fromMap(
          snapshot.docs.first.data() as Map<String, dynamic>
      );
    });
  }

  // Mendapatkan data produksi telur berdasarkan periode
  Future<List<TelurProduction>> getTelurProductionByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final snapshot = await _telurCollection
        .where('created_at', isGreaterThanOrEqualTo: startDate)
        .where('created_at', isLessThanOrEqualTo: endDate)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TelurProduction.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Menambah data produksi telur baru
  Future<void> addTelurProduction(TelurProduction production) async {
    await _telurCollection.add(production.toMap());
  }

  // Mengupdate data produksi telur
  Future<void> updateTelurProduction(
      String id,
      TelurProduction production,
      ) async {
    await _telurCollection.doc(id).update(production.toMap());
  }

  // Menghapus data produksi telur
  Future<void> deleteTelurProduction(String id) async {
    await _telurCollection.doc(id).delete();
  }

  // Mendapatkan ringkasan produksi untuk dashboard
  Future<Map<String, dynamic>> getTelurProductionSummary() async {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, now.day);

    final currentProduction = await _telurCollection
        .where('created_at', isGreaterThanOrEqualTo: lastMonth)
        .orderBy('created_at', descending: true)
        .get();

    if (currentProduction.docs.isEmpty) {
      return {
        'total_ducks': 0,
        'total_production': 0,
        'production_rate': 0,
        'monthly_change': 0,
      };
    }

    final latestData = TelurProduction.fromMap(
        currentProduction.docs.first.data() as Map<String, dynamic>
    );

    return {
      'total_ducks': latestData.totalDucks,
      'total_production': latestData.periodeIni,
      'production_rate': latestData.productionPercentage,
      'monthly_change': latestData.productionChange,
    };
  }

  // Stream untuk monitoring perubahan total itik
  Stream<int> getTotalDucksStream() {
    return _telurCollection
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0;
      final data = TelurProduction.fromMap(
          snapshot.docs.first.data() as Map<String, dynamic>
      );
      return data.totalDucks;
    });
  }

  // Stream untuk monitoring produksi harian
  Stream<List<TelurProduction>> getDailyProductionStream(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _telurCollection
        .where('created_at', isGreaterThanOrEqualTo: startOfDay)
        .where('created_at', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TelurProduction.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Mendapatkan statistik produksi
  Future<Map<String, dynamic>> getProductionStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final snapshot = await _telurCollection
        .where('created_at', isGreaterThanOrEqualTo: startDate)
        .where('created_at', isLessThanOrEqualTo: endDate)
        .orderBy('created_at')
        .get();

    final productions = snapshot.docs
        .map((doc) => TelurProduction.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    if (productions.isEmpty) {
      return {
        'average_production': 0,
        'highest_production': 0,
        'lowest_production': 0,
        'total_production': 0,
      };
    }

    final productionValues = productions.map((p) => p.periodeIni).toList();

    return {
      'average_production': productionValues.reduce((a, b) => a + b) / productionValues.length,
      'highest_production': productionValues.reduce((a, b) => a > b ? a : b),
      'lowest_production': productionValues.reduce((a, b) => a < b ? a : b),
      'total_production': productionValues.reduce((a, b) => a + b),
    };
  }
}