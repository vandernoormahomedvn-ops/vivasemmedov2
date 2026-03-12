import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for sending notifications via WhatsApp and Email.
///
/// Mirrors the old app's WhatsappCall and EnviarEmailCall from api_calls.dart.
class NotificationService {
  static const String _whatsappUrl =
      'https://n8nevo-evolution-api.gdxg1u.easypanel.host/message/sendMedia/indico_Test';
  static const String _whatsappApiKey =
      'B4D3ACCA6EA6-41B1-8C7B-E3B7D1FF2D02';
  static const String _emailUrl = 'https://8pbmm9.buildship.run/code';

  /// Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Sends a document via WhatsApp using the Evolution API.
  ///
  /// [phoneNumber] — recipient number (e.g. "258841234567")
  /// [documentUrl] — public URL to the PDF document
  /// [caption] — description text sent with the document
  /// [documentType] — filename for the attachment (e.g. "Apolice.pdf")
  Future<bool> sendWhatsApp({
    required String phoneNumber,
    required String documentUrl,
    required String caption,
    String documentType = 'Documento.pdf',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_whatsappUrl),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _whatsappApiKey,
        },
        body: jsonEncode({
          'number': phoneNumber,
          'mediatype': 'document',
          'mimetype': 'application/pdf',
          'caption': caption,
          'media': documentUrl,
          'fileName': documentType,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Sends an email via the Buildship endpoint.
  ///
  /// [recipientEmail] — destination email address
  /// [subject] — email subject
  /// [body] — email body content
  /// [senderEmail] — sender email (defaults to system email)
  Future<bool> sendEmail({
    required String recipientEmail,
    required String subject,
    required String body,
    String senderEmail = 'noreply@indicoseguros.co.mz',
  }) async {
    try {
      final uri = Uri.parse(_emailUrl).replace(queryParameters: {
        'emailEnvio': recipientEmail,
        'messagem': body,
        'assunto': subject,
        'emailSender': senderEmail,
      });

      final response = await http.get(uri);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
