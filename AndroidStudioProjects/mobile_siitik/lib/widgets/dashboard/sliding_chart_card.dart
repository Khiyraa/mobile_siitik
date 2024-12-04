import 'package:flutter/material.dart';
import 'package:mobile_siitik/models/analysis_data.dart';
import 'package:mobile_siitik/models/telur_production.dart';
import 'package:mobile_siitik/services/layer_data_service.dart';
import 'package:mobile_siitik/widgets/dashboard/average_periode_card.dart';
import 'package:mobile_siitik/services/layer_data_service.dart';
import 'package:mobile_siitik/services/penggemukan_data_service.dart';

class SlidingChartCard extends StatefulWidget {
  final List<AnalysisData> analysisData;
  final TelurProduction telurData;

  const SlidingChartCard({
    super.key,
    required this.analysisData,
    required this.telurData,
  });

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
    return FutureBuilder<List<Map<String, dynamic>>>(
      // Panggil method untuk mengambil data layer
      future: LayerDataService.fetchLayerData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();  // Tampilkan indikator loading
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');  // Tampilkan error jika terjadi masalah
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No data available');  // Tampilkan pesan jika tidak ada data
        }

        var layerData = snapshot.data!;

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: PenggemukanDataService.fetchPenggemukanData(),  // Panggil method untuk mengambil data penggemukan
          builder: (context, penggemukanSnapshot) {
            if (penggemukanSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();  // Tampilkan indikator loading
            }

            if (penggemukanSnapshot.hasError) {
              return Text('Error: ${penggemukanSnapshot.error}');  // Tampilkan error jika terjadi masalah
            }

            if (!penggemukanSnapshot.hasData || penggemukanSnapshot.data!.isEmpty) {
              return Text('No penggemukan data available');  // Tampilkan pesan jika tidak ada data
            }

            var penggemukanData = penggemukanSnapshot.data!;

            return AveragePeriodSection(
              penetasanData: widget.analysisData
                  .where((data) {
                var penerimaan = data.penerimaan;
                return penerimaan != null && (penerimaan['jumlahDOD'] as num?) != null;
              })
                  .map((data) => data.toMap())
                  .toList(),

              // Layer: Ambil data dari layerData
              layerData: layerData.map((data) => {
                'penerimaan': data['penerimaan'],
                'pengeluaran': data['pengeluaran'],
                'hasilAnalisis': data['hasilAnalisis'],
              }).toList(),

              // Penggemukan: Ambil data dari penggemukanData
              penggemukanData: penggemukanData.map((data) => {
                'penerimaan': data['penerimaan'],
                'pengeluaran': data['pengeluaran'],
                'hasilAnalisis': data['hasilAnalisis'],
              }).toList(),
            );
          },
        );
      },
    );
  }
}
