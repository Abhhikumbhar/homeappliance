import '../utils/translations.dart';

enum RenewalStatus { dueThisWeek, dueThisMonth, overdue, renewed }

extension RenewalStatusExt on RenewalStatus {
  String get labelEn {
    switch (this) {
      case RenewalStatus.dueThisWeek:
        return 'Due This Week';
      case RenewalStatus.dueThisMonth:
        return 'Due This Month';
      case RenewalStatus.overdue:
        return 'Overdue';
      case RenewalStatus.renewed:
        return 'Active & Renewed';
    }
  }

  String get labelMr {
    switch (this) {
      case RenewalStatus.dueThisWeek:
        return 'या आठवड्यात मुदत';
      case RenewalStatus.dueThisMonth:
        return 'या महिन्यात मुदत';
      case RenewalStatus.overdue:
        return 'मुदत संपली';
      case RenewalStatus.renewed:
        return 'सक्रिय / रिन्यू झाले';
    }
  }

  String get labelHi {
    switch (this) {
      case RenewalStatus.dueThisWeek:
        return 'इस सप्ताह देय';
      case RenewalStatus.dueThisMonth:
        return 'इस महीने देय';
      case RenewalStatus.overdue:
        return 'समय सीमा समाप्त';
      case RenewalStatus.renewed:
        return 'सक्रिय / नवीनीकृत';
    }
  }

  String get labelKn {
    switch (this) {
      case RenewalStatus.dueThisWeek:
        return 'ಈ ವಾರ ಬಾಕಿ';
      case RenewalStatus.dueThisMonth:
        return 'ಈ ತಿಂಗಳು ಬಾಕಿ';
      case RenewalStatus.overdue:
        return 'ಅವಧಿ ಮೀರಿದೆ';
      case RenewalStatus.renewed:
        return 'ಸಕ್ರಿಯ / ನವೀಕರಿಸಲಾಗಿದೆ';
    }
  }

  String get labelGu {
    switch (this) {
      case RenewalStatus.dueThisWeek:
        return 'આ અઠવાડિયે મુદત';
      case RenewalStatus.dueThisMonth:
        return 'આ મહિને મુદત';
      case RenewalStatus.overdue:
        return 'મુદત વીતી ગઈ';
      case RenewalStatus.renewed:
        return 'સક્રિય / રિન્યૂ કરેલ';
    }
  }

  String localizedLabel(dynamic langOrIsMr) {
    if (langOrIsMr is bool) {
      return langOrIsMr ? labelMr : labelEn;
    }
    if (langOrIsMr is AppLanguage) {
      switch (langOrIsMr) {
        case AppLanguage.marathi:
          return labelMr;
        case AppLanguage.english:
          return labelEn;
        case AppLanguage.hindi:
          return labelHi;
        case AppLanguage.kannada:
          return labelKn;
        case AppLanguage.gujarati:
          return labelGu;
      }
    }
    return labelMr;
  }
}

class AmcEquipmentItem {
  final String applianceName;
  final String brandModel;
  final String serialNo;
  final int quantity;
  final String location;

  const AmcEquipmentItem({
    required this.applianceName,
    required this.brandModel,
    this.serialNo = '',
    this.quantity = 1,
    this.location = '',
  });

  Map<String, dynamic> toJson() => {
        'applianceName': applianceName,
        'brandModel': brandModel,
        'serialNo': serialNo,
        'quantity': quantity,
        'location': location,
      };

  factory AmcEquipmentItem.fromJson(Map<String, dynamic> json) =>
      AmcEquipmentItem(
        applianceName: json['applianceName'] as String? ?? '',
        brandModel: json['brandModel'] as String? ?? '',
        serialNo: json['serialNo'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        location: json['location'] as String? ?? '',
      );
}

class AmcChecklistItem {
  final String checkPoint;
  final String status;
  final String remarks;

  const AmcChecklistItem({
    required this.checkPoint,
    this.status = 'OK',
    this.remarks = '',
  });

  Map<String, dynamic> toJson() => {
        'checkPoint': checkPoint,
        'status': status,
        'remarks': remarks,
      };

