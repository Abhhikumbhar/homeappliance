import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/appliance_service.dart';
import '../models/technician.dart';
import '../models/booking.dart';
import '../models/amc_renewal.dart';
import '../models/user_account.dart';
import '../models/app_notification.dart';
import '../models/wm_specialization.dart';
import '../services/firebase_service.dart';
import '../utils/helpers.dart';
import '../utils/translations.dart';
export '../utils/translations.dart';
export '../models/wm_specialization.dart';

enum AppRole { customer, partner, admin }

enum DispatchMode { auto, manual }

class AppState extends ChangeNotifier {
  AppRole _currentRole = AppRole.customer;
  AppLanguage _currentLanguage = AppLanguage.marathi; // Default to Marathi as requested in client call!
  bool _isMarathi = true;
  DispatchMode _dispatchMode = DispatchMode.manual;

  late List<Booking> _bookings;
  late List<Technician> _technicians;
  late List<AmcRenewal> _renewals;
  late List<UserAccount> _users;
  late List<ServicePackage> _services;
  List<AppNotification> _notifications = [];
  UserAccount? _currentUser;
  String _activePartnerId = '';
  final Set<String> _sessionBookedIds = {};

  WashingMachineSpecializationConfig _wmSpecializationConfig =
      WashingMachineSpecializationConfig.initial();

  static const String _usersStorageKey = 'ha_registered_users_v1';
  static const String _sessionStorageKey = 'ha_active_session_v1';
  static const String _languageStorageKey = 'ha_selected_language_v1';
  static const String _languageCodeKey = 'ha_selected_language_code_v2';
  static const String _notificationsStorageKey = 'ha_notifications_v1';
  static const String _wmConfigStorageKey = 'ha_wm_specialization_config_v1';

  static final List<UserAccount> defaultSeedUsers = [
    // Super Admin account only
    const UserAccount(
      id: 'admin_01',
      name: 'Super Admin',
      email: 'admin@gmail.com',
      password: 'admin@123',
      phone: '9822000000',
      role: UserRole.admin,
    ),
  ];

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  Future<void>? _initFuture;

  AppState() {
    _services = List.from(MockServicesData.allServices);
    _technicians = List.from(MockTechniciansData.initialTechnicians);
    _bookings = MockBookingsData.getInitialBookings();
    _renewals = MockRenewalsData.getInitialRenewals();
    _users = List.from(defaultSeedUsers);
    _activePartnerId = '';
    _initFuture = _loadFromStorage();
  }

