// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../services/analysis_service.dart';
import '../services/telur_service.dart';
import '../models/analysis_data.dart';
import '../models/telur_production.dart';
import '../widgets/dashboard/sliding_chart_card.dart';
import '../widgets/dashboard/info_card.dart';
import '../widgets/dashboard/menu_card.dart';
import '../widgets/dashboard/bottom_nav.dart';
import '../widgets/loading_indicator.dart';

class DashboardScreen extends StatelessWidget {
  final AnalysisService _analysisService = AnalysisService();
  final TelurService _telurService = TelurService();

  DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Selamat datang kembali!',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () {
              // Implementasi navigasi ke profil
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<dynamic>>(
          stream: CombineLatestStream.list([
            _telurService.getTelurProductionStream(),
            _analysisService.getAnalysisPeriodStream(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[300],
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Implementasi refresh
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: LoadingIndicator(
                  message: 'Memuat data...',
                ),
              );
            }

            final telurData = snapshot.data![0] as TelurProduction;
            final analysisData = snapshot.data![1] as List<AnalysisData>;

            return RefreshIndicator(
              onRefresh: () async {
                // Implementasi refresh data
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Summary Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  'Produksi Telur',
                                  '${telurData.periodeIni.toStringAsFixed(0)}',
                                  'Telur/hari',
                                  Icons.egg_outlined,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSummaryCard(
                                  'Total Itik',
                                  '${telurData.totalDucks}',
                                  'Ekor',
                                  Icons.pest_control,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  'Persentase Produksi',
                                  '${telurData.productionPercentage.toStringAsFixed(1)}%',
                                  'Produktivitas',
                                  Icons.show_chart,
                                  Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSummaryCard(
                                  'Perubahan',
                                  '${telurData.productionChange.toStringAsFixed(1)}%',
                                  'Dari periode sebelumnya',
                                  Icons.trending_up,
                                  telurData.productionChange >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Chart Section
                          SlidingChartCard(
                            analysisData: analysisData,
                            telurData: telurData,
                          ),
                          const SizedBox(height: 24),
                          // Info Card
                          const InfoCard(),
                          const SizedBox(height: 24),
                          // Menu Grid
                          const MenuGrid(),
                          const SizedBox(height: 100), // Spacing for bottom nav
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }

  Widget _buildSummaryCard(
      String title,
      String value,
      String subtitle,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.more_horiz,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}