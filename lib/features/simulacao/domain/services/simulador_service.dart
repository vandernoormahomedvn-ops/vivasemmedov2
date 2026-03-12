
class SimuladorService {
  static const List<String> pacotes = ['Basico', 'Classico', 'Exclusivo'];

  // --- RC DATA ---
  static const Map<String, double> precosRCBasico = {
    'Ligeiros, LVD/4X4': 3250.00,
    'Camiões abaixo de 3.5 toneladas': 3250.00,
    'Camiões acima de 3.5 Toneladas': 7000.00,
    'Mini Bus 15 lugares': 3250.00,
    'Autocarros': 7000.00,
    'Atrelados Domésticos': 2000.00,
    'Atrelados Comerciais': 3500.00,
    'Motociclos': 3000.00,
    'Veiculos Especiais': 3250.00,
  };
  static const Map<String, double> precosRCClassico = {
    'Ligeiros, LVD/4X4': 3999.00,
    'Camiões abaixo de 3.5 toneladas': 3999.00,
    'Camiões acima de 3.5 Toneladas': 8200.00,
    'Mini Bus 15 lugares': 3999.00,
    'Autocarros': 7000.00,
    'Atrelados domésticos': 2000.00,
    'Atrelados Comerciais': 3500.00,
    'Motociclos': 3000.00,
    'Veiculos Especiais': 3999.00,
  };
  static const Map<String, double> taxasOcupanteClassico = {
    'Mini Bus 15 lugares': 300.00,
    'Autocarros': 500.00,
  };
  static const Map<String, double> precosRCExclusivo = {
    'Ligeiros, LVD/4X4': 5000.00,
    'Camiões abaixo de 3.5 toneladas': 6300.00,
    'Camiões acima de 3.5 Toneladas': 9800.00,
    'Mini Bus 15 lugares': 6300.00,
    'Autocarros': 7000.00,
    'Atrelados domésticos': 3000.00,
    'Atrelados Comerciais': 5000.00,
    'Motociclos': 5000.00,
    'Veiculos Especiais': 5000.00,
  };
  static const Map<String, double> taxasOcupanteExclusivo = {
    'Mini Bus 15 lugares': 500.00,
    'Autocarros': 500.00,
  };

  // --- DP DATA ---
  static const Map<String, List<double>> taxasDPBasico = {
    'Ligeiros, LVD/4X4': [4.00, 3.90, 3.80, 3.70, 3.60],
    'Camiões abaixo de 3.5 toneladas': [5.00, 4.88, 4.75, 4.63, 4.50],
    'Camiões acima de 3.5 Toneladas': [6.00, 5.85, 5.70, 5.55, 5.40],
    'Mini Bus 15 lugares': [5.50, 5.36, 5.23, 5.09, 4.95],
    'Autocarros': [6.50, 6.34, 6.18, 6.01, 5.85],
    'Atrelados domésticos': [2.50, 2.44, 2.38, 2.31, 2.25],
    'Atrelados Comerciais': [3.00, 2.93, 2.85, 2.78, 2.70],
    'Motociclos': [4.00, 3.90, 3.80, 3.70, 3.60],
  };
  static const Map<String, List<double>> taxasDPClassico = {
    'Ligeiros, LVD/4X4': [5.00, 4.88, 4.75, 4.63, 4.50],
    'Camiões abaixo de 3.5 toneladas': [6.00, 5.85, 5.56, 5.14, 5.40],
    'Camiões acima de 3.5 Toneladas': [7.00, 6.83, 6.48, 6.00, 5.40],
    'Mini Bus 15 lugares': [6.00, 5.85, 5.56, 5.14, 5.40],
    'Autocarros': [7.00, 6.83, 6.48, 6.00, 5.40],
    'Atrelados domésticos': [2.75, 2.68, 2.55, 2.36, 2.48],
    'Atrelados Comerciais': [3.50, 3.41, 3.24, 3.00, 3.15],
    'Motociclos': [4.50, 4.39, 4.17, 3.86, 4.05],
  };
  static const Map<String, List<double>> taxasDPExclusivo = {
    'Ligeiros, LVD/4X4': [6.50, 6.34, 6.18, 6.01, 5.85],
    'Camiões abaixo de 3.5 toneladas': [7.00, 6.83, 6.65, 6.48, 6.30],
    'Camiões acima de 3.5 Toneladas': [7.50, 7.31, 7.13, 6.94, 6.75],
    'Mini Bus 15 lugares': [7.00, 6.83, 6.65, 6.48, 6.30],
    'Autocarros': [8.00, 7.80, 7.60, 7.40, 7.20],
    'Atrelados domésticos': [3.00, 2.93, 2.85, 2.78, 2.70],
    'Atrelados Comerciais': [4.00, 3.90, 3.80, 3.70, 3.60],
    'Motociclos': [5.00, 4.88, 4.75, 4.63, 4.50],
  };