  Future<void> init() async {
    await (_initFuture ??= _loadFromStorage());
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJsonString = prefs.getString(_usersStorageKey);
      if (usersJsonString != null && usersJsonString.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(usersJsonString);
        for (var item in decodedList) {
          if (item is Map) {
            final account = UserAccount.fromJson(item);
            // Exclude any legacy dummy customer accounts or pre-seeded partner
            if (account.id == 'cust_raj' ||
                account.id == 'cust_default' ||
                account.id == 'user_tech_01' ||
                account.email.toLowerCase() == 'raj@gmail.com' ||
                account.email.toLowerCase() == 'partner@gmail.com' ||
                account.name.contains('सचिन') ||
                account.name.contains('Sachin')) {
              continue;
            }
            final exists = _users.any(
              (u) => u.email.toLowerCase() == account.email.toLowerCase(),
            );
            if (!exists) {
              _users.add(account);
            }
          }
        }
      }

      // Ensure admin@gmail.com always has the hardcoded credentials (admin@123)
      final adminIdx = _users.indexWhere(
        (u) => u.email.toLowerCase() == 'admin@gmail.com',
      );
      if (adminIdx != -1) {
        _users[adminIdx] = _users[adminIdx].copyWith(password: 'admin@123');
      } else {
        _users.add(defaultSeedUsers.first);
      }

      // Ensure no legacy Sachin Shinde remains in technicians list
      _technicians.removeWhere(
        (t) =>
            t.id == 'tech_01' ||
            t.email?.toLowerCase() == 'partner@gmail.com' ||
            t.name.contains('सचिन') ||
            t.name.contains('Sachin'),
      );

      final sessionEmail = prefs.getString(_sessionStorageKey);
      if (sessionEmail != null && sessionEmail.isNotEmpty) {
        final found = _users
            .where((u) => u.email.toLowerCase() == sessionEmail.toLowerCase())
            .firstOrNull;
        if (found != null) {
          _currentUser = found;
          if (_currentUser!.role == UserRole.partner &&
              _currentUser!.technicianId != null) {
            _activePartnerId = _currentUser!.technicianId!;
          }
        }
      }
      final savedCode = prefs.getString(_languageCodeKey);
      if (savedCode != null) {
        _currentLanguage = AppLanguage.fromCode(savedCode);
        _isMarathi = (_currentLanguage == AppLanguage.marathi);
      } else {
        final savedLanguage = prefs.getBool(_languageStorageKey);
        if (savedLanguage != null) {
          _isMarathi = savedLanguage;
          _currentLanguage = savedLanguage ? AppLanguage.marathi : AppLanguage.english;
        }
      }
      AppTranslations.setLanguage(_currentLanguage);

      final notifsJsonString = prefs.getString(_notificationsStorageKey);
      if (notifsJsonString != null && notifsJsonString.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(notifsJsonString);
        final list = <AppNotification>[];
        for (var item in decodedList) {
          if (item is Map) {
            try {
              list.add(AppNotification.fromJson(Map<String, dynamic>.from(item)));
            } catch (_) {}
          }
        }
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _notifications = list;
      }

      final wmConfigString = prefs.getString(_wmConfigStorageKey);
      if (wmConfigString != null && wmConfigString.isNotEmpty) {
        try {
          _wmSpecializationConfig = WashingMachineSpecializationConfig.fromJson(
            Map<String, dynamic>.from(jsonDecode(wmConfigString)),
          );
        } catch (e) {
          debugPrint('Error parsing wm config: $e');
        }
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved state: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> initFirebaseSync() async {
    try {
      // 1. Initialize Firebase Service (Firestore & Auth & RTDB)
      await FirebaseService.instance.initialize();
      await FirebaseService.instance.ensureAdminAccount();

      // Proactively ensure legacy Sachin Shinde is purged from Firebase
      unawaited(FirebaseService.instance.deleteTechnician('tech_01'));
      unawaited(FirebaseService.instance.deleteUser('user_tech_01'));

      await FirebaseService.instance.seedInitialDataIfEmpty(
        services: _services,
        technicians: _technicians,
        users: _users,
        bookings: _bookings,
        renewals: _renewals,
      );

      // 2. Fetch and merge users from Cloud Firestore
      final firebaseUsers = await FirebaseService.instance.fetchUsers();
      bool usersUpdated = false;
      for (var fUser in firebaseUsers) {
        if (fUser.id == 'user_tech_01' ||
            fUser.email.toLowerCase() == 'partner@gmail.com' ||
            fUser.name.contains('सचिन') ||
            fUser.name.contains('Sachin')) {
          unawaited(FirebaseService.instance.deleteUser(fUser.id));
          continue;
        }
        final idx = _users.indexWhere(
          (u) => u.email.toLowerCase() == fUser.email.toLowerCase(),
        );
        if (idx == -1) {
          _users.add(fUser);
          usersUpdated = true;
        } else {
          _users[idx] = fUser;
        }
      }
      if (usersUpdated) {
        await _saveUsersToStorage();
        if (_currentUser == null) {
          final prefs = await SharedPreferences.getInstance();
          final sessionEmail = prefs.getString(_sessionStorageKey);
          if (sessionEmail != null && sessionEmail.isNotEmpty) {
            final found = _users
                .where((u) => u.email.toLowerCase() == sessionEmail.toLowerCase())
                .firstOrNull;
            if (found != null) {
              _currentUser = found;
              if (_currentUser!.role == UserRole.partner &&
                  _currentUser!.technicianId != null) {
                _activePartnerId = _currentUser!.technicianId!;
              }
            }
          }
        }
        notifyListeners();
      }

      // 3. Cloud Firestore Real-time Listeners
      final firestore = FirebaseService.instance.firestore;
      if (firestore != null) {
        // Users collection
        firestore.collection('users').snapshots().listen((snapshot) {
          bool changed = false;
          for (var doc in snapshot.docs) {
            try {
              final u = UserAccount.fromJson(doc.data());
              if (u.id == 'user_tech_01' ||
                  u.email.toLowerCase() == 'partner@gmail.com' ||
                  u.name.contains('सचिन') ||
                  u.name.contains('Sachin')) {
                unawaited(FirebaseService.instance.deleteUser(u.id));
                continue;
              }
              final idx = _users.indexWhere(
                (existing) => existing.email.toLowerCase() == u.email.toLowerCase(),
              );
              if (idx == -1) {
                _users.add(u);
                changed = true;
              } else if (_users[idx].password != u.password ||
                  _users[idx].name != u.name ||
                  _users[idx].role != u.role) {
                _users[idx] = u;
                changed = true;
              }
            } catch (err) {
              debugPrint('Firestore users parse error: $err');
            }
          }
          if (changed) {
            _saveUsersToStorage();
            notifyListeners();
          }
        });

        // Bookings collection
        firestore.collection('bookings').snapshots().listen((snapshot) {
          final parsedBookings = <Booking>[];
          for (var doc in snapshot.docs) {
            try {
              parsedBookings.add(Booking.fromJson(doc.data()));
            } catch (err) {
              debugPrint('Firestore booking parse error: $err');
            }
          }
          if (parsedBookings.isNotEmpty) {
            parsedBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            _bookings = parsedBookings;
            cleanupExpiredBookings(retentionDays: 7);
            notifyListeners();
          }
        });

        // Services collection
        firestore.collection('services').snapshots().listen((snapshot) {
          final parsedServices = <ServicePackage>[];
          for (var doc in snapshot.docs) {
            try {
              parsedServices.add(ServicePackage.fromJson(doc.data()));
            } catch (err) {
              debugPrint('Firestore service parse error: $err');
            }
          }
          if (parsedServices.isNotEmpty) {
            _services = parsedServices;
            notifyListeners();
          }
        });

        // Technicians collection
        firestore.collection('technicians').snapshots().listen((snapshot) {
          final parsedTechs = <Technician>[];
          for (var doc in snapshot.docs) {
            try {
              final t = Technician.fromJson(doc.data());
              if (t.id == 'tech_01' ||
                  t.email?.toLowerCase() == 'partner@gmail.com' ||
                  t.name.contains('सचिन') ||
                  t.name.contains('Sachin')) {
                unawaited(FirebaseService.instance.deleteTechnician(t.id));
                continue;
              }
              parsedTechs.add(t);
            } catch (err) {
              debugPrint('Firestore technician parse error: $err');
            }
          }
          _technicians = parsedTechs;
          notifyListeners();
        });

        // Renewals collection
        firestore.collection('renewals').snapshots().listen((snapshot) {
          final parsedRenewals = <AmcRenewal>[];
          for (var doc in snapshot.docs) {
            try {
              final data = doc.data();
              RenewalStatus st = RenewalStatus.dueThisMonth;
              for (var s in RenewalStatus.values) {
                if (s.name == data['status']) {
                  st = s;
                  break;
                }
              }
              parsedRenewals.add(AmcRenewal(
                id: data['id']?.toString() ?? doc.id,
                customerName: data['customerName']?.toString() ?? '',
                customerPhone: data['customerPhone']?.toString() ?? '',
                applianceName: data['applianceName']?.toString() ?? '',
                brandModel: data['brandModel']?.toString() ?? '',
                lastServiceDate: DateTime.tryParse(data['lastServiceDate']?.toString() ?? '') ?? DateTime.now(),
                nextDueDate: DateTime.tryParse(data['nextDueDate']?.toString() ?? '') ?? DateTime.now(),
                planName: data['planName']?.toString() ?? '',
                planPrice: (data['planPrice'] as num?)?.toDouble() ?? 0.0,
                status: st,
                address: data['address']?.toString() ?? '',
              ));
            } catch (err) {
              debugPrint('Firestore renewal parse error: $err');
            }
          }
          if (parsedRenewals.isNotEmpty) {
            _renewals = parsedRenewals;
            notifyListeners();
          }
        });

        // Notifications collection
        firestore.collection('notifications').snapshots().listen((snapshot) {
          final parsedNotifs = <AppNotification>[];
          for (var doc in snapshot.docs) {
            try {
              parsedNotifs.add(AppNotification.fromJson(doc.data()));
            } catch (err) {
              debugPrint('Firestore notification parse error: $err');
            }
          }
          if (parsedNotifs.isNotEmpty) {
            parsedNotifs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            _notifications = parsedNotifs;
            _saveNotificationsToStorage();
            notifyListeners();
          }
        });

        // Washing Machine Specialization metadata doc
        firestore
            .collection('metadata')
            .doc('wm_specialization')
            .snapshots()
            .listen((doc) {
          if (doc.exists && doc.data() != null) {
            try {
              _wmSpecializationConfig =
                  WashingMachineSpecializationConfig.fromJson(doc.data()!);
              _saveWmConfigToStorage();
              notifyListeners();
            } catch (err) {
              debugPrint('Firestore wm config parse error: $err');
            }
          }
        });
      }

      // 4. Realtime Database Listeners (Backup dual-sync)
      final root = FirebaseService.instance.rootRef;
      if (root != null) {
        root.child('bookings').onValue.listen((event) {
          final data = event.snapshot.value;
          if (data is Map && (_bookings.isEmpty)) {
            final parsedBookings = <Booking>[];
            data.forEach((k, v) {
              if (v is Map) {
                try {
                  parsedBookings.add(
                    Booking.fromJson(Map<String, dynamic>.from(v)),
                  );
                } catch (_) {}
              }
            });
            if (parsedBookings.isNotEmpty) {
              parsedBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              _bookings = parsedBookings;
              notifyListeners();
            }
          }
        });

        root.child('notifications').onValue.listen((event) {
          final data = event.snapshot.value;
          if (data is Map && _notifications.isEmpty) {
            final parsedNotifs = <AppNotification>[];
            data.forEach((k, v) {
              if (v is Map) {
                try {
                  parsedNotifs.add(
                    AppNotification.fromJson(Map<String, dynamic>.from(v)),
                  );
                } catch (_) {}
              }
            });
            if (parsedNotifs.isNotEmpty) {
              parsedNotifs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              _notifications = parsedNotifs;
              _saveNotificationsToStorage();
              notifyListeners();
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Firebase init error: $e');
    }
  }

  /// Force a complete sync of all data into homeappliance node
  Future<void> syncAllToFirebase() async {
    await FirebaseService.instance.syncFullState(
      services: _services,
      technicians: _technicians,
      users: _users,
      bookings: _bookings,
      renewals: _renewals,
    );
  }

  Future<void> _saveUsersToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersList = _users.map((u) => u.toJson()).toList();
      await prefs.setString(_usersStorageKey, jsonEncode(usersList));
    } catch (e) {
      debugPrint('Error saving users to storage: $e');
    }
  }

  Future<void> _saveSessionToStorage(String? email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (email == null) {
        await prefs.remove(_sessionStorageKey);
      } else {
        await prefs.setString(_sessionStorageKey, email);
      }
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  Future<void> _saveLanguageToStorage(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageCodeKey, language.code);
      await prefs.setBool(_languageStorageKey, language == AppLanguage.marathi);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  Future<void> _saveNotificationsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsStorageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  // Getters
  AppRole get currentRole => _currentRole;
  AppLanguage get currentLanguage => _currentLanguage;
  bool get isMarathi => _currentLanguage == AppLanguage.marathi;
  bool get isEnglish => _currentLanguage == AppLanguage.english;
  bool get isHindi => _currentLanguage == AppLanguage.hindi;
  bool get isKannada => _currentLanguage == AppLanguage.kannada;
  bool get isGujarati => _currentLanguage == AppLanguage.gujarati;

  String tr(String mr, String en, {String? hi, String? kn, String? gu}) {
    return AppTranslations.trText(
      mr,
      en,
      _currentLanguage,
      hi: hi,
      kn: kn,
      gu: gu,
    );
  }

  DispatchMode get dispatchMode => _dispatchMode;
  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<Technician> get technicians => List.unmodifiable(_technicians);
  List<AmcRenewal> get renewals => List.unmodifiable(_renewals);
  WashingMachineSpecializationConfig get wmSpecializationConfig => _wmSpecializationConfig;

  Future<void> _saveWmConfigToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _wmConfigStorageKey,
        jsonEncode(_wmSpecializationConfig.toJson()),
      );
    } catch (e) {
      debugPrint('Error saving wm config: $e');
    }
  }

  // Admin Washing Machine Specialization Management
  Future<void> updateWmSpecializationConfig(
      WashingMachineSpecializationConfig config) async {
    _wmSpecializationConfig = config;
    notifyListeners();
    await _saveWmConfigToStorage();
    FirebaseService.instance.saveWmConfig(config.toJson());
  }

  Future<void> toggleWmSpecializationAvailability(bool isAvailable) async {
    await updateWmSpecializationConfig(
      _wmSpecializationConfig.copyWith(isServiceAvailable: isAvailable),
    );
  }

  Future<void> toggleWmEmergencySameDay(bool available) async {
    await updateWmSpecializationConfig(
      _wmSpecializationConfig.copyWith(emergencySameDayAvailable: available),
    );
  }

  Future<void> updateWmStandardInspectionFee(double fee) async {
    await updateWmSpecializationConfig(
      _wmSpecializationConfig.copyWith(standardInspectionFee: fee),
    );
  }

  Future<void> addWmBrand(WashingMachineBrand brand) async {
    final list = List<WashingMachineBrand>.from(_wmSpecializationConfig.brands);
    final idx = list.indexWhere((b) => b.id == brand.id);
    if (idx != -1) {
      list[idx] = brand;
    } else {
      list.add(brand);
    }
    await updateWmSpecializationConfig(
      _wmSpecializationConfig.copyWith(brands: list),
    );
  }

  Future<void> updateWmBrand(WashingMachineBrand brand) async {
    await addWmBrand(brand);
  }

  Future<void> toggleWmBrandStatus(String brandId, bool isActive) async {
    final list = List<WashingMachineBrand>.from(_wmSpecializationConfig.brands);
    final idx = list.indexWhere((b) => b.id == brandId);
    if (idx != -1) {
      list[idx] = list[idx].copyWith(isActive: isActive);
      await updateWmSpecializationConfig(
        _wmSpecializationConfig.copyWith(brands: list),
      );
    }
  }

  Future<void> deleteWmBrand(String brandId) async {
    final list = List<WashingMachineBrand>.from(_wmSpecializationConfig.brands);
    list.removeWhere((b) => b.id == brandId);
    await updateWmSpecializationConfig(
      _wmSpecializationConfig.copyWith(brands: list),
    );
  }

  Future<void> updateWmService(
      WashingMachineSpecializationService service) async {
    final list = List<WashingMachineSpecializationService>.from(
        _wmSpecializationConfig.services);
    final idx = list.indexWhere((s) => s.id == service.id);
    if (idx != -1) {
      list[idx] = service;
    } else {
      list.add(service);
    }
    await updateWmSpecializationConfig(
      _wmSpecializationConfig.copyWith(services: list),
    );
  }

  Future<void> addWmPart(WashingMachinePart part) async {
    final list = List<WashingMachinePart>.from(_wmSpecializationConfig.parts);
    final idx = list.indexWhere((p) => p.id == part.id);
    if (idx != -1) {
      list[idx] = part;
    } else {
      list.add(part);
    }
    await updateWmSpecializationConfig(
      _wmSpecializationConfig.copyWith(parts: list),
    );
  }

  Future<void> updateWmPart(WashingMachinePart part) async {
    await addWmPart(part);
  }

  Future<void> toggleWmPartStatus(String partId, bool isActive) async {
    final list = List<WashingMachinePart>.from(_wmSpecializationConfig.parts);
    final idx = list.indexWhere((p) => p.id == partId);
    if (idx != -1) {
      list[idx] = list[idx].copyWith(isActive: isActive);
      await updateWmSpecializationConfig(
        _wmSpecializationConfig.copyWith(parts: list),
      );
    }
  }

  Future<void> updateWmCoverageCities(List<String> cities) async {
    await updateWmSpecializationConfig(
      _wmSpecializationConfig.copyWith(serviceCoverageCities: cities),
    );
  }

  String _normalizePhone(String? phone) {
    if (phone == null) return '';
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Whether a booking belongs to the current logged-in customer
  bool isBookingForCurrentCustomer(Booking b) {
    if (_currentUser?.role == UserRole.admin) {
      return true; // Admin can view all
    }

    // Direct match if booked in this session
    if (_sessionBookedIds.contains(b.id)) {
      return true;
    }

    if (_currentUser == null) {
      return false;
    }

    // Match by explicit customerId
    if (b.customerId != null && b.customerId!.isNotEmpty) {
      if (b.customerId == _currentUser!.id) {
        return true;
      }
    }

    // Match by phone number (last 10 digits match)
    final uPhone = _normalizePhone(_currentUser!.phone);
    final bPhone = _normalizePhone(b.customerPhone);
    if (uPhone.isNotEmpty && bPhone.isNotEmpty) {
      final u10 = uPhone.length >= 10
          ? uPhone.substring(uPhone.length - 10)
          : uPhone;
      final b10 = bPhone.length >= 10
          ? bPhone.substring(bPhone.length - 10)
          : bPhone;
      if (u10 == b10) {
        return true;
      }
    }

    // Match by customer name (case-insensitive)
    final uName = _currentUser!.name.trim().toLowerCase();
    final bName = b.customerName.trim().toLowerCase();
    if (uName.isNotEmpty && bName.isNotEmpty && uName == bName) {
      return true;
    }

    return false;
  }

  /// Whether an AMC Renewal belongs to the current logged-in customer
  bool isRenewalForCurrentCustomer(AmcRenewal r) {
    if (_currentUser?.role == UserRole.admin) {
      return true; // Admin can view all
    }
    if (_currentUser == null) {
      // In guest or unauthenticated mode, show all renewals so they are visible
      return true;
    }

    if (r.customerId != null && r.customerId!.isNotEmpty) {
      if (r.customerId == _currentUser!.id) {
        return true;
      }
    }

    final uPhone = _normalizePhone(_currentUser!.phone);
    final rPhone = _normalizePhone(r.customerPhone);
    if (uPhone.isNotEmpty && rPhone.isNotEmpty) {
      final u10 = uPhone.length >= 10
          ? uPhone.substring(uPhone.length - 10)
          : uPhone;
      final r10 = rPhone.length >= 10
          ? rPhone.substring(rPhone.length - 10)
          : rPhone;
      if (u10 == r10 || uPhone.contains(r10) || rPhone.contains(u10)) {
        return true;
      }
    }

    final uName = _currentUser!.name.trim().toLowerCase();
    final rName = r.customerName.trim().toLowerCase();
    if (uName.isNotEmpty && rName.isNotEmpty) {
      if (uName == rName || uName.contains(rName) || rName.contains(uName)) {
        return true;
      }
    }

    return false;
  }

  /// Returns ONLY bookings belonging to the currently logged in customer
  List<Booking> get customerBookings {
    return _bookings.where(isBookingForCurrentCustomer).toList();
  }

  /// Returns ONLY AMC renewals belonging to the currently logged in customer
  List<AmcRenewal> get customerRenewals {
    return _renewals.where(isRenewalForCurrentCustomer).toList();
  }

  List<UserAccount> get users => List.unmodifiable(_users);
  List<ServicePackage> get services => List.unmodifiable(_services);
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  List<AppNotification> get adminNotifications => _notifications
      .where((n) =>
          n.recipientRole == NotificationRecipientRole.admin ||
          n.recipientRole == NotificationRecipientRole.all)
      .toList();

  int get adminUnreadNotificationsCount =>
      adminNotifications.where((n) => !n.isRead).length;

  List<AppNotification> getPartnerNotifications(String partnerId) =>
      _notifications
          .where((n) =>
              (n.recipientRole == NotificationRecipientRole.partner &&
                  (n.targetPartnerId == null ||
                      n.targetPartnerId == partnerId)) ||
              n.recipientRole == NotificationRecipientRole.all)
          .toList();

  int getPartnerUnreadCount(String partnerId) =>
      getPartnerNotifications(partnerId).where((n) => !n.isRead).length;

  List<AppNotification> get customerNotifications {
    final myBookingIds = customerBookings.map((b) => b.id).toSet();
    final myPhone = _currentUser?.phone.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    return _notifications.where((n) {
      if (n.recipientRole == NotificationRecipientRole.all) return true;
      if (n.recipientRole == NotificationRecipientRole.customer) {
        if (n.bookingId == null || n.bookingId!.isEmpty) return true;
        if (myBookingIds.contains(n.bookingId)) return true;
        if (myPhone.isNotEmpty &&
            n.targetPartnerId != null &&
            n.targetPartnerId!.replaceAll(RegExp(r'[^0-9]'), '').endsWith(myPhone)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  int get customerUnreadNotificationsCount =>
      customerNotifications.where((n) => !n.isRead).length;

  UserAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String get activePartnerId => _activePartnerId;

  // Notification Management Methods
  void addNotification(AppNotification notif) {
    _notifications.removeWhere((n) => n.id == notif.id);
    _notifications.insert(0, notif);
    _saveNotificationsToStorage();
    notifyListeners();
    FirebaseService.instance.saveNotification(notif);
  }

  void markNotificationAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      _saveNotificationsToStorage();
      notifyListeners();
      FirebaseService.instance.markNotificationRead(id);
    }
  }

  void markAllAdminNotificationsAsRead() {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if ((_notifications[i].recipientRole == NotificationRecipientRole.admin ||
              _notifications[i].recipientRole == NotificationRecipientRole.all) &&
          !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        FirebaseService.instance.markNotificationRead(_notifications[i].id);
        changed = true;
      }
    }
    if (changed) {
      _saveNotificationsToStorage();
      notifyListeners();
    }
  }

  void markAllPartnerNotificationsAsRead(String partnerId) {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if ((_notifications[i].recipientRole == NotificationRecipientRole.partner &&
              (_notifications[i].targetPartnerId == null ||
                  _notifications[i].targetPartnerId == partnerId)) &&
          !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        FirebaseService.instance.markNotificationRead(_notifications[i].id);
        changed = true;
      }
    }
    if (changed) {
      _saveNotificationsToStorage();
      notifyListeners();
    }
  }

  void markAllCustomerNotificationsAsRead() {
    bool changed = false;
    final myBookingIds = customerBookings.map((b) => b.id).toSet();
    for (int i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      final isMine = n.recipientRole == NotificationRecipientRole.all ||
          (n.recipientRole == NotificationRecipientRole.customer &&
              (n.bookingId == null || myBookingIds.contains(n.bookingId)));
      if (isMine && !n.isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        FirebaseService.instance.markNotificationRead(_notifications[i].id);
        changed = true;
      }
    }
    if (changed) {
      _saveNotificationsToStorage();
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _saveNotificationsToStorage();
    notifyListeners();
    FirebaseService.instance.deleteNotification(id);
  }

  // Services Catalog Management (Admin controlled)
  void addService(ServicePackage service) {
    _services.add(service);
    FirebaseService.instance.saveService(service);
    notifyListeners();
  }

  void updateService(ServicePackage service) {
    final index = _services.indexWhere((s) => s.id == service.id);
    if (index != -1) {
      _services[index] = service;
      FirebaseService.instance.saveService(service);
      notifyListeners();
    }
  }

  void deleteService(String serviceId) {
    _services.removeWhere((s) => s.id == serviceId);
    FirebaseService.instance.deleteService(serviceId);
    notifyListeners();
  }

  void loadSampleServices() {
    _services = List.from(MockServicesData.allServices);
    syncAllToFirebase();
    notifyListeners();
  }

  // Unified Authentication methods
  Future<UserAccount> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    // 1. Direct Hardcoded Admin Access (admin@gmail.com / admin@123)
    if (cleanEmail == 'admin@gmail.com') {
      if (cleanPass == 'admin@123') {
        const adminUser = UserAccount(
          id: 'admin_01',
          name: 'Super Admin',
          email: 'admin@gmail.com',
          password: 'admin@123',
          phone: '9822000000',
          role: UserRole.admin,
        );
        _currentUser = adminUser;
        final idx = _users.indexWhere(
          (u) => u.email.toLowerCase() == 'admin@gmail.com',
        );
        if (idx != -1) {
          _users[idx] = adminUser;
        } else {
          _users.add(adminUser);
        }
        await _saveSessionToStorage(adminUser.email);
        await _saveUsersToStorage();
        notifyListeners();
        // Provision super admin in Firebase Auth & Firestore in background
        unawaited(FirebaseService.instance.ensureAdminAccount());
        return adminUser;
      } else {
        throw Exception(
          _isMarathi
              ? 'पासवर्ड चुकीचा आहे! कृपया योग्य पासवर्ड तपासा.'
              : 'Incorrect password! Please check and try again.',
        );
      }
    }

    // 2. Check in-memory list
    int userIndex = _users.indexWhere(
      (u) => u.email.toLowerCase() == cleanEmail,
    );

    // 3. If not found in memory, reload from SharedPreferences
    if (userIndex == -1) {
      final prefs = await SharedPreferences.getInstance();
      final usersJsonString = prefs.getString(_usersStorageKey);
      if (usersJsonString != null && usersJsonString.isNotEmpty) {
        try {
          final List<dynamic> decodedList = jsonDecode(usersJsonString);
          for (var item in decodedList) {
            if (item is Map) {
              final account = UserAccount.fromJson(item);
              if (!_users.any((u) => u.email.toLowerCase() == account.email.toLowerCase())) {
                _users.add(account);
              }
            }
          }
          userIndex = _users.indexWhere((u) => u.email.toLowerCase() == cleanEmail);
        } catch (e) {
          debugPrint('Error reloading users from storage: $e');
        }
      }
    }

    // 4. If still not found, query Firebase Cloud Firestore & RTDB directly for this email!
    if (userIndex == -1) {
      try {
        final remoteUser = await FirebaseService.instance.getUserByEmail(cleanEmail);
        if (remoteUser != null) {
          final idx = _users.indexWhere((u) => u.email.toLowerCase() == cleanEmail);
          if (idx == -1) {
            _users.add(remoteUser);
          } else {
            _users[idx] = remoteUser;
          }
          await _saveUsersToStorage();
          userIndex = _users.indexWhere((u) => u.email.toLowerCase() == cleanEmail);
        }
      } catch (e) {
        debugPrint('Error checking Firebase getUserByEmail during login: $e');
      }
    }

    // 5. If STILL not found, fetch all users from Firebase
    if (userIndex == -1) {
      try {
        final fbUsers = await FirebaseService.instance.fetchUsers();
        for (var fUser in fbUsers) {
          final idx = _users.indexWhere((u) => u.email.toLowerCase() == fUser.email.toLowerCase());
          if (idx == -1) {
            _users.add(fUser);
          } else {
            _users[idx] = fUser;
          }
        }
        await _saveUsersToStorage();
        userIndex = _users.indexWhere((u) => u.email.toLowerCase() == cleanEmail);
      } catch (e) {
        debugPrint('Error checking Firebase during login: $e');
      }
    }

    // 6. Direct Firebase Authentication sign-in fallback
    if (userIndex == -1) {
      try {
        final authCred = await FirebaseService.instance.signInWithEmailPassword(
          email: cleanEmail,
          password: cleanPass,
        );
        if (authCred != null && authCred.user != null) {
          final techMatch = _technicians.where((t) => t.email?.toLowerCase() == cleanEmail).firstOrNull;
          final recoveredUser = UserAccount(
            id: authCred.user!.uid,
            name: authCred.user!.displayName ?? (techMatch != null ? techMatch.name : 'User'),
            email: cleanEmail,
            password: cleanPass,
            phone: techMatch?.phone ?? '9800000000',
            role: techMatch != null ? UserRole.partner : UserRole.customer,
            technicianId: techMatch?.id,
          );
          _users.add(recoveredUser);
          await _saveUsersToStorage();
          await FirebaseService.instance.saveUser(recoveredUser);
          userIndex = _users.indexWhere((u) => u.email.toLowerCase() == cleanEmail);
        }
      } catch (e) {
        debugPrint('Direct Firebase Auth sign in note: $e');
      }
    }

    if (userIndex != -1) {
      final user = _users[userIndex];
      if (user.password == cleanPass) {
        _currentUser = user;
        if (_currentUser!.role == UserRole.partner &&
            _currentUser!.technicianId != null) {
          _activePartnerId = _currentUser!.technicianId!;
          // If technician profile isn't in local list yet, fetch from Firebase!
          if (!_technicians.any((t) => t.id == _currentUser!.technicianId)) {
            final fetchedTech = await FirebaseService.instance.getTechnicianById(_currentUser!.technicianId!);
            if (fetchedTech != null) {
              _technicians.add(fetchedTech);
            }
          }
        }
        await _saveSessionToStorage(_currentUser!.email);
        notifyListeners();

        // Background sync with Firebase Authentication & Firestore
        unawaited(FirebaseService.instance.signInWithEmailPassword(
          email: cleanEmail,
          password: cleanPass,
        ));
        unawaited(FirebaseService.instance.saveUser(_currentUser!));

        return _currentUser!;
      } else {
        throw Exception(
          _isMarathi
              ? 'पासवर्ड चुकीचा आहे! कृपया योग्य पासवर्ड तपासा.'
              : 'Incorrect password! Please check and try again.',
        );
      }
    }

    throw Exception(
      _isMarathi
          ? 'या ईमेलवर कोणतेही खाते सापडले नाही! लॉगिन करण्यापूर्वी कृपया प्रथम नवीन नोंदणी (Register) करा.'
          : 'No account found with this email! Please register first before logging in.',
    );
  }

  Future<UserAccount> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPhone = phone.trim();

    final existingIndex = _users.indexWhere(
      (u) => u.email.toLowerCase() == cleanEmail,
    );
    if (existingIndex != -1) {
      throw Exception(
        _isMarathi
            ? 'या ईमेलवर आधीच खाते अस्तित्वात आहे. कृपया लॉगिन करा.'
            : 'An account already exists with this email. Please sign in.',
      );
    }

    // Check remote Firebase if already registered
    try {
      final remoteExisting = await FirebaseService.instance.getUserByEmail(cleanEmail);
      if (remoteExisting != null) {
        if (!_users.any((u) => u.email.toLowerCase() == cleanEmail)) {
          _users.add(remoteExisting);
          await _saveUsersToStorage();
        }
        throw Exception(
          _isMarathi
              ? 'या ईमेलवर आधीच खाते अस्तित्वात आहे. कृपया लॉगिन करा.'
              : 'An account already exists with this email. Please sign in.',
        );
      }
    } catch (e) {
      if (e.toString().contains('आधीच') || e.toString().contains('already exists')) {
        rethrow;
      }
    }

    final existingPhone = _users.any(
      (u) => u.phone.trim() == cleanPhone,
    );
    if (existingPhone) {
      throw Exception(
        _isMarathi
            ? 'या मोबाईल नंबरवर आधीच खाते अस्तित्वात आहे. कृपया लॉगिन करा.'
            : 'An account already exists with this phone number. Please sign in.',
      );
    }

    final newCust = UserAccount(
      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: cleanEmail,
      password: password.trim(),
      phone: cleanPhone,
      role: UserRole.customer,
    );

    _users.add(newCust);
    _currentUser = newCust;
    await _saveUsersToStorage();
    await _saveSessionToStorage(cleanEmail);
    notifyListeners();

    // Directly save to Firebase Auth, Cloud Firestore and Realtime Database
    await FirebaseService.instance.saveUser(newCust);

    return newCust;
  }

  Future<UserAccount> addPartnerByAdmin({
    required String name,
    required String email,
    required String password,
    required String phone,
    required List<String> skills,
    required String locationArea,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final existingIndex = _users.indexWhere(
      (u) => u.email.toLowerCase() == cleanEmail,
    );
    if (existingIndex != -1) {
      throw Exception('या ईमेलवर आधीच पार्टनर नोंदवला गेला आहे.');
    }

    // Check remote Firebase
    try {
      final remoteExisting = await FirebaseService.instance.getUserByEmail(cleanEmail);
      if (remoteExisting != null) {
        throw Exception('या ईमेलवर आधीच खाते अस्तित्वात आहे.');
      }
    } catch (e) {
      if (e.toString().contains('आधीच')) rethrow;
    }

    final newTechId = 'tech_${DateTime.now().millisecondsSinceEpoch}';
    final newTech = Technician(
      id: newTechId,
      name: name.trim(),
      phone: phone.trim(),
      email: cleanEmail,
      skills: skills,
      rating: 5.0,
      totalJobs: 0,
      locationArea: locationArea.trim(),
      latitude: 16.8524,
      longitude: 74.5815,
      isOnline: true,
      todayEarnings: 0.0,
      todayCompletedJobs: 0,
    );

    _technicians.add(newTech);

    final newPartner = UserAccount(
      id: 'user_$newTechId',
      name: name.trim(),
      email: cleanEmail,
      password: password.trim(),
      phone: phone.trim(),
      role: UserRole.partner,
      technicianId: newTechId,
    );

    _users.add(newPartner);
    await _saveUsersToStorage();
    notifyListeners();

    // Immediately save Technician and Partner UserAccount in Firebase
    await FirebaseService.instance.saveTechnician(newTech);
    await FirebaseService.instance.saveUser(newPartner);

    return newPartner;
  }

  void deleteTechnician(String technicianId) {
    _technicians.removeWhere((t) => t.id == technicianId);
    _users.removeWhere((u) => u.technicianId == technicianId);
    _saveUsersToStorage();
    FirebaseService.instance.deleteTechnician(technicianId);
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _saveSessionToStorage(null);
    FirebaseService.instance.signOut();
    notifyListeners();
  }

  Technician? get activeTechnician {
    if (_technicians.isEmpty) return null;
    if (_activePartnerId.isNotEmpty) {
      final index = _technicians.indexWhere((t) => t.id == _activePartnerId);
      if (index != -1) return _technicians[index];
    }
    if (_currentUser?.role == UserRole.partner &&
        _currentUser?.technicianId != null) {
      final index = _technicians.indexWhere(
        (t) => t.id == _currentUser!.technicianId,
      );
      if (index != -1) return _technicians[index];
    }
    return _technicians.firstOrNull;
  }

  // Role switching
  void setRole(AppRole role) {
    _currentRole = role;
    notifyListeners();
  }

  // Language selection & toggle
  void setAppLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      _isMarathi = (_currentLanguage == AppLanguage.marathi);
      AppTranslations.setLanguage(language);
      _saveLanguageToStorage(language);
      notifyListeners();
    }
  }

  void setLanguage(bool isMarathi) {
    setAppLanguage(isMarathi ? AppLanguage.marathi : AppLanguage.english);
  }

  void toggleLanguage() {
    final nextIndex = (_currentLanguage.index + 1) % AppLanguage.values.length;
    setAppLanguage(AppLanguage.values[nextIndex]);
  }

  void setActivePartner(String partnerId) {
    _activePartnerId = partnerId;
    notifyListeners();
  }

  // Dispatch mode switch (Handwritten Note #4)
  void setDispatchMode(DispatchMode mode) {
    _dispatchMode = mode;
    notifyListeners();
  }

  /// Create new booking from Customer App
  Booking createBooking({
    required String customerName,
    required String customerPhone,
    required String address,
    required String landmark,
    required double latitude,
    required double longitude,
    required ServicePackage service,
    required DateTime scheduledDate,
    required String scheduledSlot,
    required PaymentMethod paymentMethod,
    String notes = '',
    String? brand,
    String? machineType,
    String? problem,
    String? selectedPart,
    bool isSpecialization = false,
  }) {
    final newId = 'HA-${1042 + _bookings.length}';
    final randomOtp = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000))
        .toString();

    Booking newBooking = Booking(
      id: newId,
      customerId: _currentUser?.id,
      customerName: customerName,
      customerPhone: customerPhone,
      address: address,
      landmark: landmark,
      latitude: latitude,
      longitude: longitude,
      service: service,
      scheduledDate: scheduledDate,
      scheduledSlot: scheduledSlot,
      status: BookingStatus.pending,
      startOtp: randomOtp,
      laborCost: service.basePrice,
      totalAmount: service.basePrice,
      isPaid: paymentMethod == PaymentMethod.upiOnline,
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: DateTime.now(),
      brand: brand,
      machineType: machineType,
      problem: problem,
      selectedPart: selectedPart,
      isSpecialization: isSpecialization,
    );

    // If dispatch mode is auto, assign to best matching online technician immediately
    if (_dispatchMode == DispatchMode.auto) {
      final bestTech = _findBestTechnicianForService(service.category);
      if (bestTech != null) {
        newBooking = newBooking.copyWith(
          status: BookingStatus.assigned,
          technicianId: bestTech.id,
          technicianName: bestTech.name,
          technicianPhone: bestTech.phone,
        );
      }
    }

    _sessionBookedIds.add(newId);
    _bookings.insert(0, newBooking);
    notifyListeners();
    FirebaseService.instance.saveBooking(newBooking);

    final specTag = isSpecialization && (brand != null || machineType != null)
        ? ' [${brand ?? 'WM'} • ${machineType ?? 'Specialist'}]'
        : '';

    // 1. Send Notification to Admin
    final adminNotif = AppNotification(
      id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}-ADM',
      titleEn: isSpecialization ? 'Washing Machine Specialist Booking! ⚡' : 'New Appointment Booked! 📅',
      titleMr: isSpecialization ? 'वॉशिंग मशीन स्पेशलिस्ट बुकिंग! ⚡' : 'नवीन अपॉइंटमेंट बुक झाली! 📅',
      messageEn: '$customerName ($customerPhone) booked ${service.titleEn}$specTag (#${newBooking.id}) for $scheduledSlot at $address.',
      messageMr: '$customerName ($customerPhone) यांनी ${service.titleMr}$specTag (#${newBooking.id}) वेळ $scheduledSlot साठी बुक केले. पत्ता: $address.',
      type: NotificationType.newBooking,
      recipientRole: NotificationRecipientRole.admin,
      bookingId: newBooking.id,
      createdAt: DateTime.now(),
      isRead: false,
    );
    addNotification(adminNotif);

    // 2. Send Notification to Partner (Assigned technician or Category partners)
    if (newBooking.technicianId != null && newBooking.technicianId!.isNotEmpty) {
      final partnerNotif = AppNotification(
        id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}-PTR-${newBooking.technicianId}',
        titleEn: 'New Job Assigned! 🚀',
        titleMr: 'तुम्हाला नवीन काम सोपवले! 🚀',
        messageEn: 'You have been assigned ${service.titleEn}$specTag (#${newBooking.id}) for $customerName ($customerPhone). Address: $address.',
        messageMr: 'तुम्हाला $customerName ($customerPhone) यांचे ${service.titleMr}$specTag (#${newBooking.id}) हे काम सोपवले आहे. पत्ता: $address.',
        type: NotificationType.jobAssigned,
        recipientRole: NotificationRecipientRole.partner,
        targetPartnerId: newBooking.technicianId,
        bookingId: newBooking.id,
        createdAt: DateTime.now(),
        isRead: false,
      );
      addNotification(partnerNotif);
    } else {
      // Manual mode: Notify matching qualified partners that a new request arrived
      final matchingTechs = getTechniciansForCategory(service.category);
      for (var tech in matchingTechs) {
        final reqNotif = AppNotification(
          id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}-REQ-${tech.id}',
          titleEn: 'New Service Request Available! 🔔',
          titleMr: 'नवीन कामाची विनंती उपलब्ध! 🔔',
          messageEn: 'New customer booking for ${service.titleEn}$specTag (#${newBooking.id}) at ${landmark.isNotEmpty ? landmark : address}.',
          messageMr: '${landmark.isNotEmpty ? landmark : address} येथे ${service.titleMr}$specTag (#${newBooking.id}) साठी नवीन काम उपलब्ध आहे.',
          type: NotificationType.newBooking,
          recipientRole: NotificationRecipientRole.partner,
          targetPartnerId: tech.id,
          bookingId: newBooking.id,
          createdAt: DateTime.now(),
          isRead: false,
        );
        addNotification(reqNotif);
      }
    }

    return newBooking;
  }

  /// Approve Booking by Admin
  void approveBooking({required String bookingId, String? technicianId}) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      Technician? assignedTech;
      if (technicianId != null && technicianId.isNotEmpty) {
        final tIdx = _technicians.indexWhere((t) => t.id == technicianId);
        if (tIdx != -1) assignedTech = _technicians[tIdx];
      }
      assignedTech ??= _findBestTechnicianForService(
        _bookings[index].service.category,
      );

      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.assigned,
        technicianId: assignedTech?.id,
        technicianName: assignedTech?.name ?? 'मंजूर (कामगार वाटप चालू)',
        technicianPhone: assignedTech?.phone ?? '',
      );
      notifyListeners();
      FirebaseService.instance.saveBooking(_bookings[index]);

      if (assignedTech != null) {
        final partnerNotif = AppNotification(
          id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}-APR-${assignedTech.id}',
          titleEn: 'Job Approved & Assigned! 🛠️',
          titleMr: 'काम मंजूर व तुम्हाला सोपवले! 🛠️',
          messageEn: 'Admin approved and assigned you job #${_bookings[index].id}: ${_bookings[index].service.titleEn} for ${_bookings[index].customerName} (${_bookings[index].customerPhone}). Address: ${_bookings[index].address}.',
          messageMr: 'अ‍ॅडमिनने #${_bookings[index].id}: ${_bookings[index].service.titleMr} हे काम मंजूर करून तुम्हाला सोपवले आहे. ग्राहक: ${_bookings[index].customerName} (${_bookings[index].customerPhone}). पत्ता: ${_bookings[index].address}.',
          type: NotificationType.jobAssigned,
          recipientRole: NotificationRecipientRole.partner,
          targetPartnerId: assignedTech.id,
          bookingId: _bookings[index].id,
          createdAt: DateTime.now(),
          isRead: false,
        );
        addNotification(partnerNotif);
      }
    }
  }

  /// Reject Booking by Admin
  void rejectBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.cancelled,
      );
      notifyListeners();
      FirebaseService.instance.saveBooking(_bookings[index]);
    }
  }

  /// Admin direct status update (Handwritten Note #4 - Progress tracking)
  void updateBookingStatus(String bookingId, BookingStatus newStatus) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: newStatus);
      notifyListeners();
      FirebaseService.instance.saveBooking(_bookings[index]);
    }
  }

  /// Manual Assignment by Admin (Handwritten Note #4)
  void assignBookingManually({
    required String bookingId,
    required String technicianId,
  }) {
    final techIndex = _technicians.indexWhere((t) => t.id == technicianId);
    if (techIndex == -1) return;
    final tech = _technicians[techIndex];
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.assigned,
        technicianId: tech.id,
        technicianName: tech.name,
        technicianPhone: tech.phone,
      );
      notifyListeners();
      FirebaseService.instance.saveBooking(_bookings[index]);

      final partnerNotif = AppNotification(
        id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}-ASN-${tech.id}',
        titleEn: 'Job Assigned by Admin! 🛠️',
        titleMr: 'अ‍ॅडमिनने नवीन काम सोपवले! 🛠️',
        messageEn: 'Admin assigned you job #${_bookings[index].id}: ${_bookings[index].service.titleEn} for ${_bookings[index].customerName} (${_bookings[index].customerPhone}). Address: ${_bookings[index].address}.',
        messageMr: 'अ‍ॅडमिनने तुम्हाला #${_bookings[index].id}: ${_bookings[index].service.titleMr} हे काम सोपवले आहे. ग्राहक: ${_bookings[index].customerName} (${_bookings[index].customerPhone}). पत्ता: ${_bookings[index].address}.',
        type: NotificationType.jobAssigned,
        recipientRole: NotificationRecipientRole.partner,
        targetPartnerId: tech.id,
        bookingId: _bookings[index].id,
        createdAt: DateTime.now(),
        isRead: false,
      );
      addNotification(partnerNotif);
    }
  }

  /// Partner updates status to onTheWay
  void partnerOnTheWay(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.onTheWay,
      );
      notifyListeners();
      FirebaseService.instance.saveBooking(_bookings[index]);

      final b = _bookings[index];
      final adminNotif = AppNotification(
        id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}-OTW-ADM',
        titleEn: 'Partner On The Way 🛵',
        titleMr: 'तंत्रज्ञ निघाला 🛵',
        messageEn: '${b.technicianName ?? "Partner"} is on the way for job #${b.id} (${b.customerName}).',
        messageMr: '${b.technicianName ?? "पार्टनर"} काम #${b.id} (${b.customerName}) साठी निघाले आहेत.',
        type: NotificationType.statusUpdate,
        recipientRole: NotificationRecipientRole.admin,
        bookingId: b.id,
        createdAt: DateTime.now(),
        isRead: false,
      );
      addNotification(adminNotif);
    }
  }

  /// Start Job with OTP verification
  bool startJobWithOtp(String bookingId, String enteredOtp) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      if (_bookings[index].startOtp == enteredOtp.trim()) {
        _bookings[index] = _bookings[index].copyWith(
          status: BookingStatus.inProgress,
        );
        notifyListeners();
        FirebaseService.instance.saveBooking(_bookings[index]);
        return true;
      }
    }
    return false;
  }

  /// Add spare parts to digital bill
  void addSparePartToBooking(
    String bookingId,
    String partName,
    double partCost,
  ) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final current = _bookings[index];
      final updatedParts = List<String>.from(current.sparePartsAdded)
        ..add('$partName (${AppHelpers.formatCurrency(partCost)})');
      final newSparePartsCost = current.sparePartsCost + partCost;
      final newTotal = current.laborCost + newSparePartsCost;

      _bookings[index] = current.copyWith(
        sparePartsCost: newSparePartsCost,
        sparePartsAdded: updatedParts,
        totalAmount: newTotal,
      );
      notifyListeners();
      FirebaseService.instance.saveBooking(_bookings[index]);
    }
  }

  /// Complete Job and mark payment
  void completeJob({required String bookingId, required bool isPaidOnline}) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final current = _bookings[index];
      _bookings[index] = current.copyWith(
        status: BookingStatus.completed,
        isPaid: true,
        paymentMethod: isPaidOnline
            ? PaymentMethod.upiOnline
            : PaymentMethod.cashOnDelivery,
      );

      // Update technician earnings
      if (current.technicianId != null) {
        final tIndex = _technicians.indexWhere(
          (t) => t.id == current.technicianId,
        );
        if (tIndex != -1) {
          final t = _technicians[tIndex];
          _technicians[tIndex] = t.copyWith(
            todayEarnings: t.todayEarnings + current.totalAmount,
            todayCompletedJobs: t.todayCompletedJobs + 1,
            totalJobs: t.totalJobs + 1,
          );
          FirebaseService.instance.saveTechnician(_technicians[tIndex]);
        }
      }

      notifyListeners();
      FirebaseService.instance.saveBooking(_bookings[index]);

      final b = _bookings[index];
      final adminNotif = AppNotification(
        id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}-CMP-ADM',
        titleEn: 'Job Completed! ✅',
        titleMr: 'काम पूर्ण झाले! ✅',
        messageEn: 'Job #${b.id} completed by ${b.technicianName ?? "Partner"}. Total: ₹${b.totalAmount.toStringAsFixed(0)}.',
        messageMr: 'बुकिंग #${b.id} चे काम पूर्ण झाले (तंत्रज्ञ: ${b.technicianName ?? "पार्टनर"}). एकूण: ₹${b.totalAmount.toStringAsFixed(0)}.',
        type: NotificationType.statusUpdate,
        recipientRole: NotificationRecipientRole.admin,
        bookingId: b.id,
        createdAt: DateTime.now(),
        isRead: false,
      );
      addNotification(adminNotif);
    }
  }

  /// Delete a single booking / inquiry manually
  void deleteBooking(String bookingId) {
    _bookings.removeWhere((b) => b.id == bookingId);
    notifyListeners();
    FirebaseService.instance.deleteBooking(bookingId);
  }

  /// Automatically purge bookings / inquiries older than 7 days
  int cleanupExpiredBookings({int retentionDays = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    final expired = _bookings.where((b) => b.createdAt.isBefore(cutoff)).toList();
    if (expired.isEmpty) return 0;

    for (final b in expired) {
      _bookings.removeWhere((item) => item.id == b.id);
      FirebaseService.instance.deleteBooking(b.id);
    }
    notifyListeners();
    return expired.length;
  }

  /// Toggle Partner Online/Offline
  void toggleTechnicianDuty(String technicianId) {
    final index = _technicians.indexWhere((t) => t.id == technicianId);
    if (index != -1) {
      final current = _technicians[index];
      _technicians[index] = current.copyWith(isOnline: !current.isOnline);
      notifyListeners();
      FirebaseService.instance.saveTechnician(_technicians[index]);
    }
  }

  /// Add new AMC Renewal
  void addRenewal(AmcRenewal renewal) {
    _renewals.insert(0, renewal);
    notifyListeners();
    FirebaseService.instance.saveRenewal(renewal);
  }

  /// Update existing AMC Renewal
  void updateRenewal(AmcRenewal renewal) {
    final index = _renewals.indexWhere((r) => r.id == renewal.id);
    if (index != -1) {
      _renewals[index] = renewal;
      notifyListeners();
      FirebaseService.instance.saveRenewal(renewal);
    }
  }

  /// Delete AMC Renewal
  void deleteRenewal(String renewalId) {
    _renewals.removeWhere((r) => r.id == renewalId);
    notifyListeners();
    FirebaseService.instance.deleteRenewal(renewalId);
  }

  /// Renew AMC (Handwritten Note #5)
  void renewAmc(String renewalId) {
    final index = _renewals.indexWhere((r) => r.id == renewalId);
    if (index != -1) {
      final current = _renewals[index];
      _renewals[index] = current.copyWith(
        lastServiceDate: DateTime.now(),
        nextDueDate: DateTime.now().add(const Duration(days: 365)),
        status: RenewalStatus.renewed,
      );
      notifyListeners();
      FirebaseService.instance.saveRenewal(_renewals[index]);
    }
  }

  /// Find all technicians matching a service category requirement (skills)
  List<Technician> getTechniciansForCategory(ServiceCategory category) {
    final keywords = _getCategoryKeywords(category);
    return _technicians.where((tech) {
      return tech.skills.any((skill) {
        final lower = skill.toLowerCase();
        return keywords.any((k) => lower.contains(k.toLowerCase()));
      });
    }).toList();
  }

  /// Helper to match technician by skill category
  Technician? _findBestTechnicianForService(ServiceCategory category) {
    if (_technicians.isEmpty) return null;
    final matching = getTechniciansForCategory(category);
    if (matching.isNotEmpty) {
      final onlineMatching = matching.where((t) => t.isOnline).toList();
      if (onlineMatching.isNotEmpty) return onlineMatching.first;
      return matching.first;
    }
    // Fallback: any online technician
    final onlineTechs = _technicians.where((t) => t.isOnline).toList();
    if (onlineTechs.isNotEmpty) return onlineTechs.first;
    return _technicians.first;
  }

  List<String> _getCategoryKeywords(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.ac:
        return ['ac', 'एअर', 'कंडिशनर', 'air'];
      case ServiceCategory.roWater:
        return ['ro', 'water', 'प्युरिफायर', 'filter', 'फिल्टर'];
      case ServiceCategory.refrigerator:
        return ['refrigerator', 'fridge', 'फ्रिज', 'रेफ्रिजरेटर'];
      case ServiceCategory.washingMachine:
        return ['washing', 'वॉशिंग', 'machine', 'मशीन'];
      case ServiceCategory.geyser:
        return ['geyser', 'गिझर', 'electrical', 'इलेक्ट्रिकल', 'heater'];
      case ServiceCategory.plumbing:
        return ['plumbing', 'प्लंबिंग', 'fitting', 'फिटिंग'];
      case ServiceCategory.electrical:
        return ['electrical', 'इलेक्ट्रिकल', 'wiring', 'वायरिंग'];
      case ServiceCategory.chimney:
        return ['chimney', 'चिमणी', 'plumbing', 'fitting', 'hob'];
      case ServiceCategory.other:
        return ['other', 'इतर', 'general', 'appliance', 'handyman', 'उपकरण', 'दुरुस्ती'];
    }
  }
}

// InheritedWidget wrapper or simple Provider-like accessor
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}