  factory AmcChecklistItem.fromJson(Map<String, dynamic> json) =>
      AmcChecklistItem(
        checkPoint: json['checkPoint'] as String? ?? '',
        status: json['status'] as String? ?? 'OK',
        remarks: json['remarks'] as String? ?? '',
      );
}

class AmcRenewal {
  final String id;
  final String? customerId;
  final String? contractNo;
  final String customerName;
  final String customerPhone;
  final String applianceName;
  final String brandModel;
  final DateTime lastServiceDate;
  final DateTime nextDueDate;
  final String planName;
  final double planPrice;
  final String? frequency;
  final RenewalStatus status;
  final String address;
  final List<AmcEquipmentItem>? equipmentList;
  final List<AmcChecklistItem>? checklist;

  const AmcRenewal({
    required this.id,
    this.customerId,
    this.contractNo,
    required this.customerName,
    required this.customerPhone,
    required this.applianceName,
    required this.brandModel,
    required this.lastServiceDate,
    required this.nextDueDate,
    required this.planName,
    required this.planPrice,
    this.frequency,
    required this.status,
    required this.address,
    this.equipmentList,
    this.checklist,
  });

  int get daysRemaining {
    final now = DateTime.now();
    return nextDueDate.difference(now).inDays;
  }

  AmcRenewal copyWith({
    String? id,
    String? customerId,
    String? contractNo,
    String? customerName,
    String? customerPhone,
    String? applianceName,
    String? brandModel,
    DateTime? lastServiceDate,
    DateTime? nextDueDate,
    String? planName,
    double? planPrice,
    String? frequency,
    RenewalStatus? status,
    String? address,
    List<AmcEquipmentItem>? equipmentList,
    List<AmcChecklistItem>? checklist,
  }) {
    return AmcRenewal(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      contractNo: contractNo ?? this.contractNo,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      applianceName: applianceName ?? this.applianceName,
      brandModel: brandModel ?? this.brandModel,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      planName: planName ?? this.planName,
      planPrice: planPrice ?? this.planPrice,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      address: address ?? this.address,
      equipmentList: equipmentList ?? this.equipmentList,
      checklist: checklist ?? this.checklist,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'contractNo': contractNo,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'applianceName': applianceName,
      'brandModel': brandModel,
      'lastServiceDate': lastServiceDate.toIso8601String(),
      'nextDueDate': nextDueDate.toIso8601String(),
      'planName': planName,
      'planPrice': planPrice,
      'frequency': frequency,
      'status': status.name,
      'address': address,
      'equipmentList': equipmentList?.map((e) => e.toJson()).toList(),
      'checklist': checklist?.map((c) => c.toJson()).toList(),
    };
  }

  factory AmcRenewal.fromJson(Map<String, dynamic> json) {
    RenewalStatus st = RenewalStatus.dueThisMonth;
    for (var s in RenewalStatus.values) {
      if (s.name == json['status']) {
        st = s;
        break;
      }
    }
    return AmcRenewal(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String?,
      contractNo: json['contractNo'] as String?,
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      applianceName: json['applianceName'] as String? ?? '',
      brandModel: json['brandModel'] as String? ?? '',
      lastServiceDate: DateTime.tryParse(json['lastServiceDate'] as String? ?? '') ??
          DateTime.now(),
      nextDueDate: DateTime.tryParse(json['nextDueDate'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
      planName: json['planName'] as String? ?? '',
      planPrice: (json['planPrice'] as num?)?.toDouble() ?? 0.0,
      frequency: json['frequency'] as String?,
      status: st,
      address: json['address'] as String? ?? '',
      equipmentList: (json['equipmentList'] as List<dynamic>?)
          ?.map((e) => AmcEquipmentItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      checklist: (json['checklist'] as List<dynamic>?)
          ?.map((c) => AmcChecklistItem.fromJson(Map<String, dynamic>.from(c as Map)))
          .toList(),
    );
  }
}

class MockRenewalsData {
  static List<AmcRenewal> getInitialRenewals() {
    return [];
  }
}
