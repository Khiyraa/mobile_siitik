import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_siitik/models/analysis_data.dart';

class AveragePeriodCard extends StatelessWidget {
  final String title;
  final Map<String, double> averageData;
  final Color cardColor;
  final IconData icon;

  const AveragePeriodCard({
    Key? key,
    required this.title,
    required this.averageData,
    required this.cardColor,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        final defaultPadding = isSmallScreen ? 10.0 : 12.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(defaultPadding),
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
                children: [
                  Icon(icon, color: cardColor, size: isSmallScreen ? 20 : 24),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Wrap(
                spacing: isSmallScreen ? 8 : 12,
                runSpacing: isSmallScreen ? 8 : 12,
                children: averageData.entries.map((entry) {
                  return _buildAverageItem(
                    entry.key,
                    entry.value,
                    cardColor,
                    isSmallScreen,
                    currencyFormat,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAverageItem(
      String label,
      double value,
      Color color,
      bool isSmallScreen,
      NumberFormat formatter,
      ) {
    bool isCurrency = label.toLowerCase().contains('biaya') ||
        label.toLowerCase().contains('revenue') ||
        label.toLowerCase().contains('pendapatan');

    return Container(
      width: isSmallScreen ? 95 : 110,
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          Text(
            isCurrency ? formatter.format(value) : value.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Example usage for each type of detail:

class AveragePeriodSection extends StatelessWidget {
  final List<Map<String, dynamic>> penetasanData;
  final List<Map<String, dynamic>> layerData;
  final List<Map<String, dynamic>> penggemukanData;

  const AveragePeriodSection({
    Key? key,
    required this.penetasanData,
    required this.layerData,
    required this.penggemukanData,
  }) : super(key: key);

  Map<String, double> _hitungRataRataPenetasan() {
    if (penetasanData.isEmpty) return {};

    double totalPendapatan = 0;
    double totalBiaya = 0;
    double totalProfit = 0;
    double totalPersentase = 0;

    for (var data in penetasanData) {
      final analisisData = AnalysisData.fromMap(data);

      print('Penetasan Data: $penetasanData');

      totalPendapatan += analisisData.revenue;
      totalBiaya += analisisData.cost;
      totalProfit += analisisData.profit;
      totalPersentase += analisisData.penerimaan?['persentase'] ?? 0.0;
    }

    int jumlahData = penetasanData.length;
    return {
      'Pendapatan': totalPendapatan / jumlahData,
      'Biaya': totalBiaya / jumlahData,
      'Laba': totalProfit / jumlahData,
      'Persentase': totalPersentase / jumlahData,
    };
  }

  Map<String, double> _hitungRataRataLayer() {
    if (layerData.isEmpty) return {};

    double totalPendapatan = 0;
    double totalBiaya = 0;
    double totalProfit = 0;
    double totalPersentaseBertelur = 0;

    for (var data in layerData) {
      final analisisData = AnalysisData.fromMap(data);

      // Debugging output
      print('Layer Data: $analisisData');
      print('Pendapatan: ${analisisData.revenue}');
      print('Biaya: ${analisisData.cost}');
      print('Profit: ${analisisData.profit}');
      print('Persentase Bertelur: ${analisisData.penerimaan?['persentase']}');

      totalPendapatan += analisisData.revenue;
      totalBiaya += analisisData.cost;
      totalProfit += analisisData.profit;
      totalPersentaseBertelur += analisisData.penerimaan?['persentase'] ?? 0.0;
    }

    int jumlahData = layerData.length;
    return {
      'Pendapatan': totalPendapatan / jumlahData,
      'Biaya': totalBiaya / jumlahData,
      'Laba': totalProfit / jumlahData,
      'Persentase Bertelur': totalPersentaseBertelur / jumlahData,
    };
  }


  Map<String, double> _hitungRataRataPenggemukan() {
    if (penggemukanData.isEmpty) return {};

    print('Penggemukan Data: $penggemukanData');  // Add print statement

    double totalPendapatan = 0;
    double totalBiaya = 0;
    double totalProfit = 0;
    double totalMortalitas = 0;

    for (var data in penggemukanData) {
      final analisisData = AnalysisData.fromMap(data);

      totalPendapatan += analisisData.revenue;
      totalBiaya += analisisData.cost;
      totalProfit += analisisData.profit;
      totalMortalitas += analisisData.penerimaan?['persentaseMortalitas'] ?? 0.0;
    }

    int jumlahData = penggemukanData.length;
    return {
      'Pendapatan': totalPendapatan / jumlahData,
      'Biaya': totalBiaya / jumlahData,
      'Laba': totalProfit / jumlahData,
      'Mortalitas': totalMortalitas / jumlahData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AveragePeriodCard(
          title: 'Rata-rata Penetasan',
          averageData: _hitungRataRataPenetasan(),
          cardColor: Colors.blue,
          icon: Icons.egg_outlined,
        ),
        const SizedBox(height: 16),
        AveragePeriodCard(
          title: 'Rata-rata Layer',
          averageData: _hitungRataRataLayer(),
          cardColor: Colors.green,
          icon: Icons.catching_pokemon,
        ),
        const SizedBox(height: 16),
        AveragePeriodCard(
          title: 'Rata-rata Penggemukan',
          averageData: _hitungRataRataPenggemukan(),
          cardColor: Colors.orange,
          icon: Icons.animation,
        ),
      ],
    );
  }
}
