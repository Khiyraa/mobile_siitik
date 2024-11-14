// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart'; // Tambahkan package rxdart
import '../services/analysis_service.dart';
import '../services/telur_service.dart';
import '../models/analysis_data.dart';
import '../models/telur_production.dart';
import '../widgets/dashboard/chart_card.dart';
import '../widgets/dashboard/sliding_chart_card.dart';
import '../widgets/dashboard/info_card.dart';
import '../widgets/dashboard/menu_card.dart';
import '../widgets/dashboard/bottom_nav.dart';

class DashboardScreen extends StatelessWidget {
  final AnalysisService _analysisService = AnalysisService();
  final TelurService _telurService = TelurService();

  DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: StreamBuilder<List<dynamic>>(
          // Menggunakan CombineLatestStream untuk menggabungkan dua stream
          stream: CombineLatestStream.list([
            _telurService.getTelurProductionStream(),
            _analysisService.getAnalysisPeriodStream(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Mengambil data dari stream yang digabungkan
            final telurData = snapshot.data![0] as TelurProduction;
            final analysisData = snapshot.data![1] as List<AnalysisData>;

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        ChartCard(
                          analysisData: analysisData,
                          telurData: telurData,
                        ),
                        const SizedBox(height: 24),
                        SlidingChartCard(
                          analysisData: analysisData,
                          telurData: telurData,
                        ),
                        const SizedBox(height: 24),
                        const InfoCard(),
                        const SizedBox(height: 24),
                        const MenuGrid(),
                      ],
                    ),
                  ),
                  const BottomNav(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}