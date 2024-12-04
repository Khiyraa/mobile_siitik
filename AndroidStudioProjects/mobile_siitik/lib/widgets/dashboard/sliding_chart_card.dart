import 'package:flutter/material.dart';
import 'package:mobile_siitik/models/analysis_data.dart';
import 'package:mobile_siitik/models/telur_production.dart';
import 'package:mobile_siitik/widgets/dashboard/average_periode_card.dart';

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
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        final defaultPadding = isSmallScreen ? 10.0 : 12.0;
        final titleSize = isSmallScreen ? 14.0 : 16.0;

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
              Text(
                'Analisis Data',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              _buildAverageSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAverageSection() {
    return AveragePeriodSection(
      penetasanData: widget.analysisData
          .where((data) {
        var penerimaan = data.penerimaan;
        return penerimaan != null && (penerimaan['jumlahDOD'] as num?) != null;
      })
          .map((data) => data.toMap())
          .toList(),

      // Layer: Ambil data dari TelurProduction
      layerData: [widget.telurData.toAverageData()],

      // Penggemukan: Filter data berdasarkan jumlah itik setelah mortalitas
      penggemukanData: widget.analysisData
          .where((data) {
        var penerimaan = data.penerimaan;
        return penerimaan != null && (penerimaan['jumlahItikSetelahMortalitas'] as num?) != null;
      })
          .map((data) => data.toMap())
          .toList(),
    );
  }
}
