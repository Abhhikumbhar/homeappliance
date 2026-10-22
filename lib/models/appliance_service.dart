import 'package:flutter/material.dart';
import '../utils/translations.dart';

enum ServiceCategory {
  ac,
  roWater,
  refrigerator,
  washingMachine,
  geyser,
  plumbing,
  electrical,
  chimney,
  other,
}

extension ServiceCategoryExt on ServiceCategory {
  String get nameEn {
    switch (this) {
      case ServiceCategory.ac:
        return 'AC Service & Repair';
      case ServiceCategory.roWater:
        return 'Water Purifier (RO)';
      case ServiceCategory.refrigerator:
        return 'Refrigerator Repair';
      case ServiceCategory.washingMachine:
        return 'Washing Machine';
      case ServiceCategory.geyser:
        return 'Geyser & Water Heater';
      case ServiceCategory.plumbing:
        return 'Plumbing & Fitting';
      case ServiceCategory.electrical:
        return 'Electrical & Wiring';
      case ServiceCategory.chimney:
        return 'Kitchen Chimney & Hob';
      case ServiceCategory.other:
        return 'Other Services';
    }
  }

  String get nameMr {
    switch (this) {
      case ServiceCategory.ac:
        return 'एसी सर्व्हिस व दुरुस्ती';
      case ServiceCategory.roWater:
        return 'वॉटर प्युरिफायर';
      case ServiceCategory.refrigerator:
        return 'फ्रिज दुरुस्ती';
      case ServiceCategory.washingMachine:
        return 'वॉशिंग मशीन दुरुस्ती';
      case ServiceCategory.geyser:
        return 'गिझर सर्व्हिसिंग';
      case ServiceCategory.plumbing:
        return 'प्लंबिंग व फिटिंग';
      case ServiceCategory.electrical:
        return 'इलेक्ट्रिशियन व वायरिंग';
      case ServiceCategory.chimney:
        return 'किचन चिमणी क्लिनिंग';
      case ServiceCategory.other:
        return 'इतर घरगुती सेवा';
    }
  }

  String get nameHi {
    switch (this) {
      case ServiceCategory.ac:
        return 'एसी सर्विस व मरम्मत';
      case ServiceCategory.roWater:
        return 'वाटर प्यूरिफायर (RO)';
      case ServiceCategory.refrigerator:
        return 'फ्रिज मरम्मत';
      case ServiceCategory.washingMachine:
        return 'वाशिंग मशीन मरम्मत';
      case ServiceCategory.geyser:
        return 'गीजर व वाटर हीटर';
      case ServiceCategory.plumbing:
        return 'प्लंबिंग व फिटिंग';
      case ServiceCategory.electrical:
        return 'इलेक्ट्रीशियन व वायरिंग';
      case ServiceCategory.chimney:
        return 'किचन चिमनी व हॉब';
      case ServiceCategory.other:
        return 'अन्य सेवाएं';
    }
  }

  String get nameKn {
    switch (this) {
      case ServiceCategory.ac:
        return 'ಎಸಿ ಸೇವೆ ಮತ್ತು ದುರಸ್ತಿ';
      case ServiceCategory.roWater:
        return 'ವಾಟರ್ ಪ್ಯೂರಿಫೈಯರ್ (RO)';
      case ServiceCategory.refrigerator:
        return 'ರೆಫ್ರಿಜರೇಟರ್ ದುರಸ್ತಿ';
      case ServiceCategory.washingMachine:
        return 'ವಾಷಿಂಗ್ ಮೆಷಿನ್ ದುರಸ್ತಿ';
      case ServiceCategory.geyser:
        return 'ಗೀಸರ್ ಮತ್ತು ವಾಟರ್ ಹೀಟರ್';
      case ServiceCategory.plumbing:
        return 'ಪ್ಲಂಬಿಂಗ್ ಮತ್ತು ಫಿಟ್ಟಿಂಗ್';
      case ServiceCategory.electrical:
        return 'ಎಲೆಕ್ಟ್ರಿಷಿಯನ್ ಮತ್ತು ವೈರಿಂಗ್';
      case ServiceCategory.chimney:
        return 'ಕಿಚನ್ ಚಿಮಣಿ ಮತ್ತು ಹಾಬ್';
      case ServiceCategory.other:
        return 'ಇತರ ಸೇವೆಗಳು';
    }
  }

