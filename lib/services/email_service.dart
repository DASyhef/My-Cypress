import 'package:url_launcher/url_launcher.dart';

abstract class EmailService {
  Future<void> sendEmail({
    required String toEmail,
    required String subject,
    required String body,
  });
}

class MailtoEmailService implements EmailService {
  @override
  Future<void> sendEmail({
    required String toEmail,
    required String subject,
    required String body,
  }) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: toEmail,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Impossible d\'ouvrir l\'application de messagerie.';
    }
  }
}