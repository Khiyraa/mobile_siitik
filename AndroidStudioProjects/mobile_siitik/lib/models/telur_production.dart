// lib/models/telur_production.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TelurProduction {
  final int jantan;
  final int betina;
  final double periodeIni;
  late final double betinaSebelumnya;
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
      jantan: (map['jumlahTelur'] as num).toInt(),
      betina: (map['jumlahTelurMenetas'] as num).toInt(),
      periodeIni: (map['jumlahTelur'] as num).toDouble(),
      betinaSebelumnya: (map['betinaSebelumnya'] as num?)?.toDouble() ?? 0.0,
      createdAt: (map['created_at'] as Timestamp).toDate(),
      userId: map['userId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jumlahTelur': jantan,
      'jumlahTelurMenetas': betina,
      'periodeIni': periodeIni,
      'betinaSebelumnya': betinaSebelumnya,
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
