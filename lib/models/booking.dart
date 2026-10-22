import 'appliance_service.dart';
import '../utils/translations.dart';

enum BookingStatus {
  pending, // Inquiry just placed, waiting assignment
  assigned, // Assigned to technician (auto or manual)
  onTheWay, // Technician clicked "निघाले (On the way)"
  inProgress, // Technician entered customer OTP and started work
  completed, // Work done, bill generated & paid
  cancelled,
}

extension BookingStatusExt on BookingStatus {
  String get nameEn {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending Approval';
      case BookingStatus.assigned:
        return 'Approved & Assigned';
      case BookingStatus.onTheWay:
        return 'Partner On The Way';
      case BookingStatus.inProgress:
        return 'Work In Progress';
      case BookingStatus.completed:
        return 'Service Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get nameMr {
    switch (this) {
      case BookingStatus.pending:
        return 'मंजुरी प्रलंबित';
      case BookingStatus.assigned:
        return 'मंजूर (काम सोपवले)';
      case BookingStatus.onTheWay:
        return 'कामगार निघत आहे';
      case BookingStatus.inProgress:
        return 'काम चालू आहे';
      case BookingStatus.completed:
        return 'काम पूर्ण झाले';
      case BookingStatus.cancelled:
        return 'रद्द केले';
    }
  }

  String get nameHi {
    switch (this) {
      case BookingStatus.pending:
        return 'मंजूरी लंबित';
      case BookingStatus.assigned:
        return 'स्वीकृत (पार्टनर असाइन)';
      case BookingStatus.onTheWay:
        return 'पार्टनर रास्ते में है';
      case BookingStatus.inProgress:
        return 'काम प्रगति पर है';
      case BookingStatus.completed:
        return 'काम पूरा हुआ';
      case BookingStatus.cancelled:
        return 'रद्द किया गया';
    }
  }

  String get nameKn {
    switch (this) {
      case BookingStatus.pending:
        return 'ಅನುಮೋದನೆ ಬಾಕಿ ಇದೆ';
      case BookingStatus.assigned:
        return 'ಅನುಮೋದಿಸಲಾಗಿದೆ (ಪಾಲುದಾರ ನಿಯೋಜಿತ)';
      case BookingStatus.onTheWay:
        return 'ಪಾಲುದಾರರು ಬರುತ್ತಿದ್ದಾರೆ';
      case BookingStatus.inProgress:
        return 'ಕೆಲಸ ಪ್ರಗತಿಯಲ್ಲಿದೆ';
      case BookingStatus.completed:
        return 'ಸೇವೆ ಪೂರ್ಣಗೊಂಡಿದೆ';
      case BookingStatus.cancelled:
        return 'ರದ್ದುಗೊಳಿಸಲಾಗಿದೆ';
    }
  }