  String get nameGu {
    switch (this) {
      case ServiceCategory.ac:
        return 'એસી સર્વિસ અને રિપેરિંગ';
      case ServiceCategory.roWater:
        return 'વોટર પ્યુરિફાયર (RO)';
      case ServiceCategory.refrigerator:
        return 'રેફ્રિજરેટર રિપેરિંગ';
      case ServiceCategory.washingMachine:
        return 'વોશિંગ મશીન સમારકામ';
      case ServiceCategory.geyser:
        return 'ગીઝર અને વોટર હીટર';
      case ServiceCategory.plumbing:
        return 'પ્લમ્બિંગ અને ફિટિંગ';
      case ServiceCategory.electrical:
        return 'ઇલેક્ટ્રિશિયન અને વાયરિંગ';
      case ServiceCategory.chimney:
        return 'કિચન ચીમની અને હોબ';
      case ServiceCategory.other:
        return 'અન્ય સેવાઓ';
    }
  }

  String localizedName(dynamic langOrIsMr) {
    if (langOrIsMr is bool) {
      return langOrIsMr ? nameMr : nameEn;
    }
    if (langOrIsMr is AppLanguage) {
      switch (langOrIsMr) {
        case AppLanguage.marathi:
          return nameMr;
        case AppLanguage.english:
          return nameEn;
        case AppLanguage.hindi:
          return nameHi;
        case AppLanguage.kannada:
          return nameKn;
        case AppLanguage.gujarati:
          return nameGu;
      }
    }
    return nameMr;
  }

  IconData get icon {
    switch (this) {
      case ServiceCategory.ac:
        return Icons.ac_unit_rounded;
      case ServiceCategory.roWater:
        return Icons.water_drop_rounded;
      case ServiceCategory.refrigerator:
        return Icons.kitchen_rounded;
      case ServiceCategory.washingMachine:
        return Icons.local_laundry_service_rounded;
      case ServiceCategory.geyser:
        return Icons.waves_rounded;
      case ServiceCategory.plumbing:
        return Icons.plumbing_rounded;
      case ServiceCategory.electrical:
        return Icons.bolt_rounded;
      case ServiceCategory.chimney:
        return Icons.soup_kitchen_rounded;
      case ServiceCategory.other:
        return Icons.miscellaneous_services_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ServiceCategory.ac:
        return const Color(0xFF0284C7);
      case ServiceCategory.roWater:
        return const Color(0xFF06B6D4);
      case ServiceCategory.refrigerator:
        return const Color(0xFF6366F1);
      case ServiceCategory.washingMachine:
        return const Color(0xFF8B5CF6);
      case ServiceCategory.geyser:
        return const Color(0xFFEA580C);
      case ServiceCategory.plumbing:
        return const Color(0xFF0D9488);
      case ServiceCategory.electrical:
        return const Color(0xFFD97706);
      case ServiceCategory.chimney:
        return const Color(0xFFE11D48);
      case ServiceCategory.other:
        return const Color(0xFF64748B);
    }
  }
}

class ServicePackage {
  final String id;
  final ServiceCategory category;
  final String? customCategoryName;
  final String titleEn;
  final String titleMr;
  final String descriptionEn;
  final String descriptionMr;
  final double basePrice;
  final double originalPrice;
  final int durationMinutes;
  final double rating;
  final int reviewsCount;
  final int warrantyDays;
  final List<String> inclusions;
  final List<String> exclusions;
  final bool isFestiveOffer;

  const ServicePackage({
    required this.id,
    required this.category,
    this.customCategoryName,
    required this.titleEn,
    required this.titleMr,
    required this.descriptionEn,
    required this.descriptionMr,
    required this.basePrice,
    required this.originalPrice,
    required this.durationMinutes,
    this.rating = 4.8,
    this.reviewsCount = 142,
    this.warrantyDays = 30,
    required this.inclusions,
    required this.exclusions,
    this.isFestiveOffer = false,
  });

  String getCategoryName(dynamic langOrIsMr) {
    if (customCategoryName != null && customCategoryName!.trim().isNotEmpty) {
      return customCategoryName!.trim();
    }
    return category.localizedName(langOrIsMr);
  }

  String localizedTitle([dynamic langOrIsMr]) {
    final lang = (langOrIsMr is AppLanguage)
        ? langOrIsMr
        : AppTranslations.currentLang;
    switch (lang) {
      case AppLanguage.marathi:
        return titleMr;
      case AppLanguage.english:
        return titleEn;
      case AppLanguage.hindi:
      case AppLanguage.kannada:
      case AppLanguage.gujarati:
        return AppTranslations.trText(titleMr, titleEn, lang);
    }
  }

