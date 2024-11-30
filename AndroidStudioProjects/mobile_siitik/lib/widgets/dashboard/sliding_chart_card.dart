import 'package:flutter/material.dart';
import 'package:mobile_siitik/models/analysis_data.dart';
import 'package:mobile_siitik/models/telur_production.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SlidingChartCard extends StatefulWidget {
  final List<AnalysisData> analysisData;
  final TelurProduction telurData;

  const SlidingChartCard({
    Key? key,
    required this.analysisData,
    required this.telurData,
  }) : super(key: key);

  @override
  State<SlidingChartCard> createState() => _SlidingChartCardState();
}

class _SlidingChartCardState extends State<SlidingChartCard> {
  int _selectedIndex = 0; // 0: Keuangan, 1: Produksi
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedIndex == 0 ? 'Analisis Keuangan' : 'Produksi Telur',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              _buildSegmentedControl(),
            ],
          ),
          const SizedBox(height: 24),
          _selectedIndex == 0 ? _buildFinanceChart() : _buildProductionChart(),
          const SizedBox(height: 24),
          _selectedIndex == 0 ? _buildFinanceSummary() : _buildProductionSummary(),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegmentButton(0, 'Keuangan'),
          _buildSegmentButton(1, 'Produksi'),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(int index, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceChart() {
    if (widget.analysisData.isEmpty) {
      return const Center(
        child: Text('Belum ada data analisis keuangan'),
      );
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    currencyFormat.format(value).replaceAll('Rp ', ''),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= widget.analysisData.length) {
                    return const Text('');
                  }
                  final date = widget.analysisData[value.toInt()].createdAt;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            _createLineBarsData(Colors.green, (data) => data.revenue),
            _createLineBarsData(Colors.red, (data) => data.cost),
            _createLineBarsData(Colors.blue, (data) => data.profit),
          ],
        ),
      ),
    );
  }

  Widget _buildProductionChart() {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProductionIndicator(
                'Produksi Periode Ini',
                widget.telurData.periodeIni,
                Colors.blue,
              ),
              const SizedBox(width: 24),
              _buildProductionIndicator(
                'Produksi Sebelumnya',
                widget.telurData.betinaSebelumnya,
                Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProductionIndicator(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: widget.telurData.productionPercentage / 100,
            backgroundColor: Colors.grey[200],
            color: Colors.blue,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Persentase Produksi: ${widget.telurData.productionPercentage.toStringAsFixed(1)}%',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  LineChartBarData _createLineBarsData(
      Color color,
      double Function(AnalysisData) getValue,
      ) {
    return LineChartBarData(
      spots: widget.analysisData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), getValue(entry.value));
      }).toList(),
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildFinanceSummary() {
    final latestData = widget.analysisData.isNotEmpty
        ? widget.analysisData.last
        : AnalysisData(revenue: 0, cost: 0);

    return Row(
      children: [
        _buildSummaryCard(
          'Pendapatan',
          currencyFormat.format(latestData.revenue),
          Colors.green,
          Icons.trending_up,
        ),
        const SizedBox(width: 12),
        _buildSummaryCard(
          'Biaya',
          currencyFormat.format(latestData.cost),
          Colors.red,
          Icons.trending_down,
        ),
        const SizedBox(width: 12),
        _buildSummaryCard(
          'Laba',
          currencyFormat.format(latestData.profit),
          Colors.blue,
          Icons.account_balance,
        ),
      ],
    );
  }

  Widget _buildProductionSummary() {
    final change = widget.telurData.productionChange;
    final changeColor = change >= 0 ? Colors.green : Colors.red;
    final changeIcon = change >= 0 ? Icons.trending_up : Icons.trending_down;

    return Row(
      children: [
        _buildSummaryCard(
          'Total Itik',
          '${widget.telurData.totalDucks}',
          Colors.blue,
          Icons.pets,
        ),
        const SizedBox(width: 12),
        _buildSummaryCard(
          'Produksi',
          widget.telurData.periodeIni.toStringAsFixed(1),
          Colors.orange,
          Icons.egg_outlined,
        ),
        const SizedBox(width: 12),
        _buildSummaryCard(
          'Perubahan',
          '${change.toStringAsFixed(1)}%',
          changeColor,
          changeIcon,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title,
      String value,
      Color color,
      IconData icon,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}