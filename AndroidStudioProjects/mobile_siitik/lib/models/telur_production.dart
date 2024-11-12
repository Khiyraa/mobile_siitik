// lib/models/telur_production.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TelurProduction {
  final int jantan;
  final int betina;
  final double periodeIni;
  final double betinaSebelumnya;
  final DateTime createdAt;
  final String userId;

  TelurProduction({
    required this.jantan,
    required this.betina,
    required this.periodeIni,
    required this.betinaSebelumnya,
    required this.createdAt,
    required this.userId,
  });

  factory TelurProduction.fromMap(Map<String, dynamic> map) {
    return TelurProduction(
      jantan: (map['jantan'] as num).toInt(),
      betina: (map['betina'] as num).toInt(),
      periodeIni: (map['periode_ini'] as num).toDouble(),
      betinaSebelumnya: (map['betina_sebelumnya'] as num).toDouble(),
      createdAt: (map['created_at'] as Timestamp).toDate(),
      userId: map['userId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jantan': jantan,
      'betina': betina,
      'periode_ini': periodeIni,
      'betina_sebelumnya': betinaSebelumnya,
      'created_at': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  // Helper method untuk mendapatkan total itik
  int get totalDucks => jantan + betina;

  // Helper method untuk mendapatkan persentase produksi
  double get productionPercentage => (periodeIni / totalDucks) * 100;

  // Helper method untuk mendapatkan perubahan produksi
  double get productionChange {
    if (betinaSebelumnya == 0) return 0;
    return ((periodeIni - betinaSebelumnya) / betinaSebelumnya) * 100;
  }
}