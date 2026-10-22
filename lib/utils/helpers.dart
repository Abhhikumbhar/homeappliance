import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/booking.dart';
import 'translations.dart';

class AppHelpers {
  static final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String formatCurrency(double amount) {
    return currencyFormat.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  /// If a string contains bilingual format like "मराठी (English)",
  /// returns appropriate language string (supports both bool isMr and AppLanguage).
  static String localizedText(String text, dynamic langOrIsMr) {
    final trimmed = text.trim();
    final effectiveLang = (langOrIsMr is AppLanguage)
        ? langOrIsMr
        : AppTranslations.currentLang;
    return AppTranslations.translate(trimmed, effectiveLang);
  }

  /// Formats client address and landmark with proper regional context for accurate Google Maps resolution
  static String buildCleanAddressQuery({
    String? address,
    String? landmark,
  }) {
    final cleanAddr = (address ?? '').trim();
    final cleanLm = (landmark ?? '').trim();

    final parts = <String>[];
    if (cleanAddr.isNotEmpty) {
      parts.add(cleanAddr);
    }
    if (cleanLm.isNotEmpty) {
      // Avoid duplicate if landmark is already part of the address string
      if (!cleanAddr.toLowerCase().contains(cleanLm.toLowerCase())) {
        parts.add(cleanLm);
      }
    }

    if (parts.isEmpty) {
      return 'Sangli, Maharashtra';
    }

    final combined = parts.join(', ');

    // Check if locality/state is already in the address text
    // Check if locality/state is already in the address text (English or Marathi)
    final hasRegionalContext = RegExp(
      r'\b(sangli|miraj|kupwad|karad|kolhapur|satara|pune|mumbai|solapur|ichalkaranji|maharashtra)\b|'
      r'(सांगली|मिरज|कुपवाड|कराड|कोल्हापूर|सातारा|पुणे|मुंबई|सोलापूर|इचलकरंजी|महाराष्ट्र)',
      caseSensitive: false,
    ).hasMatch(combined);

    if (!hasRegionalContext) {
      return '$combined, Sangli, Maharashtra';
    }
    return combined;
  }

  /// Launches Google Maps Navigation to the specified client address & landmark.
  /// Captures client's exact address with first priority for precise navigation.
  static Future<void> openGoogleMaps({
    double lat = 0.0,
    double lng = 0.0,
    String? address,
    String? landmark,
    bool directNavigation = false,
    BuildContext? context,
  }) async {
    final hasAddress = (address != null && address.trim().isNotEmpty) ||
        (landmark != null && landmark.trim().isNotEmpty);

    String query;
    if (hasAddress) {
      query = buildCleanAddressQuery(address: address, landmark: landmark);
    } else if (lat != 0.0 && lng != 0.0) {
      query = '$lat,$lng';
    } else {
      query = 'Sangli, Maharashtra';
    }

    final encodedQuery = Uri.encodeComponent(query);

    // 1. Android Geo Intent (Opens native Google Maps app directly centered on address pin)
    final geoUrl = Uri.parse('geo:0,0?q=$encodedQuery');

    // 2. Android Turn-by-Turn Navigation Intent
    final androidNavUrl = Uri.parse('google.navigation:q=$encodedQuery');

    // 3. iOS Google Maps Scheme
    final iosGoogleMapsUrl = directNavigation
        ? Uri.parse('comgooglemaps://?daddr=$encodedQuery&directionsmode=driving')
        : Uri.parse('comgooglemaps://?q=$encodedQuery');

    // 4. Apple Maps Native Scheme (iOS fallback)
    final appleMapsUrl = directNavigation
        ? Uri.parse('maps://?daddr=$encodedQuery&dirflg=d')
        : Uri.parse('maps://?q=$encodedQuery');

    // 5. Universal Web URL (Browser / Universal Link fallback)
    final webUrl = directNavigation
        ? Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$encodedQuery')
        : Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');

    bool launched = false;

    // A. If direct navigation is requested, try navigation intents first
    if (directNavigation) {
      try {
        if (await canLaunchUrl(androidNavUrl)) {
          launched = await launchUrl(androidNavUrl, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}

      if (!launched) {
        try {
          if (await canLaunchUrl(iosGoogleMapsUrl)) {
            launched = await launchUrl(iosGoogleMapsUrl, mode: LaunchMode.externalApplication);
          }
        } catch (_) {}
      }

      if (!launched) {
        try {
          if (await canLaunchUrl(appleMapsUrl)) {
            launched = await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
          }
        } catch (_) {}
      }
    } else {
      // B. Standard Map View: Open native map app with pin dropped on customer address
      try {
        if (await canLaunchUrl(geoUrl)) {
          launched = await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}

      if (!launched) {
        try {
          if (await canLaunchUrl(iosGoogleMapsUrl)) {
            launched = await launchUrl(iosGoogleMapsUrl, mode: LaunchMode.externalApplication);
          }
        } catch (_) {}
      }

      if (!launched) {
        try {
          if (await canLaunchUrl(appleMapsUrl)) {
            launched = await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
          }
        } catch (_) {}
      }
    }

    // C. Fallback: Universal Google Maps Web URL
    if (!launched) {
      try {
        if (await canLaunchUrl(webUrl)) {
          launched = await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}
    }

    // D. Platform default fallback
    if (!launched) {
      try {
        launched = await launchUrl(webUrl, mode: LaunchMode.platformDefault);
      } catch (err) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('गुगल मॅप्स उघडता आले नाही: $err'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    }
  }

  /// Launches WhatsApp with pre-filled message
  static Future<void> openWhatsApp({
    required String phone,
    required String message,
    BuildContext? context,
  }) async {
    // Sanitize phone number: remove +, spaces, dashes
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final fullPhone = cleanPhone.startsWith('91')
        ? cleanPhone
        : '91$cleanPhone';
    final encodedMsg = Uri.encodeComponent(message);
    final waUrl = Uri.parse('https://wa.me/$fullPhone?text=$encodedMsg');

    try {
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('व्हॉट्सॲप उघडता आले नाही: $waUrl')),
          );
        }
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error launching WhatsApp: $e')));
      }
    }
  }

  /// Make phone call
  static Future<void> makePhoneCall(
    String phone, [
    BuildContext? context,
  ]) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final telUri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('कॉल करता आला नाही: $cleanPhone')),
          );
        }
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Call error: $e')));
      }
    }
  }

  /// Formats the complete job assignment message for the partner with clean, professional spacing
  static String buildJobAssignmentMessage(
    Booking booking, {
    dynamic isMr,
    dynamic lang,
    dynamic langOrIsMr,
  }) {
    final effectiveLang = (lang is AppLanguage)
        ? lang
        : (langOrIsMr is AppLanguage)
            ? langOrIsMr
            : (isMr is AppLanguage)
                ? isMr
                : ((isMr == false || langOrIsMr == false)
                    ? AppLanguage.english
                    : AppTranslations.currentLang);
    final isMarathiScript = effectiveLang == AppLanguage.marathi || effectiveLang != AppLanguage.english;
    final buffer = StringBuffer();
    final serviceTitle = booking.service.localizedTitle(effectiveLang);
    final cleanAddress = buildCleanAddressQuery(address: booking.address, landmark: booking.landmark);
    final mapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(cleanAddress)}';
    final paymentText = booking.paymentMethod == PaymentMethod.upiOnline
        ? tr('ऑनलाइन भरले आहे (Paid Online)', 'Paid Online')
        : tr('रोख किंवा UPI द्वारे घ्यावे (Cash / UPI on Visit)', 'Cash / UPI on Visit');

    if (isMarathiScript) {
      buffer.writeln('📋 *नवीन सर्व्हिस काम सोपवले* (Job Assignment)');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('');
      buffer.writeln('🆔 *बुकिंग आयडी:* #${booking.id}');
      buffer.writeln('');
      buffer.writeln('🛠️ *सर्व्हिस तपशील:*');
      buffer.writeln('$serviceTitle');
      buffer.writeln('');
      buffer.writeln('👤 *ग्राहकाचे नाव:* ${booking.customerName}');
      buffer.writeln('📞 *मोबाईल नंबर:* ${booking.customerPhone}');
      buffer.writeln('');
      buffer.writeln('📍 *घरचा पत्ता (Address):*');
      buffer.writeln('${booking.address}');
      if (booking.landmark.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('🚩 *जवळची खूण (Landmark):*');
        buffer.writeln('${booking.landmark}');
      }
      buffer.writeln('');
      buffer.writeln('⏰ *नियोजित वेळ (Scheduled Slot):*');
      buffer.writeln('${booking.scheduledSlot}');
      buffer.writeln('');
      buffer.writeln('💰 *अंदाजे बिल / मजुरी:* ${formatCurrency(booking.totalAmount)}');
      buffer.writeln('💳 *पेमेंट पद्धत:* $paymentText');
      if (booking.notes.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('📝 *ग्राहकाची तक्रार / समस्या:*');
        buffer.writeln('${booking.notes}');
      }
      buffer.writeln('');
      buffer.writeln('🗺️ *गुगल मॅप्स थेट रस्ता (Location Map):*');
      buffer.writeln('$mapsUrl');
      buffer.writeln('');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('⚠️ *महत्त्वाची सूचना:*');
      buffer.writeln('१. वेळेवर ग्राहकाच्या पत्त्यावर पोहोचा.');
      buffer.writeln('२. काम सुरू करण्यापूर्वी ग्राहकाकडून ४-अंकी OTP घ्या.');
    } else {
      buffer.writeln('📋 *NEW SERVICE JOB ASSIGNED*');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('');
      buffer.writeln('🆔 *Booking ID:* #${booking.id}');
      buffer.writeln('');
      buffer.writeln('🛠️ *Service:*');
      buffer.writeln('$serviceTitle');
      buffer.writeln('');
      buffer.writeln('👤 *Customer Name:* ${booking.customerName}');
      buffer.writeln('📞 *Contact Phone:* ${booking.customerPhone}');
      buffer.writeln('');
      buffer.writeln('📍 *Service Address:*');
      buffer.writeln('${booking.address}');
      if (booking.landmark.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('🚩 *Landmark:*');
        buffer.writeln('${booking.landmark}');
      }
      buffer.writeln('');
      buffer.writeln('⏰ *Scheduled Time Slot:*');
      buffer.writeln('${booking.scheduledSlot}');
      buffer.writeln('');
      buffer.writeln('💰 *Estimated Amount:* ${formatCurrency(booking.totalAmount)}');
      buffer.writeln('💳 *Payment Method:* $paymentText');
      if (booking.notes.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('📝 *Customer Notes / Issue:*');
        buffer.writeln('${booking.notes}');
      }
      buffer.writeln('');
      buffer.writeln('🗺️ *Google Maps Direct Route:*');
      buffer.writeln('$mapsUrl');
      buffer.writeln('');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('⚠️ *Important Instructions:*');
      buffer.writeln('1. Reach the customer doorstep on time.');
      buffer.writeln('2. Request 4-digit OTP from customer before beginning.');
    }

    return buffer.toString().trim();
  }
}
