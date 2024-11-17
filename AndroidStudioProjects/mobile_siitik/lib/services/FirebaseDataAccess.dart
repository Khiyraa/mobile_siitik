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

  // Get current user email safely
  String get _userEmail {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseException('User tidak terautentikasi');
    return user.email ?? ''; // pastikan email tidak null
  }

  // Generic method untuk mengambil data dengan error handling yang lebih baik
  Future<Map<String, dynamic>> _fetchLatestDocument({
    required String analysisType,
    required Map<String, dynamic> defaultData,
  }) async {
    try {
      print('Mengambil data dari koleksi: $analysisType');
      print('User email: $_userEmail');

      // Ambil dokumen pertama berdasarkan email pengguna
      final QuerySnapshot snapshot = await _firestore
          .collection(analysisType) // Koleksi berdasarkan tipe analisis
          .where('userId', isEqualTo: _userEmail) // Mengganti userId dengan email
          .limit(1)
          .get()
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw FirebaseException(
          'Timeout saat mengambil data dari $analysisType',
        ),
      );

      print('Jumlah dokumen ditemukan: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('Tidak ada dokumen ditemukan. Mengembalikan data default');
        return defaultData;
      }

      final document = snapshot.docs.first;
      final String idAnalisis = document.id;
      final data = document.data() as Map<String, dynamic>;

      // Ambil data subkoleksi 'analisis_periode' menggunakan ID dokumen
      final subcollectionSnapshot = await _firestore
          .collection(analysisType)
          .doc(idAnalisis)
          .collection('analisis_periode')
          .get();

      final subcollectionData = subcollectionSnapshot.docs.map((doc) {
        return doc.data();
      }).toList();

      print('Data periode dari subkoleksi: $subcollectionData');

      _validateData(data, analysisType);

      print('Data berhasil diambil dari $analysisType');
      return {...data, 'analisis_periode': subcollectionData};
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
        print('Field tidak ditemukan: $field');
        // Lakukan penanganan berbeda di sini (misalnya, berikan nilai default)
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
      analysisType: 'detail_layer',
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
      analysisType: 'detail_penetasan',
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
        'hargaItik': 0.0,
        'penyusutanPeralatan': 0.0,
        'sewaKandang': 0.0,
        'totalBiaya': 0.0,
        'totalBiayaOperasional': 0.0,
        'totalCost': 0.0,
        'totalFixedCost': 0.0,
        'totalVariableCost': 0.0
      },
      'periode': 'Periode 1'
    };

    return _fetchLatestDocument(
      analysisType: 'detail_penggemukan',
      defaultData: defaultData,
    );
  }
}
