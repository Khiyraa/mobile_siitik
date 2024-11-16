// lib/widgets/dashboard/chart_card.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_siitik/models/telur_production.dart';
import '../../models/analysis_data.dart';

class ChartCard extends StatelessWidget {
  final List<AnalysisData> analysisData;
  final TelurProduction telurData;

  const ChartCard({
    super.key,
    required this.analysisData,
    required this.telurData,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildCharts(),
          if (analysisData.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildProfitIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Analisis Keuangan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCharts() {
    if (analysisData.isEmpty) {
      return const Center(
        child: Text('Belum ada data analisis'),
      );
    }

    return Row(
      children: [
        Expanded(child: _buildRevenueChart()),
        const SizedBox(width: 16),
        Expanded(child: _buildCostChart()),
      ],
    );
  }

  Widget _buildRevenueChart() {
    return _buildBarChart(
      title: 'Pendapatan',
      data: analysisData.take(6).map((e) => e.revenue).toList(),
      color: Colors.green,
    );
  }

  Widget _buildCostChart() {
    return _buildBarChart(
      title: 'Biaya',
      data: analysisData.take(6).map((e) => e.cost).toList(),
      color: Colors.red,
    );
  }

  Widget _buildBarChart({
    required String title,
    required List<double> data,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: data.reduce((a, b) => a > b ? a : b),
              barGroups: data.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      color: color,
                      width: 12,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        'Rp${(value / 1000000).toStringAsFixed(1)}M',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= analysisData.length) {
                        return const Text('');
                      }
                      return Text(
                        _getMonthName(analysisData[value.toInt()].createdAt),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[date.month - 1];
  }

  Widget _buildProfitIndicator() {
    final latestProfit = analysisData.first.profit;
    final previousProfit = analysisData.length > 1 ? analysisData[1].profit : 0;
    final profitChange = latestProfit - previousProfit;
    final isPositive = profitChange >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Profit Bulan Ini:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Rp ${(latestProfit / 1000000).toStringAsFixed(1)}M',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}