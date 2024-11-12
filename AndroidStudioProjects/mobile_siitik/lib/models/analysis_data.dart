class TelurProduction {
  final int jantan;
  final int betina;
  final int periodeIni;
  final int betinaSebelumnya;

  TelurProduction({
    required this.jantan,
    required this.betina,
    required this.periodeIni,
    required this.betinaSebelumnya,
  });

  factory TelurProduction.fromMap(Map<String, dynamic> map) {
    return TelurProduction(
      jantan: map['jantan'] ?? 0,
      betina: map['betina'] ?? 0,
      periodeIni: map['periode_ini'] ?? 0,
      betinaSebelumnya: map['betina_sebelumnya'] ?? 0,
    );
  }
}