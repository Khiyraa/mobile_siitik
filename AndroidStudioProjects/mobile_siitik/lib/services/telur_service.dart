import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/telur_production.dart';

class TelurService {
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
}