  static Map<String, double> calcularRC({
    required String tipoVeiculo,
    required int numVeiculos,
    required int numOcupantes,
  }) {
    Map<String, double> resultados = {};

    for (var pacote in pacotes) {
      double premioBase = 0.0;
      double premioOcupantes = 0.0;

      switch (pacote) {
        case 'Basico':
          premioBase = precosRCBasico[tipoVeiculo] ?? 0.0;
          break;
        case 'Classico':
          premioBase = precosRCClassico[tipoVeiculo] ?? 0.0;
          premioOcupantes =
              (taxasOcupanteClassico[tipoVeiculo] ?? 0.0) * numOcupantes;
          break;
        case 'Exclusivo':
          premioBase = precosRCExclusivo[tipoVeiculo] ?? 0.0;
          premioOcupantes =
              (taxasOcupanteExclusivo[tipoVeiculo] ?? 0.0) * numOcupantes;
          break;
      }

      double descontoPercentual = 0.0;
      if (numVeiculos >= 10 && numVeiculos <= 25) {
        descontoPercentual = 0.025;
      } else if (numVeiculos > 25 && numVeiculos <= 35) {
        descontoPercentual = 0.05;
      } else if (numVeiculos > 35 && numVeiculos <= 45) {
        descontoPercentual = 0.075;
      } else if (numVeiculos > 45) {
        descontoPercentual = 0.10;
      }

      double premioComDesconto = premioBase * (1 - descontoPercentual);
      double premioOcupantesComDesconto =
          premioOcupantes * (1 - descontoPercentual);

      resultados[pacote] = premioComDesconto + premioOcupantesComDesconto;
    }

    return resultados;
  }

  static double _getTaxaDP(
      Map<String, List<double>> mapaDeTaxas, String tipoVeiculo, int numVeiculos) {
    List<double> taxasDaViatura = mapaDeTaxas[tipoVeiculo] ?? [];
    if (taxasDaViatura.isEmpty) return 0.00;

    if (numVeiculos < 10) return taxasDaViatura[0];
    if (numVeiculos <= 25) return taxasDaViatura[1];
    if (numVeiculos <= 35) return taxasDaViatura[2];
    if (numVeiculos <= 45) return taxasDaViatura[3];
    return taxasDaViatura[4];
  }

  static Map<String, double> calcularDP({
    required String tipoVeiculo,
    required double valorVeiculo,
    required int numVeiculos,
  }) {
    double taxaBasico = _getTaxaDP(taxasDPBasico, tipoVeiculo, numVeiculos);
    double precoBasico = valorVeiculo * (taxaBasico / 100.00) * numVeiculos;

    double taxaClassico = _getTaxaDP(taxasDPClassico, tipoVeiculo, numVeiculos);
    double precoClassico = valorVeiculo * (taxaClassico / 100.00) * numVeiculos;

    double taxaExclusivo = _getTaxaDP(taxasDPExclusivo, tipoVeiculo, numVeiculos);
    double precoExclusivo = valorVeiculo * (taxaExclusivo / 100.00) * numVeiculos;

    return {
      'Basico': precoBasico,
      'Classico': precoClassico,
      'Exclusivo': precoExclusivo,
    };
  }
}
