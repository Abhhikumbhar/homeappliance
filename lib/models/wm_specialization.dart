import 'package:flutter/material.dart';
import '../utils/translations.dart';

/// Supported Washing Machine Types
class MachineTypeConstants {
  static const String frontLoad = 'Front Load';
  static const String topLoad = 'Top Load';
  static const String semiAutomatic = 'Semi-Automatic';

  static const List<String> all = [frontLoad, topLoad, semiAutomatic];

  static String localizedName(String type, [dynamic langOrIsMr]) {
    final lang = (langOrIsMr is AppLanguage)
        ? langOrIsMr
        : AppTranslations.currentLang;
    switch (type) {
      case frontLoad:
        return AppTranslations.trText('फ्रंट लोड', 'Front Load', lang);
      case topLoad:
        return AppTranslations.trText('टॉप लोड', 'Top Load', lang);
      case semiAutomatic:
        return AppTranslations.trText('सेमी-ऑटोमॅटिक', 'Semi-Automatic', lang);
      default:
        return type;
    }
  }

  static IconData getIcon(String type) {
    switch (type) {
      case frontLoad:
        return Icons.local_laundry_service_rounded;
      case topLoad:
        return Icons.microwave_rounded;
      case semiAutomatic:
        return Icons.settings_backup_restore_rounded;
      default:
        return Icons.local_laundry_service_outlined;
    }
  }
}

/// Supported Washing Machine Brand Model
class WashingMachineBrand {
  final String id;
  final String name;
  final bool isActive;
  final List<String> supportedMachineTypes;
  final List<String> supportedParts;
  final double inspectionFee;
  final String accentColorHex;

  const WashingMachineBrand({
    required this.id,
    required this.name,
    this.isActive = true,
    this.supportedMachineTypes = const [
      MachineTypeConstants.frontLoad,
      MachineTypeConstants.topLoad,
      MachineTypeConstants.semiAutomatic,
    ],
    this.supportedParts = const [],
    this.inspectionFee = 249.0,
    this.accentColorHex = '#0047BA',
  });

