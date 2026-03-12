import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for an insurance policy (Apólice).
///
/// Maps to the `apolices` collection in Firestore.
class ApoliceModel {
  final String id;
  final String userId;
  final String numero; // e.g. "INDICO-2024-00042"
  final String tipo; // 'RC', 'DP', 'Funeral'
  final String pacote; // 'Basico', 'Classico', 'Exclusivo'
  final double premio; // Premium amount in MZN
  final String status; // 'pendente', 'activa', 'expirada', 'cancelada'

  // Datas
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final DateTime? createdAt;

  // Dados do Segurado
  final String nomeCliente;
  final String telefoneCliente;
  final String emailCliente;

  // Dados do Veículo (Automóvel only)
  final String? tipoVeiculo;
  final String? marca;
  final String? modelo;
  final String? ano;
  final double? valorVeiculo;
  final int? numOcupantes;

  // Dados Funeral (Funeral only)
  final int? numPessoas;
  final int? idadeMedia;

  // Coberturas
  final List<String> coberturas;

  // Pagamento
  final String metodoPagamento; // 'M-Pesa', 'E-Mola', 'VISA'
  final String? transactionId;
  final String? pagamentoStatus; // 'pendente', 'confirmado', 'falhado'

  // Documentos (URLs no Firebase Storage)
  final String? documentoBiUrl;
  final String? documentoCartaUrl;
  final List<String> fotosVeiculoUrls;
  final String? certificadoPdfUrl;
  final String? reciboPdfUrl;

  ApoliceModel({
    this.id = '',
    required this.userId,
    required this.numero,
    required this.tipo,
    required this.pacote,
    required this.premio,
    this.status = 'pendente',
    this.dataInicio,
    this.dataFim,
    this.createdAt,
    required this.nomeCliente,
    required this.telefoneCliente,
    this.emailCliente = '',
    this.tipoVeiculo,
    this.marca,
    this.modelo,
    this.ano,
    this.valorVeiculo,
    this.numOcupantes,
    this.numPessoas,
    this.idadeMedia,
    this.coberturas = const [],
    this.metodoPagamento = 'M-Pesa',
    this.transactionId,
    this.pagamentoStatus,
    this.documentoBiUrl,
    this.documentoCartaUrl,
    this.fotosVeiculoUrls = const [],
    this.certificadoPdfUrl,
    this.reciboPdfUrl,
  });

  /// Creates an [ApoliceModel] from a Firestore document snapshot.
  factory ApoliceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ApoliceModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      numero: data['numero'] ?? '',
      tipo: data['tipo'] ?? '',
      pacote: data['pacote'] ?? '',
      premio: (data['premio'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'pendente',
      dataInicio: _parseTimestamp(data['dataInicio']),
      dataFim: _parseTimestamp(data['dataFim']),
      createdAt: _parseTimestamp(data['createdAt']),
      nomeCliente: data['nomeCliente'] ?? '',
      telefoneCliente: data['telefoneCliente'] ?? '',
      emailCliente: data['emailCliente'] ?? '',
      tipoVeiculo: data['tipoVeiculo'],
      marca: data['marca'],
      modelo: data['modelo'],
      ano: data['ano'],
      valorVeiculo: (data['valorVeiculo'] as num?)?.toDouble(),
      numOcupantes: data['numOcupantes'] as int?,
      numPessoas: data['numPessoas'] as int?,
      idadeMedia: data['idadeMedia'] as int?,
      coberturas: List<String>.from(data['coberturas'] ?? []),
      metodoPagamento: data['metodoPagamento'] ?? 'M-Pesa',
      transactionId: data['transactionId'],
      pagamentoStatus: data['pagamentoStatus'],
      documentoBiUrl: data['documentoBiUrl'],
      documentoCartaUrl: data['documentoCartaUrl'],
      fotosVeiculoUrls: List<String>.from(data['fotosVeiculoUrls'] ?? []),
      certificadoPdfUrl: data['certificadoPdfUrl'],
      reciboPdfUrl: data['reciboPdfUrl'],
    );
  }

  /// Converts the model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'numero': numero,
      'tipo': tipo,
      'pacote': pacote,
      'premio': premio,
      'status': status,
      if (dataInicio != null) 'dataInicio': Timestamp.fromDate(dataInicio!),
      if (dataFim != null) 'dataFim': Timestamp.fromDate(dataFim!),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'nomeCliente': nomeCliente,
      'telefoneCliente': telefoneCliente,
      'emailCliente': emailCliente,
      if (tipoVeiculo != null) 'tipoVeiculo': tipoVeiculo,
      if (marca != null) 'marca': marca,
      if (modelo != null) 'modelo': modelo,
      if (ano != null) 'ano': ano,
      if (valorVeiculo != null) 'valorVeiculo': valorVeiculo,
      if (numOcupantes != null) 'numOcupantes': numOcupantes,
      if (numPessoas != null) 'numPessoas': numPessoas,
      if (idadeMedia != null) 'idadeMedia': idadeMedia,
      'coberturas': coberturas,
      'metodoPagamento': metodoPagamento,
      if (transactionId != null) 'transactionId': transactionId,
      if (pagamentoStatus != null) 'pagamentoStatus': pagamentoStatus,
      if (documentoBiUrl != null) 'documentoBiUrl': documentoBiUrl,
      if (documentoCartaUrl != null) 'documentoCartaUrl': documentoCartaUrl,
      'fotosVeiculoUrls': fotosVeiculoUrls,
      if (certificadoPdfUrl != null) 'certificadoPdfUrl': certificadoPdfUrl,
      if (reciboPdfUrl != null) 'reciboPdfUrl': reciboPdfUrl,
    };
  }

  /// Creates a copy with modified fields.
  ApoliceModel copyWith({
    String? id,
    String? status,
    String? transactionId,
    String? pagamentoStatus,
    String? certificadoPdfUrl,
    String? reciboPdfUrl,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) {
    return ApoliceModel(
      id: id ?? this.id,
      userId: userId,
      numero: numero,
      tipo: tipo,
      pacote: pacote,
      premio: premio,
      status: status ?? this.status,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      createdAt: createdAt,
      nomeCliente: nomeCliente,
      telefoneCliente: telefoneCliente,
      emailCliente: emailCliente,
      tipoVeiculo: tipoVeiculo,
      marca: marca,
      modelo: modelo,
      ano: ano,
      valorVeiculo: valorVeiculo,
      numOcupantes: numOcupantes,
      numPessoas: numPessoas,
      idadeMedia: idadeMedia,
      coberturas: coberturas,
      metodoPagamento: metodoPagamento,
      transactionId: transactionId ?? this.transactionId,
      pagamentoStatus: pagamentoStatus ?? this.pagamentoStatus,
      documentoBiUrl: documentoBiUrl,
      documentoCartaUrl: documentoCartaUrl,
      fotosVeiculoUrls: fotosVeiculoUrls,
      certificadoPdfUrl: certificadoPdfUrl ?? this.certificadoPdfUrl,
      reciboPdfUrl: reciboPdfUrl ?? this.reciboPdfUrl,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