  String localizedDescription([dynamic langOrIsMr]) {
    final lang = (langOrIsMr is AppLanguage)
        ? langOrIsMr
        : AppTranslations.currentLang;
    switch (lang) {
      case AppLanguage.marathi:
        return descriptionMr;
      case AppLanguage.english:
        return descriptionEn;
      case AppLanguage.hindi:
      case AppLanguage.kannada:
      case AppLanguage.gujarati:
        return AppTranslations.trText(descriptionMr, descriptionEn, lang);
    }
  }

  ServicePackage copyWith({
    String? id,
    ServiceCategory? category,
    String? customCategoryName,
    String? titleEn,
    String? titleMr,
    String? descriptionEn,
    String? descriptionMr,
    double? basePrice,
    double? originalPrice,
    int? durationMinutes,
    double? rating,
    int? reviewsCount,
    int? warrantyDays,
    List<String>? inclusions,
    List<String>? exclusions,
    bool? isFestiveOffer,
  }) {
    return ServicePackage(
      id: id ?? this.id,
      category: category ?? this.category,
      customCategoryName: customCategoryName ?? this.customCategoryName,
      titleEn: titleEn ?? this.titleEn,
      titleMr: titleMr ?? this.titleMr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionMr: descriptionMr ?? this.descriptionMr,
      basePrice: basePrice ?? this.basePrice,
      originalPrice: originalPrice ?? this.originalPrice,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      warrantyDays: warrantyDays ?? this.warrantyDays,
      inclusions: inclusions ?? this.inclusions,
      exclusions: exclusions ?? this.exclusions,
      isFestiveOffer: isFestiveOffer ?? this.isFestiveOffer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'customCategoryName': customCategoryName,
      'titleEn': titleEn,
      'titleMr': titleMr,
      'descriptionEn': descriptionEn,
      'descriptionMr': descriptionMr,
      'basePrice': basePrice,
      'originalPrice': originalPrice,
      'durationMinutes': durationMinutes,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'warrantyDays': warrantyDays,
      'inclusions': inclusions,
      'exclusions': exclusions,
      'isFestiveOffer': isFestiveOffer,
    };
  }

