/// Holds the state of the insurance contracting wizard.
///
/// This model carries data from the SimulationWizard into the ContratacaoWizard,
/// tracking all user selections throughout the checkout process.
class ContratacaoModel {
  // ─── From SimulationWizard ───────────────────────────────────────
  final String nomeCliente;
  final String telefoneCliente;
  final String emailCliente;
  final String tipoSeguro; // 'Automóvel' or 'Funeral'
  final String tipoCobertura; // 'RC' or 'DP' (Automóvel only)

  // Vehicle details (Automóvel only)
  final String? tipoVeiculo;
  final String? marca;
  final String? modelo;
  final String? ano;
  final double? valorVeiculo;
  final int? numOcupantes;

  // Funeral details
  final int? numPessoas;
  final int? idadeMedia;

  // Quote result
  final String pacoteSelecionado; // 'Basico', 'Classico', 'Exclusivo'
  final double premioTotal;
  final Map<String, double> precosPerPackage; // {'Basico': X, 'Classico': Y, ...}
  final List<String> coberturas;

  // ─── Collected during ContratacaoWizard ──────────────────────────
  
  // Step 2: Documents
  String? documentoBiPath;
  String? documentoCartaPath;

  // Step 3: Vehicle photos (Automóvel only)
  String? fotoFrentePath;
  String? fotoTraseiraPath;
  String? fotoLateralEsqPath;
  String? fotoLateralDirPath;

  // Step 4: Payment method
  String metodoPagamento; // 'M-Pesa', 'E-Mola', 'VISA'
  String? telefonePagamento; // Phone number for M-Pesa/E-Mola

  // Step 5: Terms
  bool aceitouTermos;

  ContratacaoModel({
    required this.nomeCliente,
    required this.telefoneCliente,
    this.emailCliente = '',
    required this.tipoSeguro,
    this.tipoCobertura = 'RC',
    this.tipoVeiculo,
    this.marca,
    this.modelo,
    this.ano,
    this.valorVeiculo,
    this.numOcupantes,
    this.numPessoas,
    this.idadeMedia,
    required this.pacoteSelecionado,
    required this.premioTotal,
    required this.precosPerPackage,
    this.coberturas = const [],
    this.documentoBiPath,
    this.documentoCartaPath,
    this.fotoFrentePath,
    this.fotoTraseiraPath,
    this.fotoLateralEsqPath,
    this.fotoLateralDirPath,
    this.metodoPagamento = 'M-Pesa',
    this.telefonePagamento,
    this.aceitouTermos = false,
  });

  /// Whether all required documents are uploaded.
  bool get hasRequiredDocuments =>
      documentoBiPath != null && documentoBiPath!.isNotEmpty;

  /// Whether all 4 vehicle photos are uploaded (Automóvel only).
  bool get hasAllVehiclePhotos =>
      fotoFrentePath != null &&
      fotoTraseiraPath != null &&
      fotoLateralEsqPath != null &&
      fotoLateralDirPath != null;

  /// Whether the user is ready for checkout.
  bool get isReadyForCheckout {
    if (!aceitouTermos) return false;
    if (metodoPagamento == 'M-Pesa' || metodoPagamento == 'E-Mola') {
      return telefonePagamento != null && telefonePagamento!.length >= 9;
    }
    return true;
  }

  /// All vehicle photo paths as a list (for batch upload).
  List<String> get vehiclePhotoPaths => [
        if (fotoFrentePath != null) fotoFrentePath!,
        if (fotoTraseiraPath != null) fotoTraseiraPath!,
        if (fotoLateralEsqPath != null) fotoLateralEsqPath!,
        if (fotoLateralDirPath != null) fotoLateralDirPath!,
      ];

  /// Display name for the insurance type.
  String get tipoSeguroDisplay {
    if (tipoSeguro == 'Automóvel') {
      return tipoCobertura == 'DP'
          ? 'Automóvel — Danos Próprios'
          : 'Automóvel — Responsabilidade Civil';
    }
    return 'Seguro Funeral';
  }
}
