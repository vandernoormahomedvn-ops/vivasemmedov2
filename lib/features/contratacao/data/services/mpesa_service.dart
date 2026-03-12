import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for M-Pesa C2B payments via the Indico Seguros API.
///
/// Flow: [getToken] → [initiatePayment] → poll/confirm
class MpesaService {
  static const String _tokenUrl =
      'https://e2payments.explicador.co.mz/oauth/token';
  static const String _paymentUrl =
      'https://indico.unitechsolution.co.mz/api/c2bPayment';

  // TODO: Move to Cloud Function for production security
  static const String _clientId = '9d1a0e7b-9785-4087-8857-c461fefeb1dc';
  static const String _clientSecret = 'JXjS2MVnmM7CcevFZ5ukjEuM0L6CBGsibMCaykcO';

  String? _cachedToken;
  DateTime? _tokenExpiry;

  /// Singleton
  static final MpesaService _instance = MpesaService._internal();
  factory MpesaService() => _instance;
  MpesaService._internal();

  /// Gets an OAuth token, caching it until expiry.
  Future<String> getToken() async {
    // Return cached token if still valid
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedToken!;
    }

    final response = await http.post(
      Uri.parse(_tokenUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'grant_type': 'client_credentials',
        'client_id': _clientId,
        'client_secret': _clientSecret,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _cachedToken = data['access_token'] as String;
      // Cache for 50 minutes (tokens typically expire in 60min)
      _tokenExpiry = DateTime.now().add(const Duration(minutes: 50));
      return _cachedToken!;
    } else {
      throw MpesaException(
        'Falha ao obter token de autenticação',
        statusCode: response.statusCode,
        body: response.body,
      );
    }
  }

  /// Initiates a C2B M-Pesa payment.
  ///
  /// [amount] — value in MZN (e.g. "3250.00")
  /// [phoneNumber] — subscriber MSISDN (e.g. "258841234567")
  /// [reference] — transaction reference (e.g. "APOLICE-2024-001")
  Future<MpesaPaymentResult> initiatePayment({
    required String amount,
    required String phoneNumber,
    required String reference,
  }) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse(_paymentUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,
        'msisdn': phoneNumber,
        'transaction_ref': reference,
        'thirdparty_ref': token,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return MpesaPaymentResult(
        success: true,
        transactionId: data['transactionId']?.toString() ?? '',
        message: data['message']?.toString() ?? 'Pagamento iniciado',
        rawResponse: data,
      );
    } else {
      return MpesaPaymentResult(
        success: false,
        transactionId: '',
        message: 'Falha no pagamento. Tente novamente.',
        rawResponse: jsonDecode(response.body),
      );
    }
  }
}

/// Result of an M-Pesa payment attempt.
class MpesaPaymentResult {
  final bool success;
  final String transactionId;
  final String message;
  final Map<String, dynamic> rawResponse;

  const MpesaPaymentResult({
    required this.success,
    required this.transactionId,
    required this.message,
    required this.rawResponse,
  });
}

/// Custom exception for M-Pesa API errors.
class MpesaException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  const MpesaException(this.message, {this.statusCode, this.body});

  @override
  String toString() =>
      'MpesaException: $message (status: $statusCode, body: $body)';
}
