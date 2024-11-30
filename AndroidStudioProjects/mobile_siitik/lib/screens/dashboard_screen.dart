// lib/screens/dashboard_screen.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/streams.dart';
import 'package:mobile_siitik/models/analysis_data.dart';
import 'package:mobile_siitik/models/telur_production.dart';
import 'package:mobile_siitik/services/analysis_service.dart';
import 'package:mobile_siitik/services/telur_service.dart';
import 'package:mobile_siitik/widgets/dashboard/info_card.dart';
import 'package:mobile_siitik/widgets/dashboard/menu_card.dart';
import 'package:mobile_siitik/widgets/dashboard/sliding_chart_card.dart';
import 'package:mobile_siitik/widgets/loading_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AnalysisService _analysisService = AnalysisService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TelurService _telurService = TelurService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;
  String? _currentDetailLayerId;
  String? _currentDetailPenggemukanId;
  String? _currentDetailPenetasanId;

  @override
  void initState() {
    super.initState();
    _setupStreams();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _setupStreams() async {
    try {
      final detailLayer = await getLatestDetailLayer();
      final detailPenggemukan = await getLatestDetailPenggemukan();
      final detailPenetasan = await getLatestDetailPenetasan();
      if (detailLayer != null) {
        setState(() {
          _currentDetailLayerId = detailLayer.id;
        });
      }

      if (detailPenggemukan != null) {
        setState(() {
          _currentDetailPenggemukanId = detailPenggemukan.id;
        });
      }

      if (detailPenetasan != null) {
        setState(() {
          _currentDetailPenetasanId = detailPenetasan.id;
        });
      }
    } catch (e) {
      print('Error setting up streams: $e');
    }
  }

  Future<DocumentSnapshot?> getLatestDetailLayer() async {
    final userId = _auth.currentUser?.email;
    if (userId == null) {
      throw Exception('User tidak terautentikasi');
    }
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('detail_layer')
          .where('userId', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      print('Error getting latest detail layer: $e');
      return null;
    }
  }

  Future<DocumentSnapshot?> getLatestDetailPenggemukan() async {
    final userId = _auth.currentUser?.email;
    if (userId == null) {
      throw Exception('User tidak terautentikasi');
    }
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('detail_penggemukan')
          .where('userId', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      print('Error getting latest detail layer: $e');
      return null;
    }
  }

  Future<DocumentSnapshot?> getLatestDetailPenetasan() async {
    final userId = _auth.currentUser?.email;
    if (userId == null) {
      throw Exception('User tidak terautentikasi');
    }
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('detail_penetasan')
          .where('userId', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      print('Error getting latest detail layer: $e');
      return null;
    }
  }

  Stream<List<dynamic>> _getCombinedStream(String detailLayerId,
      String detailPenggemukanid, String detailPenetasanId) {
    return CombineLatestStream.list([
      _telurService.getTelurProductionStream(
          detailLayerId, detailPenggemukanid),
      _analysisService.getAnalysisPeriodStream(detailPenetasanId),
    ]).handleError((error) {
      print('Stream error: $error');
      return [];
    });
  }

  Future<void> _refreshData() async {
    await _setupStreams();
  }

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
        child: _currentDetailLayerId == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<List<dynamic>>(
          stream: _getCombinedStream(
            _currentDetailLayerId ?? '',
            _currentDetailPenggemukanId ?? '',
            _currentDetailPenetasanId ?? '',
          ),
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
                            onPressed: _refreshData,
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

                  // print("telurData ${analysisData}");
                  return RefreshIndicator(
                    onRefresh: _refreshData,
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildSummaryCard(
                                        'Produksi Telur',
                                        telurData.periodeIni.toStringAsFixed(0),
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
                                        telurData.productionChange >= 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
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
                                const SizedBox(height: 100),
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
