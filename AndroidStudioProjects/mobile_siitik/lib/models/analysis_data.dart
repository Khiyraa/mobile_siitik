// lib/models/analysis_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisDataException implements Exception {
  final String message;
  AnalysisDataException(this.message);

  @override
  String toString() => 'AnalysisDataException: $message';
}

class AnalysisData {
  final double revenue;
  final double cost;
  final double profit;
  final DateTime createdAt;

  // Private constructor
  const AnalysisData._({
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.createdAt,
  });

  // Factory constructor with validation
  factory AnalysisData({
    required double revenue,
    required double cost,
    DateTime? createdAt,
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
    );
  }

  // Factory constructor from Firestore
  factory AnalysisData.fromMap(Map<String, dynamic> map) {
    final revenue =
        double.tryParse(map['penerimaan']['totalRevenue'].toString()) ?? 0.0;

    // Konversi totalCost dari String ke double
    final cost =
        double.tryParse(map['pengeluaran']['totalCost'].toString()) ?? 0.0;
    final createdAt =
        (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();

    return AnalysisData(
      revenue: revenue,
      cost: cost,
      createdAt: createdAt,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'revenue': revenue,
      'cost': cost,
      'profit': profit,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // Add copyWith method for immutability
  AnalysisData copyWith({
    double? revenue,
    double? cost,
    DateTime? createdAt,
  }) {
    return AnalysisData(
      revenue: revenue ?? this.revenue,
      cost: cost ?? this.cost,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Override toString for debugging
  @override
  String toString() {
    return 'AnalysisData(revenue: $revenue, cost: $cost, profit: $profit, createdAt: $createdAt)';
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
}
