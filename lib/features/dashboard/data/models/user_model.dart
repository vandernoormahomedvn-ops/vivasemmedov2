import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final String phoneNumber;
  final int cargoInt;
  final String cargo;
  final String statusUsuario;
  final String nuit;
  final String tipoDocumento;
  final String numeroDocumento;
  final DateTime? dataNascimento;
  final String genero;
  final String enderecoCompleto;
  final String provincia;
  final String distrito;
  final String bairro;
  final DateTime? createdTime;
  final bool? termoCond;

  UserModel({
    required this.id,
    this.email = '',
    this.displayName = '',
    this.photoUrl = '',
    this.phoneNumber = '',
    this.cargoInt = 0,
    this.cargo = '',
    this.statusUsuario = '',
    this.nuit = '',
    this.tipoDocumento = '',
    this.numeroDocumento = '',
    this.dataNascimento,
    this.genero = '',
    this.enderecoCompleto = '',
    this.provincia = '',
    this.distrito = '',
    this.bairro = '',
    this.createdTime,
    this.termoCond,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['display_name'] ?? data['displayName'] ?? '',
      photoUrl: data['photo_url'] ?? data['photoUrl'] ?? '',
      phoneNumber: data['phone_number'] ?? data['phoneNumber'] ?? '',
      cargoInt: data['cargo_Int'] ?? data['cargoInt'] ?? 0,
      cargo: data['cargo'] ?? '',
      statusUsuario: data['statusUsuario'] ?? data['status'] ?? '',
      nuit: data['nuit'] ?? '',
      tipoDocumento: data['tipo_documento'] ?? data['tipoDocumento'] ?? '',
      numeroDocumento:
          data['numero_documento'] ?? data['numeroDocumento'] ?? '',
      dataNascimento: data['data_nascimento'] != null
          ? (data['data_nascimento'] as Timestamp).toDate()
          : null,
      genero: data['genero'] ?? '',
      enderecoCompleto:
          data['endereco_completo'] ?? data['enderecoCompleto'] ?? '',
      provincia: data['provincia'] ?? '',
      distrito: data['distrito'] ?? '',
      bairro: data['bairro'] ?? '',
      createdTime: data['created_time'] != null
          ? (data['created_time'] as Timestamp).toDate()
          : null,
      termoCond: data['termoCond'] as bool?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'phone_number': phoneNumber,
      'cargo_Int': cargoInt,
      'cargo': cargo,
      'statusUsuario': statusUsuario,
      'nuit': nuit,
      'tipo_documento': tipoDocumento,
      'numero_documento': numeroDocumento,
      if (dataNascimento != null)
        'data_nascimento': Timestamp.fromDate(dataNascimento!),
      'genero': genero,
      'endereco_completo': enderecoCompleto,
      'provincia': provincia,
      'distrito': distrito,
      'bairro': bairro,
      if (createdTime != null) 'created_time': Timestamp.fromDate(createdTime!),
      if (termoCond != null) 'termoCond': termoCond,
    };
  }
}
