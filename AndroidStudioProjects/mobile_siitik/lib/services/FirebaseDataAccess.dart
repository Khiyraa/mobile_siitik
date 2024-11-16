import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseException implements Exception {
  final String message;
  FirebaseException(this.message);

  @override
  String toString() => 'FirebaseException: $message';
}

class FirebaseDataAccess {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Singleton pattern
  static final FirebaseDataAccess _instance = FirebaseDataAccess._internal();

  factory FirebaseDataAccess() => _instance;

  FirebaseDataAccess._internal()
      : _firestore = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  // Get current user ID safely
  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseException('User tidak terautentikasi');
    return user.uid;
  }

  // Generic method untuk mengambil data dengan error handling yang lebih baik
  Future<Map<String, dynamic>> _fetchLatestDocument({
    required String collection,
    required Map<String, dynamic> defaultData,
  }) async {
    try {
      print('Mengambil data dari koleksi: $collection');
      print('User ID: $_userId');

      final QuerySnapshot snapshot = await _firestore
          .collection(collection)
          .where('userId', isEqualTo: _userId)
          .orderBy('created_at', descending: true)
          .limit(1)
          .get()
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw FirebaseException(
          'Timeout saat mengambil data dari $collection',
        ),
      );

      print('Jumlah dokumen ditemukan: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('Tidak ada dokumen ditemukan. Mengembalikan data default');
        return defaultData;
      }

      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      _validateData(data, collection);

      print('Data berhasil diambil dari $collection');
      return data;
    } on FirebaseAuthException catch (e) {
      throw FirebaseException('Auth error: ${e.message}');
    } on FirebaseException catch (e) {
      rethrow;
    } catch (e, stackTrace) {
      print('Stack trace: $stackTrace');
      throw FirebaseException('Error tidak terduga: $e');
    }
  }

  // Validasi struktur data
  void _validateData(Map<String, dynamic> data, String collection) {
    final requiredFields = _getRequiredFields(collection);
    for (final field in requiredFields) {
      if (!data.containsKey(field)) {
        throw FirebaseException(
          'Data tidak valid: field "$field" tidak ditemukan di $collection',
        );
      }
    }
  }

  // Helper untuk mendapatkan required fields berdasarkan collection
  List<String> _getRequiredFields(String collection) {
    switch (collection) {
      case 'detail_layer':
        return ['hasilAnalisis', 'penerimaan', 'pengeluaran', 'periode'];
      case 'detail_penetasan':
        return ['hasilAnalisis', 'penerimaan', 'pengeluaran', 'periode'];
      case 'detail_penggemukan':
        return ['hasilAnalisis', 'penerimaan', 'pengeluaran', 'periode'];
      default:
        return [];
    }
  }

  // Get Layer Analysis Data
  Future<Map<String, dynamic>> getAnalysisPeriodData() async {
    const defaultData = {
      'hasilAnalisis': {
        'bepHarga': 0.0,
        'bepHasil': 0.0,
        'laba': 0.0,
        'marginOfSafety': 0.0,
        'rcRatio': 0.0
      },
      'penerimaan': {
        'hargaTelur': 0.0,
        'jumlahItikAwal': 0,
        'jumlahSatuPeriode': 0,
        'jumlahTelurDihasilkan': 0,
        'persentase': 0.0,
        'persentaseBertelur': 0.0,
        'produksiTelurHarian': 0.0,
        'satuPeriode': 0
      },
      'pengeluaran': {
        'biayaListrik': 0.0,
        'biayaOperasional': 0.0,
        'biayaOvk': 0.0,
        'biayaTenagaKerja': 0.0,
        'jumlahHari': 0,
        'jumlahItikAwal': 0,
        'jumlahPakanKilogram': 0.0,
        'penyusutanItik': 0.0,
        'sewaKandang': 0.0,
        'standardPakanGram': 0.0,
        'totalBiaya': 0.0,
        'totalBiayaOperasional': 0.0,
        'totalBiayaPakan': 0.0,
        'totalCost': 0.0,
        'totalFixedCost': 0.0,
        'totalVariableCost': 0.0
      },
      'periode': 'Periode 1'
    };

    return _fetchLatestDocument(
      collection: 'detail_layer',
      defaultData: defaultData,
    );
  }

  // Get Hatching Data
  Future<Map<String, dynamic>> getHatchingData() async {
    const defaultData = {
      'hasilAnalisis': {
        'bepHarga': 0.0,
        'bepHasil': 0.0,
        'laba': 0.0,
        'marginOfSafety': 0.0,
        'rcRatio': 0.0
      },
      'penerimaan': {
        'hargaDOD': 0.0,
        'jumlahDOD': 0,
        'jumlahTelur': 0,
        'jumlahTelurMenetas': 0,
        'persentase': 0.0,
        'totalRevenue': 0.0
      },
      'pengeluaran': {
        'biayaListrik': 0.0,
        'biayaOperasional': 0.0,
        'biayaOvk': 0.0,
        'biayaTenagaKerja': 0.0,
        'hargaTelur': 0.0,
        'penyusutanPeralatan': 0.0,
        'sewaKandang': 0.0,
        'totalBiaya': 0.0,
        'totalBiayaOperasional': 0.0,
        'totalBiayaPembelianTelur': 0.0,
        'totalCost': 0.0,
        'totalFixedCost': 0.0,
        'totalVariableCost': 0.0
      },
      'periode': 'Periode 1'
    };

    return _fetchLatestDocument(
      collection: 'detail_penetasan',
      defaultData: defaultData,
    );
  }

  // Get Fattening Data
  Future<Map<String, dynamic>> getFatteningData() async {
    const defaultData = {
      'hasilAnalisis': {
        'bepHarga': 0.0,
        'bepHasil': 0.0,
        'laba': 0.0,
        'marginOfSafety': 0.0,
        'rcRatio': 0.0
      },
      'penerimaan': {
        'hargaItik': 0.0,
        'jumlahItikAwal': 0,
        'jumlahItikMati': 0,
        'jumlahItikSetelahMortalitas': 0.0,
        'persentase': 0.0,
        'persentaseMortalitas': 0.0,
        'totalRevenue': 0.0
      },
      'pengeluaran': {
        'biayaListrik': 0.0,
        'biayaOperasional': 0.0,
        'biayaOvk': 0.0,
        'biayaTenagaKerja': 0.0,
        'hargaPakan': 0.0,
        'jumlahPakan': 0.0,
        'penyusutanPeralatan': 0.0,
        'sewaKandang': 0.0,
        'standardPakan': 0.0,
        'totalBiaya': 0.0,
        'totalBiayaOperasional': 0.0,
        'totalCost': 0.0,
        'totalFixedCost': 0.0,
        'totalHargaPakan': 0.0,
        'totalVariableCost': 0.0
      },
      'periode': 'Periode 1'
    };

    return _fetchLatestDocument(
      collection: 'detail_penggemukan',
      defaultData: defaultData,
    );
  }
}