  String get nameGu {
    switch (this) {
      case BookingStatus.pending:
        return 'મંજૂરી બાકી';
      case BookingStatus.assigned:
        return 'સ્વીકારેલ (પાર્ટનર સોંપેલ)';
      case BookingStatus.onTheWay:
        return 'પાર્ટનર રસ્તામાં છે';
      case BookingStatus.inProgress:
        return 'કામ ચાલુ છે';
      case BookingStatus.completed:
        return 'કામ પૂર્ણ થયું';
      case BookingStatus.cancelled:
        return 'રદ કરેલ';
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
}

enum PaymentMethod { upiOnline, cashOnDelivery }

class Booking {
  final String id;
  final String? customerId;
  final String customerName;
  final String customerPhone;
  final String address;
  final String landmark;
  final double latitude;
  final double longitude;
  final ServicePackage service;
  final DateTime scheduledDate;
  final String scheduledSlot;
  final BookingStatus status;
  final String? technicianId;
  final String? technicianName;
  final String? technicianPhone;
  final String startOtp;
  final double laborCost;
  final double sparePartsCost;
  final List<String> sparePartsAdded;
  final double totalAmount;
  final bool isPaid;
  final PaymentMethod paymentMethod;
  final String notes;
  final DateTime createdAt;
  final String? brand;
  final String? machineType;
  final String? problem;
  final String? selectedPart;
  final bool isSpecialization;

  const Booking({
    required this.id,
    this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.landmark,
    required this.latitude,
    required this.longitude,
    required this.service,
    required this.scheduledDate,
    required this.scheduledSlot,
    this.status = BookingStatus.pending,
    this.technicianId,
    this.technicianName,
    this.technicianPhone,
    required this.startOtp,
    required this.laborCost,
    this.sparePartsCost = 0.0,
    this.sparePartsAdded = const [],
    required this.totalAmount,
    this.isPaid = false,
    this.paymentMethod = PaymentMethod.cashOnDelivery,
    this.notes = '',
    required this.createdAt,
    this.brand,
    this.machineType,
    this.problem,
    this.selectedPart,
    this.isSpecialization = false,
  });

  Booking copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? address,
    String? landmark,
    double? latitude,
    double? longitude,
    ServicePackage? service,
    DateTime? scheduledDate,
    String? scheduledSlot,
    BookingStatus? status,
    String? technicianId,
    String? technicianName,
    String? technicianPhone,
    String? startOtp,
    double? laborCost,
    double? sparePartsCost,
    List<String>? sparePartsAdded,
    double? totalAmount,
    bool? isPaid,
    PaymentMethod? paymentMethod,
    String? notes,
    DateTime? createdAt,
    String? brand,
    String? machineType,
    String? problem,
    String? selectedPart,
    bool? isSpecialization,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      service: service ?? this.service,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledSlot: scheduledSlot ?? this.scheduledSlot,
      status: status ?? this.status,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      technicianPhone: technicianPhone ?? this.technicianPhone,
      startOtp: startOtp ?? this.startOtp,
      laborCost: laborCost ?? this.laborCost,
      sparePartsCost: sparePartsCost ?? this.sparePartsCost,
      sparePartsAdded: sparePartsAdded ?? this.sparePartsAdded,
      totalAmount: totalAmount ?? this.totalAmount,
      isPaid: isPaid ?? this.isPaid,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      brand: brand ?? this.brand,
      machineType: machineType ?? this.machineType,
      problem: problem ?? this.problem,
      selectedPart: selectedPart ?? this.selectedPart,
      isSpecialization: isSpecialization ?? this.isSpecialization,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'address': address,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
      'service': service.toJson(),
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledSlot': scheduledSlot,
      'status': status.name,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'technicianPhone': technicianPhone,
      'startOtp': startOtp,
      'laborCost': laborCost,
      'sparePartsCost': sparePartsCost,
      'sparePartsAdded': sparePartsAdded,
      'totalAmount': totalAmount,
      'isPaid': isPaid,
      'paymentMethod': paymentMethod.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'brand': brand,
      'machineType': machineType,
      'problem': problem,
      'selectedPart': selectedPart,
      'isSpecialization': isSpecialization,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    BookingStatus st = BookingStatus.pending;
    for (var s in BookingStatus.values) {
      if (s.name == json['status']) {
        st = s;
        break;
      }
    }
    PaymentMethod pm = PaymentMethod.cashOnDelivery;
    for (var p in PaymentMethod.values) {
      if (p.name == json['paymentMethod']) {
        pm = p;
        break;
      }
    }
    return Booking(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      landmark: json['landmark'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 16.8524,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 74.5815,
      service: ServicePackage.fromJson(
        Map<String, dynamic>.from(json['service'] as Map),
      ),
      scheduledDate: DateTime.tryParse(json['scheduledDate'] as String? ?? '') ??
          DateTime.now(),
      scheduledSlot: json['scheduledSlot'] as String? ?? '10:00 AM - 12:00 PM',
      status: st,
      technicianId: json['technicianId'] as String?,
      technicianName: json['technicianName'] as String?,
      technicianPhone: json['technicianPhone'] as String?,
      startOtp: json['startOtp'] as String? ?? '1234',
      laborCost: (json['laborCost'] as num?)?.toDouble() ?? 0.0,
      sparePartsCost: (json['sparePartsCost'] as num?)?.toDouble() ?? 0.0,
      sparePartsAdded: (json['sparePartsAdded'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      isPaid: json['isPaid'] as bool? ?? false,
      paymentMethod: pm,
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      brand: json['brand'] as String?,
      machineType: json['machineType'] as String?,
      problem: json['problem'] as String?,
      selectedPart: json['selectedPart'] as String?,
      isSpecialization: json['isSpecialization'] as bool? ?? false,
    );
  }
}

class MockBookingsData {
  static List<Booking> getInitialBookings() {
    return [];
  }
}
