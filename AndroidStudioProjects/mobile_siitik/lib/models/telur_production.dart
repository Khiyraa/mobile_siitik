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
      // Tambahkan null check dan konversi yang aman
      jantan: map['jumlahTelur'] != null
          ? (map['jumlahTelur'] as num).toInt()
          : 0,
      betina: map['jumlahTelurMenetas'] != null
          ? (map['jumlahTelurMenetas'] as num).toInt()
          : 0,
      periodeIni: 219.0, // Pastikan menggunakan .0 untuk double literal
      betinaSebelumnya: map['betinaSebelumnya'] != null
          ? (map['betinaSebelumnya'] as num).toDouble()
          : 0.0,
      createdAt: map['created_at'] != null
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      userId: map['userId'] as String? ?? '',
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

  int get totalDucks => jantan + betina;

  double get productionPercentage =>
      totalDucks > 0 ? (periodeIni / totalDucks) * 100 : 0.0;

  double get productionChange {
    if (betinaSebelumnya == 0) return 0.0;
    return ((periodeIni - betinaSebelumnya) / betinaSebelumnya) * 100;
  }
}