import 'package:url_launcher/url_launcher.dart';

class SmsService {
  // 1. Send SOS via default SMS app (opens SMS app with prefilled message)
  Future<bool> sendSOSMessage(List<String> recipients, String message) async {
    try {
      final String recipientStr = recipients.join(',');
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: recipientStr,
        query: 'body=${Uri.encodeComponent(message)}',
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return true;
      } else {
        print("⚠️ SMS app could not be launched.");
        return false;
      }
    } catch (e) {
      print("❌ SmsService Error: $e");
      return false;
    }
  }

  // 2. Send SOS via WhatsApp to each trusted contact individually
  Future<void> sendWhatsAppSOS(List<String> recipients, String message) async {
    final String encodedMessage = Uri.encodeComponent(message);
    bool anySuccess = false;

    for (final String rawPhone in recipients) {
      try {
        // Normalize the phone number: remove +, spaces, dashes
        final String phone = rawPhone
            .replaceAll('+', '')
            .replaceAll(' ', '')
            .replaceAll('-', '')
            .trim();

        // WhatsApp deep link: opens chat with pre-filled message
        final Uri whatsappUri = Uri.parse(
          'https://wa.me/$phone?text=$encodedMessage',
        );

        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
          print("✅ WhatsApp SOS sent to: $phone");
          anySuccess = true;
          // Small delay before opening next contact chat
          await Future.delayed(const Duration(milliseconds: 800));
        } else {
          print("⚠️ WhatsApp not installed or URI not launchable for: $phone");
        }
      } catch (e) {
        print("❌ WhatsApp SOS Error for $rawPhone: $e");
      }
    }

    if (!anySuccess) {
      print("⚠️ WhatsApp SOS failed for all contacts. Check WhatsApp installation.");
    }
  }

  // 3. Unified SOS Alert Dispatcher: SMS + WhatsApp both
  Future<void> sendSOSAlerts(List<String> recipients, String message) async {
    print("🚨 Dispatching SOS Alerts via SMS + WhatsApp to ${recipients.length} contacts...");

    // Fire both in parallel
    await Future.wait([
      sendSOSMessage(recipients, message),
      sendWhatsAppSOS(recipients, message),
    ]);

    print("✅ All SOS alert channels dispatched.");
  }
}