  Color get accentColor {
    try {
      final hex = accentColorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF0047BA);
    }
  }

  WashingMachineBrand copyWith({
    String? id,
    String? name,
    bool? isActive,
    List<String>? supportedMachineTypes,
    List<String>? supportedParts,
    double? inspectionFee,
    String? accentColorHex,
  }) {
    return WashingMachineBrand(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      supportedMachineTypes:
          supportedMachineTypes ?? this.supportedMachineTypes,
      supportedParts: supportedParts ?? this.supportedParts,
      inspectionFee: inspectionFee ?? this.inspectionFee,
      accentColorHex: accentColorHex ?? this.accentColorHex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'supportedMachineTypes': supportedMachineTypes,
      'supportedParts': supportedParts,
      'inspectionFee': inspectionFee,
      'accentColorHex': accentColorHex,
    };
  }

  factory WashingMachineBrand.fromJson(Map<String, dynamic> json) {
    return WashingMachineBrand(
      id: json['id'] as String? ?? 'brand_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      supportedMachineTypes: (json['supportedMachineTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          MachineTypeConstants.all,
      supportedParts: (json['supportedParts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      inspectionFee: (json['inspectionFee'] as num?)?.toDouble() ?? 249.0,
      accentColorHex: json['accentColorHex'] as String? ?? '#0047BA',
    );
  }
}

/// Specialization Service Model (PCB, Inverter, Front Load)
class WashingMachineSpecializationService {
  final String id;
  final String titleEn;
  final String titleMr;
  final String subtitleEn;
  final String subtitleMr;
  final String descriptionEn;
  final String descriptionMr;
  final String badgeEn;
  final String badgeMr;
  final double basePrice;
  final double inspectionFee;
  final int warrantyDays;
  final List<String> compatibleMachineTypes;
  final List<String> compatibleParts;
  final bool isActive;
  final IconData icon;

  const WashingMachineSpecializationService({
    required this.id,
    required this.titleEn,
    required this.titleMr,
    required this.subtitleEn,
    required this.subtitleMr,
    required this.descriptionEn,
    required this.descriptionMr,
    required this.badgeEn,
    required this.badgeMr,
    required this.basePrice,
    this.inspectionFee = 249.0,
    this.warrantyDays = 90,
    required this.compatibleMachineTypes,
    required this.compatibleParts,
    this.isActive = true,
    this.icon = Icons.precision_manufacturing_rounded,
  });

  String localizedTitle([dynamic langOrIsMr]) {
    final lang = (langOrIsMr is AppLanguage)
        ? langOrIsMr
        : AppTranslations.currentLang;
    return AppTranslations.trText(titleMr, titleEn, lang);
  }

  String localizedSubtitle([dynamic langOrIsMr]) {
    final lang = (langOrIsMr is AppLanguage)
        ? langOrIsMr
        : AppTranslations.currentLang;
    return AppTranslations.trText(subtitleMr, subtitleEn, lang);
  }

  String localizedDescription([dynamic langOrIsMr]) {
    final lang = (langOrIsMr is AppLanguage)
        ? langOrIsMr
        : AppTranslations.currentLang;
    return AppTranslations.trText(descriptionMr, descriptionEn, lang);
  }

  String localizedBadge([dynamic langOrIsMr]) {
    final lang = (langOrIsMr is AppLanguage)
        ? langOrIsMr
        : AppTranslations.currentLang;
    return AppTranslations.trText(badgeMr, badgeEn, lang);
  }

  WashingMachineSpecializationService copyWith({
    String? id,
    String? titleEn,
    String? titleMr,
    String? subtitleEn,
    String? subtitleMr,
    String? descriptionEn,
    String? descriptionMr,
    String? badgeEn,
    String? badgeMr,
    double? basePrice,
    double? inspectionFee,
    int? warrantyDays,
    List<String>? compatibleMachineTypes,
    List<String>? compatibleParts,
    bool? isActive,
    IconData? icon,
  }) {
    return WashingMachineSpecializationService(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleMr: titleMr ?? this.titleMr,
      subtitleEn: subtitleEn ?? this.subtitleEn,
      subtitleMr: subtitleMr ?? this.subtitleMr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionMr: descriptionMr ?? this.descriptionMr,
      badgeEn: badgeEn ?? this.badgeEn,
      badgeMr: badgeMr ?? this.badgeMr,
      basePrice: basePrice ?? this.basePrice,
      inspectionFee: inspectionFee ?? this.inspectionFee,
      warrantyDays: warrantyDays ?? this.warrantyDays,
      compatibleMachineTypes:
          compatibleMachineTypes ?? this.compatibleMachineTypes,
      compatibleParts: compatibleParts ?? this.compatibleParts,
      isActive: isActive ?? this.isActive,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleEn': titleEn,
      'titleMr': titleMr,
      'subtitleEn': subtitleEn,
      'subtitleMr': subtitleMr,
      'descriptionEn': descriptionEn,
      'descriptionMr': descriptionMr,
      'badgeEn': badgeEn,
      'badgeMr': badgeMr,
      'basePrice': basePrice,
      'inspectionFee': inspectionFee,
      'warrantyDays': warrantyDays,
      'compatibleMachineTypes': compatibleMachineTypes,
      'compatibleParts': compatibleParts,
      'isActive': isActive,
    };
  }

  factory WashingMachineSpecializationService.fromJson(
      Map<String, dynamic> json) {
    IconData iconData = Icons.precision_manufacturing_rounded;
    final sid = json['id'] as String? ?? '';
    if (sid.contains('pcb')) {
      iconData = Icons.developer_board_rounded;
    } else if (sid.contains('inverter')) {
      iconData = Icons.electric_bolt_rounded;
    } else if (sid.contains('frontload')) {
      iconData = Icons.local_laundry_service_rounded;
    }

    return WashingMachineSpecializationService(
      id: sid,
      titleEn: json['titleEn'] as String? ?? '',
      titleMr: json['titleMr'] as String? ?? '',
      subtitleEn: json['subtitleEn'] as String? ?? '',
      subtitleMr: json['subtitleMr'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      descriptionMr: json['descriptionMr'] as String? ?? '',
      badgeEn: json['badgeEn'] as String? ?? 'Specialist',
      badgeMr: json['badgeMr'] as String? ?? 'स्पेशालिस्ट',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 599.0,
      inspectionFee: (json['inspectionFee'] as num?)?.toDouble() ?? 249.0,
      warrantyDays: (json['warrantyDays'] as num?)?.toInt() ?? 90,
      compatibleMachineTypes: (json['compatibleMachineTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          MachineTypeConstants.all,
      compatibleParts: (json['compatibleParts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isActive: json['isActive'] as bool? ?? true,
      icon: iconData,
    );
  }
}

/// Washing Machine Problem / Part Model
class WashingMachinePart {
  final String id;
  final String nameEn;
  final String nameMr;
  final String descriptionEn;
  final String descriptionMr;
  final List<String> applicableServices;
  final List<String> applicableMachineTypes;
  final double estimatedMinPrice;
  final double estimatedMaxPrice;
  final bool isActive;
  final IconData icon;

  const WashingMachinePart({
    required this.id,
    required this.nameEn,
    required this.nameMr,
    this.descriptionEn = '',
    this.descriptionMr = '',
    required this.applicableServices,
    required this.applicableMachineTypes,
    this.estimatedMinPrice = 350.0,
    this.estimatedMaxPrice = 2800.0,
    this.isActive = true,
    this.icon = Icons.settings_rounded,
  });

  String localizedName([dynamic langOrIsMr]) {
    final lang = (langOrIsMr is AppLanguage)
        ? langOrIsMr
        : AppTranslations.currentLang;
    return AppTranslations.trText(nameMr, nameEn, lang);
  }

  String localizedDescription([dynamic langOrIsMr]) {
    final lang = (langOrIsMr is AppLanguage)
        ? langOrIsMr
        : AppTranslations.currentLang;
    return AppTranslations.trText(descriptionMr, descriptionEn, lang);
  }

  WashingMachinePart copyWith({
    String? id,
    String? nameEn,
    String? nameMr,
    String? descriptionEn,
    String? descriptionMr,
    List<String>? applicableServices,
    List<String>? applicableMachineTypes,
    double? estimatedMinPrice,
    double? estimatedMaxPrice,
    bool? isActive,
    IconData? icon,
  }) {
    return WashingMachinePart(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameMr: nameMr ?? this.nameMr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionMr: descriptionMr ?? this.descriptionMr,
      applicableServices: applicableServices ?? this.applicableServices,
      applicableMachineTypes:
          applicableMachineTypes ?? this.applicableMachineTypes,
      estimatedMinPrice: estimatedMinPrice ?? this.estimatedMinPrice,
      estimatedMaxPrice: estimatedMaxPrice ?? this.estimatedMaxPrice,
      isActive: isActive ?? this.isActive,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameEn': nameEn,
      'nameMr': nameMr,
      'descriptionEn': descriptionEn,
      'descriptionMr': descriptionMr,
      'applicableServices': applicableServices,
      'applicableMachineTypes': applicableMachineTypes,
      'estimatedMinPrice': estimatedMinPrice,
      'estimatedMaxPrice': estimatedMaxPrice,
      'isActive': isActive,
    };
  }

  factory WashingMachinePart.fromJson(Map<String, dynamic> json) {
    IconData icon = Icons.build_circle_rounded;
    final pid = json['id'] as String? ?? '';
    if (pid.contains('pcb') || pid.contains('board')) {
      icon = Icons.memory_rounded;
    } else if (pid.contains('motor')) {
      icon = Icons.motion_photos_on_rounded;
    } else if (pid.contains('drain') || pid.contains('pump')) {
      icon = Icons.water_damage_rounded;
    } else if (pid.contains('door') || pid.contains('lock')) {
      icon = Icons.lock_outline_rounded;
    } else if (pid.contains('valve')) {
      icon = Icons.water_drop_rounded;
    } else if (pid.contains('drum')) {
      icon = Icons.donut_large_rounded;
    } else if (pid.contains('error')) {
      icon = Icons.warning_amber_rounded;
    }

    return WashingMachinePart(
      id: pid,
      nameEn: json['nameEn'] as String? ?? '',
      nameMr: json['nameMr'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      descriptionMr: json['descriptionMr'] as String? ?? '',
      applicableServices: (json['applicableServices'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      applicableMachineTypes: (json['applicableMachineTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          MachineTypeConstants.all,
      estimatedMinPrice:
          (json['estimatedMinPrice'] as num?)?.toDouble() ?? 350.0,
      estimatedMaxPrice:
          (json['estimatedMaxPrice'] as num?)?.toDouble() ?? 2800.0,
      isActive: json['isActive'] as bool? ?? true,
      icon: icon,
    );
  }
}

/// Washing Machine Specialization Global Configuration
class WashingMachineSpecializationConfig {
  final bool isServiceAvailable;
  final bool emergencySameDayAvailable;
  final double standardInspectionFee;
  final List<String> serviceCoverageCities;
  final List<WashingMachineBrand> brands;
  final List<WashingMachineSpecializationService> services;
  final List<WashingMachinePart> parts;

  const WashingMachineSpecializationConfig({
    this.isServiceAvailable = true,
    this.emergencySameDayAvailable = true,
    this.standardInspectionFee = 249.0,
    this.serviceCoverageCities = const [
      'Pune',
      'Sangli',
      'Miraj',
      'Karad',
      'Kupwad',
      'Kolhapur',
      'Satara',
    ],
    required this.brands,
    required this.services,
    required this.parts,
  });

  List<WashingMachineBrand> get activeBrands =>
      brands.where((b) => b.isActive).toList();

  List<WashingMachineSpecializationService> get activeServices =>
      services.where((s) => s.isActive).toList();

  List<WashingMachinePart> get activeParts =>
      parts.where((p) => p.isActive).toList();

  WashingMachineSpecializationConfig copyWith({
    bool? isServiceAvailable,
    bool? emergencySameDayAvailable,
    double? standardInspectionFee,
    List<String>? serviceCoverageCities,
    List<WashingMachineBrand>? brands,
    List<WashingMachineSpecializationService>? services,
    List<WashingMachinePart>? parts,
  }) {
    return WashingMachineSpecializationConfig(
      isServiceAvailable: isServiceAvailable ?? this.isServiceAvailable,
      emergencySameDayAvailable:
          emergencySameDayAvailable ?? this.emergencySameDayAvailable,
      standardInspectionFee:
          standardInspectionFee ?? this.standardInspectionFee,
      serviceCoverageCities:
          serviceCoverageCities ?? this.serviceCoverageCities,
      brands: brands ?? this.brands,
      services: services ?? this.services,
      parts: parts ?? this.parts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isServiceAvailable': isServiceAvailable,
      'emergencySameDayAvailable': emergencySameDayAvailable,
      'standardInspectionFee': standardInspectionFee,
      'serviceCoverageCities': serviceCoverageCities,
      'brands': brands.map((b) => b.toJson()).toList(),
      'services': services.map((s) => s.toJson()).toList(),
      'parts': parts.map((p) => p.toJson()).toList(),
    };
  }

  factory WashingMachineSpecializationConfig.fromJson(
      Map<String, dynamic> json) {
    return WashingMachineSpecializationConfig(
      isServiceAvailable: json['isServiceAvailable'] as bool? ?? true,
      emergencySameDayAvailable:
          json['emergencySameDayAvailable'] as bool? ?? true,
      standardInspectionFee:
          (json['standardInspectionFee'] as num?)?.toDouble() ?? 249.0,
      serviceCoverageCities: (json['serviceCoverageCities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Pune', 'Sangli', 'Miraj', 'Karad', 'Kolhapur'],
      brands: (json['brands'] as List<dynamic>?)
              ?.map((e) =>
                  WashingMachineBrand.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          defaultBrands,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => WashingMachineSpecializationService.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList() ??
          defaultServices,
      parts: (json['parts'] as List<dynamic>?)
              ?.map((e) =>
                  WashingMachinePart.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          defaultParts,
    );
  }

  // Pre-configured default brands as specified in requirement 2
  static final List<WashingMachineBrand> defaultBrands = [
    const WashingMachineBrand(
      id: 'brand_samsung',
      name: 'Samsung',
      isActive: true,
      inspectionFee: 249.0,
      accentColorHex: '#034EA2',
      supportedMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
        MachineTypeConstants.semiAutomatic,
      ],
    ),
    const WashingMachineBrand(
      id: 'brand_lg',
      name: 'LG',
      isActive: true,
      inspectionFee: 249.0,
      accentColorHex: '#A50034',
      supportedMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
        MachineTypeConstants.semiAutomatic,
      ],
    ),
    const WashingMachineBrand(
      id: 'brand_ifb',
      name: 'IFB',
      isActive: true,
      inspectionFee: 299.0,
      accentColorHex: '#E31B23',
      supportedMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
      ],
    ),
    const WashingMachineBrand(
      id: 'brand_haier',
      name: 'Haier',
      isActive: true,
      inspectionFee: 249.0,
      accentColorHex: '#005AAA',
      supportedMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
        MachineTypeConstants.semiAutomatic,
      ],
    ),
    const WashingMachineBrand(
      id: 'brand_whirlpool',
      name: 'Whirlpool',
      isActive: true,
      inspectionFee: 249.0,
      accentColorHex: '#FFB800',
      supportedMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
        MachineTypeConstants.semiAutomatic,
      ],
    ),
    const WashingMachineBrand(
      id: 'brand_bosch',
      name: 'Bosch',
      isActive: true,
      inspectionFee: 299.0,
      accentColorHex: '#EA1D25',
      supportedMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
      ],
    ),
  ];

  // Pre-configured 3 professional specialization service cards as specified in requirement 1
  static final List<WashingMachineSpecializationService> defaultServices = [
    const WashingMachineSpecializationService(
      id: 'wm_spec_pcb',
      titleEn: 'PCB Board Repair & Replacement',
      titleMr: 'पीसीबी बोर्ड दुरुस्ती व बदलणे',
      subtitleEn: 'Expert PCB Board, Inverter & Front Load Repair Services',
      subtitleMr: 'तज्ज्ञ पीसीबी मायक्रो सोल्डरिंग व सर्किट बोर्ड दुरुस्ती',
      descriptionEn:
          'Component-level micro soldering, IC reprogramming, power supply & display troubleshooting with original test fixtures.',
      descriptionMr:
          'मायक्रो कंपोनंट सोल्डरिंग, आयसी रिप्रोग्रामिंग, डिस्प्ले एरर आणि पॉवर सर्किटची १००% खात्रीशीर दुरुस्ती.',
      badgeEn: 'Micro Soldering Lab',
      badgeMr: 'मायक्रो लॅब टेस्टेड',
      basePrice: 899.0,
      inspectionFee: 249.0,
      warrantyDays: 90,
      compatibleMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
        MachineTypeConstants.semiAutomatic,
      ],
      compatibleParts: [
        'part_pcb_board',
        'part_inverter_pcb',
        'part_error_code',
      ],
      icon: Icons.developer_board_rounded,
    ),
    const WashingMachineSpecializationService(
      id: 'wm_spec_inverter',
      titleEn: 'Inverter Motor & Inverter PCB Repair',
      titleMr: 'इन्व्हर्टर मोटर व इन्व्हर्टर पीसीबी दुरुस्ती',
      subtitleEn: 'Expert PCB Board, Inverter & Front Load Repair Services',
      subtitleMr: 'बीएलडीसी डायरेक्ट ड्राईव्ह मोटर व इन्व्हर्टर आयपीएम मॉड्यूल',
      descriptionEn:
          'Direct Drive / BLDC motor diagnosis, inverter controller board repair & variable frequency drive fixes.',
      descriptionMr:
          'डायरेक्ट ड्राईव्ह / बीएलडीसी मोटर टेस्ट, इन्व्हर्टर आयपीएम ड्राइव्ह कार्ड दुरुस्ती व मोटर व्हायब्रेशन सोल्यूशन.',
      badgeEn: 'Direct Drive Specialist',
      badgeMr: 'डायरेक्ट ड्राईव्ह तज्ज्ञ',
      basePrice: 1199.0,
      inspectionFee: 249.0,
      warrantyDays: 90,
      compatibleMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
      ],
      compatibleParts: [
        'part_inverter_pcb',
        'part_inverter_motor',
        'part_pcb_board',
        'part_error_code',
      ],
      icon: Icons.electric_bolt_rounded,
    ),
    const WashingMachineSpecializationService(
      id: 'wm_spec_frontload',
      titleEn: 'Front Load Washing Machine Repair',
      titleMr: 'फ्रंट लोड वॉशिंग मशीन स्पेशलिस्ट दुरुस्ती',
      subtitleEn: 'Expert PCB Board, Inverter & Front Load Repair Services',
      subtitleMr: 'ड्रम बेअरिंग, स्पायडर आर्म, रबर डोअर गास्केट व लीकेज दुरुस्ती',
      descriptionEn:
          'Precision drum bearing replacement, door boot seal gasket, spider arm repair & anti-vibration high-speed balancing.',
      descriptionMr:
          'ओरिजिनल ड्रम बेअरिंग बदलणे, स्पायडर आर्म रिपेअर, डोअर रबर गास्केट बदल व स्पिनिंग आवाज १००% निवारण.',
      badgeEn: 'Drum & Seal Shield',
      badgeMr: 'ड्रम व सील शील्ड',
      basePrice: 699.0,
      inspectionFee: 249.0,
      warrantyDays: 90,
      compatibleMachineTypes: [
        MachineTypeConstants.frontLoad,
      ],
      compatibleParts: [
        'part_door_lock',
        'part_drum_problems',
        'part_drain_pump',
        'part_water_inlet_valve',
        'part_pcb_board',
        'part_error_code',
      ],
      icon: Icons.local_laundry_service_rounded,
    ),
  ];

  // Pre-configured parts & problems as specified in requirement 4
  static final List<WashingMachinePart> defaultParts = [
    const WashingMachinePart(
      id: 'part_pcb_board',
      nameEn: 'PCB / Control Board',
      nameMr: 'पीसीबी / मेन कंट्रोल बोर्ड',
      descriptionEn: 'Microcontroller, power IC, display touch or relay burn-out issues.',
      descriptionMr: 'मायक्रोकंट्रोलर, पॉवर सप्लाय आयसी, डिस्प्ले टच किंवा रिले बिघाड.',
      applicableServices: ['wm_spec_pcb', 'wm_spec_inverter', 'wm_spec_frontload'],
      applicableMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
        MachineTypeConstants.semiAutomatic,
      ],
      estimatedMinPrice: 850.0,
      estimatedMaxPrice: 3200.0,
      icon: Icons.memory_rounded,
    ),
    const WashingMachinePart(
      id: 'part_inverter_pcb',
      nameEn: 'Inverter PCB',
      nameMr: 'इन्व्हर्टर पीसीबी कार्ड',
      descriptionEn: 'IPM power inverter board controlling brushless direct drive motor.',
      descriptionMr: 'बीएलडीसी मोटर नियंत्रित करणारे हाय-व्होल्टेज आयपीएम इन्व्हर्टर बोर्ड.',
      applicableServices: ['wm_spec_pcb', 'wm_spec_inverter'],
      applicableMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
      ],
      estimatedMinPrice: 1200.0,
      estimatedMaxPrice: 3800.0,
      icon: Icons.electric_meter_rounded,
    ),
    const WashingMachinePart(
      id: 'part_inverter_motor',
      nameEn: 'Inverter Motor',
      nameMr: 'इन्व्हर्टर मोटर (BLDC)',
      descriptionEn: 'BLDC / Direct drive motor hall sensor, stator winding or rotor issue.',
      descriptionMr: 'हॉल सेन्सॉर बिघाड, स्टेटर कॉइल शॉर्ट किंवा रोटर मॅग्नेट समस्या.',
      applicableServices: ['wm_spec_inverter'],
      applicableMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
      ],
      estimatedMinPrice: 950.0,
      estimatedMaxPrice: 3400.0,
      icon: Icons.motion_photos_on_rounded,
    ),
    const WashingMachinePart(
      id: 'part_drain_pump',
      nameEn: 'Drain Pump',
      nameMr: 'ड्रेन पंप व पाणी निचरा',
      descriptionEn: 'Water not draining out, pump motor jammed or filter clogged.',
      descriptionMr: 'पाणी बाहेर न फेकणे, ड्रेन मोटर जॅम होणे किंवा कॉईन फिल्टर अडकणे.',
      applicableServices: ['wm_spec_frontload'],
      applicableMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
        MachineTypeConstants.semiAutomatic,
      ],
      estimatedMinPrice: 450.0,
      estimatedMaxPrice: 1400.0,
      icon: Icons.water_damage_rounded,
    ),
    const WashingMachinePart(
      id: 'part_door_lock',
      nameEn: 'Door Lock',
      nameMr: 'डोअर लॉक (Interlock Switch)',
      descriptionEn: 'Door not closing/opening, dE error code or safety latch issue.',
      descriptionMr: 'दरवाजा लॉक न होणे, उघडता न येणे किंवा dE एरर कोड येणे.',
      applicableServices: ['wm_spec_frontload'],
      applicableMachineTypes: [
        MachineTypeConstants.frontLoad,
      ],
      estimatedMinPrice: 400.0,
      estimatedMaxPrice: 1100.0,
      icon: Icons.lock_outline_rounded,
    ),
    const WashingMachinePart(
      id: 'part_water_inlet_valve',
      nameEn: 'Water Inlet Valve',
      nameMr: 'वॉटर इनलेट व्हॉल्व्ह (सोलेनॉइड)',
      descriptionEn: 'Water not filling in machine, slow water flow or continuous filling.',
      descriptionMr: 'मशीनमध्ये पाणी न येणे, अतिशय संत गतीने पाणी भरणे किंवा न थांबणे.',
      applicableServices: ['wm_spec_frontload'],
      applicableMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
      ],
      estimatedMinPrice: 350.0,
      estimatedMaxPrice: 950.0,
      icon: Icons.water_drop_rounded,
    ),
    const WashingMachinePart(
      id: 'part_drum_problems',
      nameEn: 'Drum Problems',
      nameMr: 'ड्रम समस्या (बेअरिंग / स्पायडर)',
      descriptionEn: 'Excessive banging noise in spin mode, loose drum or black grease marks.',
      descriptionMr: 'स्पिनिंग वेळी मोठा आवाज, ड्रम थरथरणे किंवा कपड्यांवर ग्रीसचे डाग.',
      applicableServices: ['wm_spec_frontload'],
      applicableMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
      ],
      estimatedMinPrice: 750.0,
      estimatedMaxPrice: 2800.0,
      icon: Icons.donut_large_rounded,
    ),
    const WashingMachinePart(
      id: 'part_error_code',
      nameEn: 'Error Code / Other Issue',
      nameMr: 'एरर कोड / इतर समस्या',
      descriptionEn: 'Digital error code (4E, 5E, UE, LE, IE, OE, dE, etc.) or unknown fault.',
      descriptionMr: 'डिस्प्लेवर एरर कोड दिसणे (4E, UE, IE, dE, OE इत्यादी) किंवा असामान्य आवाज.',
      applicableServices: [
        'wm_spec_pcb',
        'wm_spec_inverter',
        'wm_spec_frontload'
      ],
      applicableMachineTypes: [
        MachineTypeConstants.frontLoad,
        MachineTypeConstants.topLoad,
        MachineTypeConstants.semiAutomatic,
      ],
      estimatedMinPrice: 249.0,
      estimatedMaxPrice: 1500.0,
      icon: Icons.warning_amber_rounded,
    ),
  ];

  static WashingMachineSpecializationConfig initial() {
    return WashingMachineSpecializationConfig(
      isServiceAvailable: true,
      emergencySameDayAvailable: true,
      standardInspectionFee: 249.0,
      brands: List.from(defaultBrands),
      services: List.from(defaultServices),
      parts: List.from(defaultParts),
    );
  }
}