  factory ServicePackage.fromJson(Map<String, dynamic> json) {
    ServiceCategory cat = ServiceCategory.other;
    for (var c in ServiceCategory.values) {
      if (c.name == json['category']) {
        cat = c;
        break;
      }
    }
    return ServicePackage(
      id: json['id'] as String? ?? 'srv_${DateTime.now().millisecondsSinceEpoch}',
      category: cat,
      customCategoryName: json['customCategoryName'] as String?,
      titleEn: json['titleEn'] as String? ?? '',
      titleMr: json['titleMr'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      descriptionMr: json['descriptionMr'] as String? ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 45,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 100,
      warrantyDays: (json['warrantyDays'] as num?)?.toInt() ?? 30,
      inclusions: (json['inclusions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      exclusions: (json['exclusions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isFestiveOffer: json['isFestiveOffer'] as bool? ?? false,
    );
  }
}

class MockServicesData {
  static final List<ServicePackage> allServices = [
    // 1. AC Services
    const ServicePackage(
      id: 'ac_deep_clean',
      category: ServiceCategory.ac,
      titleEn: 'Diwali AC Deep Jet Servicing',
      titleMr: 'दिवाळी एसी डीप जेट सर्व्हिसिंग',
      descriptionEn: 'High-pressure jet wash, indoor coil deep cleaning, cooling check & drain tray cleaning.',
      descriptionMr: 'हाय-प्रेशर जेट वॉश, इनडोअर कॉईल क्लिनिंग, कुलिंग तपासणी आणि ड्रेन ट्रे क्लिनिंग.',
      basePrice: 499,
      originalPrice: 799,
      durationMinutes: 45,
      rating: 4.9,
      reviewsCount: 380,
      warrantyDays: 30,
      isFestiveOffer: true,
      inclusions: [
        'Foam + High-pressure water jet clean',
        'Outdoor unit water wash',
        'Cooling gas pressure check',
        'Drain pipe unclogging',
      ],
      exclusions: [
        'Spare parts cost (capacitors, sensors)',
        'Gas refilling (charged extra per kg)',
      ],
    ),
    const ServicePackage(
      id: 'ac_gas_leak',
      category: ServiceCategory.ac,
      titleEn: 'AC Gas Charging & Leak Repair',
      titleMr: 'एसी गॅस चार्जिंग व लिकेज दुरुस्ती',
      descriptionEn: 'Complete nitrogen pressure test, leak brazing and 100% pure refrigerant gas refill.',
      descriptionMr: 'नायट्रोजन प्रेशर टेस्टिंग, लिकेज वेल्डिंग व १००% प्युअर रेफ्रिजरंट गॅस रिफिल.',
      basePrice: 1899,
      originalPrice: 2499,
      durationMinutes: 60,
      rating: 4.8,
      reviewsCount: 215,
      warrantyDays: 60,
      inclusions: [
        'Complete nitrogen leak detection',
        'Copper pipe leak brazing',
        'Complete vacuum pump evac',
        'Refrigerant gas top-up (R32 / R410A)',
      ],
      exclusions: ['Compressor replacement'],
    ),
    const ServicePackage(
      id: 'ac_install',
      category: ServiceCategory.ac,
      titleEn: 'AC Installation / Uninstallation',
      titleMr: 'एसी नवीन फिटिंग व अनइन्स्टॉलेशन',
      descriptionEn: 'Professional mounting of indoor and outdoor unit, core hole drilling and testing.',
      descriptionMr: 'इनडोअर व आउटडोअर युनिट सुरक्षित फिटिंग, कॉपर पाईप जोडणी व कुलिंग टेस्ट.',
      basePrice: 699,
      originalPrice: 999,
      durationMinutes: 60,
      rating: 4.85,
      reviewsCount: 160,
      warrantyDays: 30,
      inclusions: [
        'Indoor bracket installation',
        'Outdoor unit stand mounting',
        'Flaring and pipe connection',
        'Gas check and demo',
      ],
      exclusions: ['Extra copper pipe cost', 'Stand purchase'],
    ),

    // 2. RO Water Purifier
    const ServicePackage(
      id: 'ro_full_service',
      category: ServiceCategory.roWater,
      titleEn: 'RO Complete Filter Replacement & Service',
      titleMr: 'आरओ पूर्ण फिल्टर बदल व सर्व्हिसिंग',
      descriptionEn: 'Sediment, Carbon filter replacement, TDS test, UV/UF check, and full sanitization.',
      descriptionMr: 'सेडिमेंट, कार्बन फिल्टर बदल, टीडीएस चाचणी, यूव्ही चेक आणि संपूर्ण स्वच्छता.',
      basePrice: 799,
      originalPrice: 1200,
      durationMinutes: 40,
      rating: 4.9,
      reviewsCount: 420,
      warrantyDays: 90,
      isFestiveOffer: true,
      inclusions: [
        'Pre-filter candle replacement',
        'Sediment filter & Activated Carbon replacement',
        'Raw water & pure water TDS measurement',
        'Leakage & booster pump pressure check',
      ],
      exclusions: ['RO Membrane replacement (extra if choked)'],
    ),
    const ServicePackage(
      id: 'ro_general_service',
      category: ServiceCategory.roWater,
      titleEn: 'RO Regular Checkup & TDS Tuning',
      titleMr: 'आरओ नियमित तपासणी व टीडीएस ट्युनिंग',
      descriptionEn: 'Complete purifier sanitization, TDS balance adjustment and water leakage check.',
      descriptionMr: 'आरओ प्युरिफायर स्वच्छता, टीडीएस लेव्हल ॲडजस्टमेंट व वॉटर लीकेज तपासणी.',
      basePrice: 249,
      originalPrice: 399,
      durationMinutes: 30,
      rating: 4.8,
      reviewsCount: 230,
      warrantyDays: 30,
      inclusions: [
        'Water flow & TDS check',
        'Pre-filter chamber cleaning',
        'Pump vibration & power check',
      ],
      exclusions: ['Replacement filter candles'],
    ),

    // 3. Washing Machine
    const ServicePackage(
      id: 'wm_drum_service',
      category: ServiceCategory.washingMachine,
      titleEn: 'Washing Machine Deep Descaling & Checkup',
      titleMr: 'वॉशिंग मशीन डीप डिगेलिंग व तपासणी',
      descriptionEn: 'Drum tub cleaning, lint filter wash, motor vibration check & drainage troubleshooting.',
      descriptionMr: 'ड्रम टब स्वच्छता, लिंट फिल्टर वॉश, मोटर व्हायब्रेशन चेक व ड्रेनेज दुरुस्ती.',
      basePrice: 399,
      originalPrice: 599,
      durationMinutes: 45,
      rating: 4.7,
      reviewsCount: 190,
      warrantyDays: 30,
      inclusions: [
        'Full automatic tub chemical descaling',
        'Inlet & outlet hose check',
        'Spin & agitation test',
      ],
      exclusions: ['Electronic PCB repair'],
    ),
    const ServicePackage(
      id: 'wm_spec_pcb',
      category: ServiceCategory.washingMachine,
      titleEn: 'PCB Board Repair & Replacement',
      titleMr: 'पीसीबी बोर्ड दुरुस्ती व बदलणे',
      descriptionEn: 'Component-level micro soldering, IC reprogramming, power supply & display troubleshooting.',
      descriptionMr: 'मायक्रो कंपोनंट सोल्डरिंग, आयसी रिप्रोग्रामिंग, डिस्प्ले एरर आणि पॉवर सर्किट दुरुस्ती.',
      basePrice: 899,
      originalPrice: 1299,
      durationMinutes: 60,
      rating: 4.95,
      reviewsCount: 312,
      warrantyDays: 90,
      inclusions: [
        'Component-level micro soldering & IC testing',
        'Relay, capacitor & voltage regulator check',
        'Original test-bench load diagnostic',
        '90-Day specialized circuit warranty',
      ],
      exclusions: ['Completely burnt board casing replacement'],
    ),
    const ServicePackage(
      id: 'wm_spec_inverter',
      category: ServiceCategory.washingMachine,
      titleEn: 'Inverter Motor & Inverter PCB Repair',
      titleMr: 'इन्व्हर्टर मोटर व इन्व्हर्टर पीसीबी दुरुस्ती',
      descriptionEn: 'Direct Drive / BLDC motor diagnosis, inverter controller board repair & variable frequency drive fixes.',
      descriptionMr: 'डायरेक्ट ड्राईव्ह / बीएलडीसी मोटर टेस्ट, इन्व्हर्टर आयपीएम ड्राइव्ह कार्ड दुरुस्ती व व्हायब्रेशन सोल्यूशन.',
      basePrice: 1199,
      originalPrice: 1699,
      durationMinutes: 75,
      rating: 4.92,
      reviewsCount: 248,
      warrantyDays: 90,
      inclusions: [
        'Direct Drive BLDC motor rotor/stator testing',
        'Inverter IPM power module & hall sensor diagnosis',
        'Speed frequency oscillation tuning',
        '90-Day drive warranty',
      ],
      exclusions: ['Entire motor stator copper replacement if burnt'],
    ),
    const ServicePackage(
      id: 'wm_spec_frontload',
      category: ServiceCategory.washingMachine,
      titleEn: 'Front Load Washing Machine Repair',
      titleMr: 'फ्रंट लोड वॉशिंग मशीन स्पेशलिस्ट दुरुस्ती',
      descriptionEn: 'Drum bearing replacement, door boot seal gasket, spider arm repair & anti-vibration balancing.',
      descriptionMr: 'ओरिजिनल ड्रम बेअरिंग बदलणे, स्पायडर आर्म रिपेअर, डोअर रबर गास्केट बदल व स्पिनिंग आवाज निवारण.',
      basePrice: 699,
      originalPrice: 999,
      durationMinutes: 60,
      rating: 4.9,
      reviewsCount: 286,
      warrantyDays: 90,
      inclusions: [
        'Heavy-duty drum bearing & oil seal fitting',
        'Door bellows rubber gasket leak repair',
        'Spider arm & shock absorber vibration alignment',
        'High-speed spin noise dampening test',
      ],
      exclusions: ['Outer drum tub plastic casting replacement'],
    ),
    const ServicePackage(
      id: 'wm_spin_drain',
      category: ServiceCategory.washingMachine,
      titleEn: 'Spin, Drain & Water Leakage Fix',
      titleMr: 'स्पिन, ड्रेन व पाणी गळती दुरुस्ती',
      descriptionEn: 'Fix drum not rotating, water drainage blockage and pipe leakages for Front & Top load.',
      descriptionMr: 'ड्रम न फिरणे, ड्रेन ब्लॉकेज आणि फ्रंट/टॉप लोड मशीनची पाणी गळती दुरुस्ती.',
      basePrice: 449,
      originalPrice: 650,
      durationMinutes: 45,
      rating: 4.85,
      reviewsCount: 145,
      warrantyDays: 30,
      inclusions: [
        'Drain pump unclogging',
        'Belt tension check',
        'Door lock / sensor testing',
      ],
      exclusions: ['Motor rewinding', 'Main PCB replacement'],
    ),

    // 4. Refrigerator
    const ServicePackage(
      id: 'fridge_cooling_repair',
      category: ServiceCategory.refrigerator,
      titleEn: 'Refrigerator Cooling & Compressor Diagnostics',
      titleMr: 'फ्रीज कुलिंग व कॉम्प्रेसर दुरुस्ती',
      descriptionEn: 'Thermostat inspection, defrost timer check, gas level test & door gasket replacement.',
      descriptionMr: 'थर्मोस्टॅट तपासणी, डीफ्रॉस्ट टाइमर चेक, गॅस लेव्हल टेस्ट आणि दरवाजा गॅस्केट बदल.',
      basePrice: 349,
      originalPrice: 499,
      durationMinutes: 40,
      rating: 4.8,
      reviewsCount: 160,
      warrantyDays: 30,
      inclusions: [
        'Complete diagnostics',
        'Door seal inspection',
        'Coil cleaning',
      ],
      exclusions: ['Compressor cost', 'Relay/OLP parts'],
    ),
    const ServicePackage(
      id: 'fridge_gas_charging',
      category: ServiceCategory.refrigerator,
      titleEn: 'Refrigerator Gas Refill & Leak Fix',
      titleMr: 'फ्रीज गॅस रिफिल व कुलिंग कॉईल दुरुस्ती',
      descriptionEn: 'Pin valve installation, vacuum testing, filter drier change and 100% genuine gas filling.',
      descriptionMr: 'पिन व्हॉल्व्ह वेल्डिंग, व्हॅक्यूम टेस्टिंग, ड्रायर फिल्टर बदल आणि प्युअर गॅस चार्जिंग.',
      basePrice: 1099,
      originalPrice: 1599,
      durationMinutes: 50,
      rating: 4.88,
      reviewsCount: 180,
      warrantyDays: 60,
      inclusions: [
        'Leak brazing & vacuuming',
        'Filter drier replacement',
        'Refrigerant gas top-up',
      ],
      exclusions: ['Compressor replacement'],
    ),

    // 5. Plumbing & Fitting
    const ServicePackage(
      id: 'plumbing_fitting',
      category: ServiceCategory.plumbing,
      titleEn: 'Plumbing Fitting & Leakage Solution',
      titleMr: 'प्लंबर - नळ, पाईप फिटिंग व लिकेज दुरुस्ती',
      descriptionEn: 'Expert plumber visit for pipe fitting, tap installation, toilet flush & concealed leakage.',
      descriptionMr: 'तज्ज्ञ प्लंबर भेट: पाईप फिटिंग, नळ बसवणे, टॉयलेट फ्लश व लिकेज निराकरण.',
      basePrice: 249,
      originalPrice: 399,
      durationMinutes: 45,
      rating: 4.8,
      reviewsCount: 512,
      warrantyDays: 30,
      inclusions: [
        'Up to 1 hour of labor for fitting/repairs',
        'Pressure & joint leakage testing',
        'All installation tools included',
      ],
      exclusions: ['Hardware & pipe materials cost'],
    ),
    const ServicePackage(
      id: 'plumbing_blockage',
      category: ServiceCategory.plumbing,
      titleEn: 'Blocked Drain Pipe & Flush Tank Repair',
      titleMr: 'ड्रेनेज चोकअप व फ्लश टँक दुरुस्ती',
      descriptionEn: 'Clearing kitchen sink, bathroom drain blockage and toilet flush mechanism overhaul.',
      descriptionMr: 'किचन सिंक, बाथरुम ड्रेनेज चोकअप मोकळे करणे आणि फ्लश टँक दुरुस्ती.',
      basePrice: 299,
      originalPrice: 450,
      durationMinutes: 40,
      rating: 4.82,
      reviewsCount: 220,
      warrantyDays: 30,
      inclusions: [
        'Drain line clearing with wire pump',
        'Flush syphon / ball-valve tuning',
        'Leak check',
      ],
      exclusions: ['New sanitaryware purchase'],
    ),

    // 6. Electrical & Wiring
    const ServicePackage(
      id: 'electrical_fitting',
      category: ServiceCategory.electrical,
      titleEn: 'Electrician Fitting & MCB Inspection',
      titleMr: 'इलेक्ट्रिशियन - स्वीचबोर्ड, वायरिंग व फिटिंग',
      descriptionEn: 'Switchboard installation, short-circuit troubleshooting, fan/geyser wiring & MCB setup.',
      descriptionMr: 'स्वीचबोर्ड बसवणे, शॉर्ट-सर्किट तपासणी, फॅन/गिझर वायरिंग व एमसीबी इन्स्टॉलेशन.',
      basePrice: 249,
      originalPrice: 399,
      durationMinutes: 40,
      rating: 4.9,
      reviewsCount: 390,
      warrantyDays: 30,
      inclusions: [
        'Wiring continuity check',
        'Earth testing',
        'Installation labor',
      ],
      exclusions: ['Electrical wires, switches, MCBs'],
    ),
    const ServicePackage(
      id: 'electrical_fan_repair',
      category: ServiceCategory.electrical,
      titleEn: 'Ceiling Fan Installation & Repair',
      titleMr: 'सिलिंग फॅन नवीन फिटिंग व बेअरिंग बदल',
      descriptionEn: 'Ceiling fan hanging, downrod fitting, capacitor replacement and noise troubleshooting.',
      descriptionMr: 'नवीन पंखा बसवणे, कॅपेसिटर बदलणे, स्पीड समस्या व आवाज दुरुस्ती.',
      basePrice: 199,
      originalPrice: 299,
      durationMinutes: 30,
      rating: 4.85,
      reviewsCount: 310,
      warrantyDays: 30,
      inclusions: [
        'Fan blade balancing',
        'Hook & regulator connection',
        'Testing with dimmer switch',
      ],
      exclusions: ['New fan purchase', 'Capacitor cost'],
    ),

    // 7. Geyser & Water Heater
    const ServicePackage(
      id: 'geyser_maintenance',
      category: ServiceCategory.geyser,
      titleEn: 'Geyser Deep Descaling & Element Check',
      titleMr: 'गिझर डीप क्लिनिंग व कॉइल तपासणी',
      descriptionEn: 'Full heating element scale removal, thermostat calibration, pressure valve test & water flow tuning.',
      descriptionMr: 'हिटिंग कॉइलवरील क्षार साफ करणे, थर्मोस्टॅट तपासणी व प्रेशर व्हॉल्व्ह सुरक्षितता चाचणी.',
      basePrice: 349,
      originalPrice: 499,
      durationMinutes: 45,
      rating: 4.85,
      reviewsCount: 280,
      warrantyDays: 30,
      inclusions: [
        'Tank draining and scale flushing',
        'Heating element inspection',
        'Safety valve and thermostat check',
      ],
      exclusions: ['Replacement of heating element or thermostat'],
    ),
    const ServicePackage(
      id: 'geyser_install',
      category: ServiceCategory.geyser,
      titleEn: 'Geyser Installation & Pipe Fitting',
      titleMr: 'नवीन गिझर फिटिंग व पाईप कनेक्शन',
      descriptionEn: 'Secure wall bracket mounting, inlet/outlet braided pipe connection and safety check.',
      descriptionMr: 'भिंतीवर मजबूत हँगिंग, इनलेट/आउटलेट पाईप जोडणी व लीकेज टेस्ट.',
      basePrice: 299,
      originalPrice: 450,
      durationMinutes: 40,
      rating: 4.88,
      reviewsCount: 195,
      warrantyDays: 30,
      inclusions: [
        'Wall drilling & anchor fixing',
        'Inlet/outlet connection with safety valve',
        'Electrical point test',
      ],
      exclusions: ['Geyser purchase', 'Extra connection pipes'],
    ),
    const ServicePackage(
      id: 'geyser_repair',
      category: ServiceCategory.geyser,
      titleEn: 'Geyser Not Heating / Thermostat Repair',
      titleMr: 'गिझर पाणी गरम न होणे व थर्मोस्टॅट दुरुस्ती',
      descriptionEn: 'Fix no hot water, tripping MCB, burnt heating element and auto-cut thermostat malfunction.',
      descriptionMr: 'पाणी गरम न होणे, एमसीबी ट्रिपिंग, कॉइल जळणे व थर्मोस्टॅट दुरुस्ती.',
      basePrice: 399,
      originalPrice: 599,
      durationMinutes: 45,
      rating: 4.84,
      reviewsCount: 175,
      warrantyDays: 30,
      inclusions: [
        'Multimeter resistance test',
        'Wiring & cut-off reset',
        'Heating speed verification',
      ],
      exclusions: ['New heating coil / thermostat parts cost'],
    ),

    // 8. Kitchen Chimney & Hob
    const ServicePackage(
      id: 'chimney_deep_clean',
      category: ServiceCategory.chimney,
      titleEn: 'Kitchen Chimney & Filter Degreasing',
      titleMr: 'किचन चिमणी व फिल्टर ऑइल डिग्रेसिंग',
      descriptionEn: 'Heavy oil baffle filter degreasing, motor impeller cleaning, outer stainless steel polish & suction check.',
      descriptionMr: 'चिमणी बॅफल फिल्टरवरील तेल साफ करणे, मोटर ब्लोअर स्वच्छता व सक्शन पॉवर चाचणी.',
      basePrice: 499,
      originalPrice: 799,
      durationMinutes: 60,
      rating: 4.82,
      reviewsCount: 310,
      warrantyDays: 30,
      inclusions: [
        'Baffle / mesh filter chemical degreasing',
        'Oil collector cup emptying and wash',
        'Blower fan motor dust removal',
      ],
      exclusions: ['Duct pipe replacement', 'Motor replacement'],
    ),
    const ServicePackage(
      id: 'chimney_install',
      category: ServiceCategory.chimney,
      titleEn: 'Chimney Installation & Duct Pipe Fitting',
      titleMr: 'नवीन चिमणी व डक्ट पाईप इन्स्टॉलेशन',
      descriptionEn: 'Precision hole drilling, bracket mounting, flexible duct pipe routing and air suction check.',
      descriptionMr: 'भिंतीवर चिमणी माउंटिंग, डक्ट पाईप बाहेर काढणे व व्हायब्रेशन टेस्टिंग.',
      basePrice: 699,
      originalPrice: 999,
      durationMinutes: 60,
      rating: 4.85,
      reviewsCount: 140,
      warrantyDays: 30,
      inclusions: [
        'Bracket mounting on tiles/wall',
        'Duct pipe clamping',
        'Suction power demonstration',
      ],
      exclusions: ['Core cutting in exterior concrete', 'Duct pipe material'],
    ),
    // 9. Other Services
    const ServicePackage(
      id: 'other_general_inspection',
      category: ServiceCategory.other,
      titleEn: 'General Appliance Inspection & Diagnosis',
      titleMr: 'इतर उपकरण तपासणी व डायग्नोसिस',
      descriptionEn: 'Expert diagnosis and repair check for microwave, mixer, induction, air cooler, iron & other household appliances.',
      descriptionMr: 'मायक्रोव्हेव्ह, मिक्सर, इंडक्शन, कुलर, इस्त्री व इतर घरगुती उपकरणांची संपूर्ण तपासणी व डायग्नोसिस.',
      basePrice: 199,
      originalPrice: 299,
      durationMinutes: 45,
      rating: 4.86,
      reviewsCount: 165,
      warrantyDays: 30,
      inclusions: [
        'Complete fault diagnosis',
        'Transparent quote before repair',
        'Safety electrical leakage test',
      ],
      exclusions: ['Spare parts cost', 'Major rewinding if required'],
    ),
    const ServicePackage(
      id: 'other_custom_repair',
      category: ServiceCategory.other,
      titleEn: 'Custom Appliance Repair & Handyman Help',
      titleMr: 'कस्टम उपकरण दुरुस्ती व हॅन्डीमॅन सर्व्हिस',
      descriptionEn: 'On-demand technician assistance for unlisted appliances, minor household fixes, and custom repair quote.',
      descriptionMr: 'यादीत नसलेल्या उपकरणांची दुरुस्ती, किरकोळ जोडणी व कस्टम कोटेशन सेवा.',
      basePrice: 249,
      originalPrice: 399,
      durationMinutes: 60,
      rating: 4.88,
      reviewsCount: 120,
      warrantyDays: 30,
      inclusions: [
        'Dedicated doorstep technician visit',
        'Multi-appliance troubleshooting',
        '30-day service guarantee',
      ],
      exclusions: ['Materials and replacement spares'],
    ),
  ];
}
