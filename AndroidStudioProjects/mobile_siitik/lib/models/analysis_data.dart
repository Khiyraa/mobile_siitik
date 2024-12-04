import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisDataException implements Exception {
  final String message;
  AnalysisDataException(this.message);

  // Untuk Penetasan
  double? persentaseMenetas;
  double? jumlahDOD;

// Untuk Layer
  double? produksiTelur;
  double? persentaseBertelur;

// Untuk Penggemukan
  double? mortalitas;
  double? konsumsiFeed;

  @override
  String toString() => 'AnalysisDataException: $message';
}

class AnalysisData {
  final double revenue;
  final double cost;
  final double profit;
  final DateTime createdAt;
  final Map<String, dynamic>? penerimaan;
  final Map<String, dynamic>? pengeluaran;

  // Private constructor
  const AnalysisData._({
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.createdAt,
    this.penerimaan,
    this.pengeluaran,
  });

  // Factory constructor with validation
  factory AnalysisData({
    required double revenue,
    required double cost,
    DateTime? createdAt,
    Map<String, dynamic>? penerimaan,
    Map<String, dynamic>? pengeluaran,
  }) {
    // Validasi nilai negatif
    if (revenue < 0) {
      throw AnalysisDataException('Revenue tidak boleh negatif');
    }
    if (cost < 0) {
      throw AnalysisDataException('Cost tidak boleh negatif');
    }

    // Hitung profit otomatis
    final profit = revenue - cost;

    return AnalysisData._(
      revenue: revenue,
      cost: cost,
      profit: profit,
      createdAt: createdAt ?? DateTime.now(),
      penerimaan: penerimaan,
      pengeluaran: pengeluaran,
    );
  }

  // Factory constructor from Firestore
  factory AnalysisData.fromMap(Map<String, dynamic> map) {
    final penerimaan = map['penerimaan'] as Map<String, dynamic>?;
    final pengeluaran = map['pengeluaran'] as Map<String, dynamic>?;

    final revenue = (penerimaan?['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    final cost = (pengeluaran?['totalCost'] as num?)?.toDouble() ?? 0.0;
    final createdAt = (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();

    return AnalysisData(
      revenue: revenue,
      cost: cost,
      createdAt: createdAt,
      penerimaan: penerimaan,
      pengeluaran: pengeluaran,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'penerimaan': penerimaan ?? {'totalRevenue': revenue},
      'pengeluaran': pengeluaran ?? {'totalCost': cost},
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // Add copyWith method for immutability
  AnalysisData copyWith({
    double? revenue,
    double? cost,
    DateTime? createdAt,
    Map<String, dynamic>? penerimaan,
    Map<String, dynamic>? pengeluaran,
  }) {
    return AnalysisData(
      revenue: revenue ?? this.revenue,
      cost: cost ?? this.cost,
      createdAt: createdAt ?? this.createdAt,
      penerimaan: penerimaan ?? this.penerimaan,
      pengeluaran: pengeluaran ?? this.pengeluaran,
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'AnalysisData(revenue: $revenue, cost: $cost, profit: $profit, createdAt: $createdAt, penerimaan: $penerimaan, pengeluaran: $pengeluaran)';
  }

  // Helper methods for analysis
  bool isProfitable() => profit > 0;

  double getProfitMargin() {
    if (revenue == 0) return 0;
    return (profit / revenue) * 100;
  }

  String getProfitabilityStatus() {
    final margin = getProfitMargin();
    if (margin > 20) return 'Sangat Menguntungkan';
    if (margin > 10) return 'Menguntungkan';
    if (margin > 0) return 'Margin Tipis';
    if (margin == 0) return 'Break Even';
    return 'Rugi';
  }

  // Helper method untuk mendapatkan data untuk average card
  Map<String, dynamic> toAverageData(String type) {
    if (type == 'penetasan') {
      var hargaDOD = penerimaan?['hargaDOD'] ?? 0.0;
      var jumlahDOD = penerimaan?['jumlahDOD'] ?? 0.0;
      var revenue = hargaDOD * jumlahDOD;
      return {
        'penerimaan': {'totalRevenue': revenue, ...?penerimaan},
        'pengeluaran': pengeluaran,
      };
    } else if (type == 'penggemukan') {
      var hargaItik = penerimaan?['hargaItik'] ?? 0.0;
      var jumlahItikSetelahMortalitas = penerimaan?['jumlahItikSetelahMortalitas'] ?? 0.0;
      var revenue = hargaItik * jumlahItikSetelahMortalitas;
      return {
        'penerimaan': {'totalRevenue': revenue, ...?penerimaan},
        'pengeluaran': pengeluaran,
      };
    } else if (type == 'layer') {
      var hargaTelur = penerimaan?['hargaTelur'] ?? 0.0;
      var jumlahTelurDihasilkan = penerimaan?['jumlahTelurDihasilkan'] ?? 0.0;
      var revenue = hargaTelur * jumlahTelurDihasilkan;

      // Jika totalRevenue tetap 0, pastikan kita memberikan feedback atau nilai lain
      if (revenue == 0.0) {
        print("Warning: revenue untuk layer adalah 0, cek hargaTelur dan jumlahTelurDihasilkan.");
      }

      return {
        'penerimaan': {'totalRevenue': revenue, ...?penerimaan},
        'pengeluaran': pengeluaran,
      };
    }
    throw AnalysisDataException('Tipe tidak valid');
  }


}