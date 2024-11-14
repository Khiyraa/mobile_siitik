// lib/models/analysis_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisData {
  final double revenue;
  final double cost;
  final double profit;
  final DateTime createdAt;

  AnalysisData({
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.createdAt,
  });

  factory AnalysisData.fromMap(Map<String, dynamic> map) {
    return AnalysisData(
      revenue: (map['revenue'] as num).toDouble(),
      cost: (map['cost'] as num).toDouble(),
      profit: (map['profit'] as num).toDouble(),
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'revenue': revenue,
      'cost': cost,
      'profit': profit,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}