import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/appliance_service.dart';
import '../models/technician.dart';
import '../models/booking.dart';
import '../models/amc_renewal.dart';
import '../models/user_account.dart';
import '../models/app_notification.dart';

/// Comprehensive Firebase Service integrating:
/// 1. Firebase Authentication (Users registration, sign-in, session)
/// 2. Cloud Firestore (Primary database collections: users, services, technicians, bookings, renewals, metadata)
/// 3. Firebase Realtime Database (Dual-sync under "homeappliance" node)
/// All network operations have safe timeouts so UI is never blocked or frozen!
class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();
  FirebaseService._internal();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  DatabaseReference? _rootRef;
  bool _isInitialized = false;

  FirebaseAuth? get auth => _auth;
  FirebaseFirestore? get firestore => _firestore;
  DatabaseReference? get rootRef => _rootRef;
  bool get isInitialized => _isInitialized;

  User? get currentAuthUser => _auth?.currentUser;

  /// Initialize Firebase Authentication, Cloud Firestore and Realtime Database
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        debugPrint('Firebase not initialized yet.');
        return;
      }

      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;

      try {
        final db = FirebaseDatabase.instance;
        _rootRef = db.ref('homeappliance');
      } catch (e) {
        debugPrint('Realtime DB init note: $e');
      }

      _isInitialized = true;

      // Update metadata in Firestore with timeout
      try {
        await _firestore?.collection('metadata').doc('homeappliance').set({
          'appName': 'Home Appliances On-Demand',
          'lastActive': DateTime.now().toIso8601String(),
          'version': '1.0.0',
          'firestoreActive': true,
          'authActive': true,
        }, SetOptions(merge: true)).timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Firestore metadata note: $e');
      }

      // Update metadata in Realtime Database with timeout
      try {
        await _rootRef?.child('metadata').set({
          'appName': 'Home Appliances On-Demand',
          'node': 'homeappliance',
          'lastActive': DateTime.now().toIso8601String(),
          'version': '1.0.0',
        }).timeout(const Duration(seconds: 3));
      } catch (_) {}

      debugPrint('Firebase Service initialized: Firestore & Auth connected successfully!');
    } catch (e) {
      debugPrint('FirebaseService initialize error: $e');
    }
  }

  // ========================================================
  // FIREBASE AUTHENTICATION METHODS
  // ========================================================

  /// Register user in Firebase Authentication with timeout
  Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (_auth == null) return null;
    try {
      final cred = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      ).timeout(const Duration(seconds: 4));
      if (displayName != null && displayName.isNotEmpty) {
        try {
          await cred.user?.updateDisplayName(displayName).timeout(const Duration(seconds: 2));
        } catch (_) {}
      }
      debugPrint('Firebase Auth: User created successfully -> ${cred.user?.email}');
      return cred;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        debugPrint('Firebase Auth: Email already in use, attempting sign-in -> $email');
        try {
          return await _auth!.signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          ).timeout(const Duration(seconds: 3));
        } catch (signInErr) {
          debugPrint('Sign-in fallback note: $signInErr');
        }
      }
      debugPrint('FirebaseAuthException during sign-up: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error signing up in Firebase Auth: $e');
      return null;
    }
  }

  /// Sign in user with Firebase Authentication with timeout
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (_auth == null) return null;
    try {
      final cred = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      ).timeout(const Duration(seconds: 4));
      debugPrint('Firebase Auth: User signed in successfully -> ${cred.user?.email}');
      return cred;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during sign-in: ${e.code}');
      // If user does not exist in Firebase Auth yet, auto-register them
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        try {
          final newCred = await _auth!.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          ).timeout(const Duration(seconds: 4));
          debugPrint('Firebase Auth: Auto-created missing account during sign-in -> $email');
          return newCred;
        } catch (regErr) {
          debugPrint('Auto-create account note: $regErr');
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error signing in to Firebase Auth: $e');
      return null;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth?.signOut().timeout(const Duration(seconds: 2));
      debugPrint('Firebase Auth: User signed out.');
    } catch (e) {
      debugPrint('Error signing out from Firebase Auth: $e');
    }
  }

  /// Ensure a UserAccount exists in Firebase Authentication
  Future<void> ensureAuthUser(UserAccount user) async {
    if (_auth == null) return;
    try {
      final cleanPass = user.password.isNotEmpty ? user.password.trim() : '123456';
      final cleanEmail = user.email.trim().toLowerCase();
      try {
        await _auth!.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: cleanPass,
        ).timeout(const Duration(seconds: 8));
        await _auth!.currentUser?.updateDisplayName(user.name).timeout(const Duration(seconds: 3));
        debugPrint('Firebase Auth: User registered successfully -> ${user.email}');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          debugPrint('Firebase Auth: Account already exists for ${user.email}');
        } else {
          debugPrint('Firebase Auth ensureAuthUser note: ${e.code} - ${e.message}');
        }
      }
    } catch (e) {
      debugPrint('ensureAuthUser note: $e');
    }
  }

  /// Ensure super admin account (admin@gmail.com / admin@123) is provisioned in Firebase
  Future<void> ensureAdminAccount() async {
    const adminAccount = UserAccount(
      id: 'admin_01',
      name: 'Super Admin',
      email: 'admin@gmail.com',
      password: 'admin@123',
      phone: '9822000000',
      role: UserRole.admin,
    );
    await saveUser(adminAccount);
  }

  // ========================================================
  // SEED & INITIAL DATA SYNC (Firestore & Auth & RTDB)
  // ========================================================
  Future<void> seedInitialDataIfEmpty({
    required List<ServicePackage> services,
    required List<Technician> technicians,
    required List<UserAccount> users,
    required List<Booking> bookings,
    required List<AmcRenewal> renewals,
  }) async {
    if (!_isInitialized) return;

    try {
      // 1. Provision seed users in Firebase Authentication in background
      for (var u in users) {
        unawaited(ensureAuthUser(u));
      }

      // 2. Check and Seed Cloud Firestore
      if (_firestore != null) {
        final servicesSnapshot = await _firestore!
            .collection('services')
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 3));

        if (servicesSnapshot.docs.isEmpty) {
          debugPrint('Seeding initial data into Cloud Firestore collections...');
          final batch = _firestore!.batch();

          // Services
          for (var s in services) {
            batch.set(_firestore!.collection('services').doc(s.id), s.toJson());
          }

          // Technicians
          for (var t in technicians) {
            batch.set(_firestore!.collection('technicians').doc(t.id), t.toJson());
          }

          // Users
          for (var u in users) {
            batch.set(_firestore!.collection('users').doc(u.id), u.toJson());
          }

          // Bookings
          for (var b in bookings) {
            batch.set(_firestore!.collection('bookings').doc(b.id), b.toJson());
          }

          // Renewals
          for (var r in renewals) {
            batch.set(_firestore!.collection('renewals').doc(r.id), r.toJson());
          }

          // Metadata
          batch.set(_firestore!.collection('metadata').doc('homeappliance'), {
            'appName': 'Home Appliances On-Demand',
            'lastSeeded': DateTime.now().toIso8601String(),
            'totalServices': services.length,
            'totalTechnicians': technicians.length,
            'totalUsers': users.length,
            'totalBookings': bookings.length,
            'totalRenewals': renewals.length,
          });

          await batch.commit().timeout(const Duration(seconds: 4));
          debugPrint('Cloud Firestore collections successfully seeded!');
        }
      }

      // 3. Seed Realtime Database if empty
      if (_rootRef != null) {
        final rtdbSnapshot = await _rootRef!.child('services').get().timeout(const Duration(seconds: 3));
        if (!rtdbSnapshot.exists || rtdbSnapshot.value == null) {
          final servicesMap = {for (var s in services) s.id: s.toJson()};
          final techsMap = {for (var t in technicians) t.id: t.toJson()};
          final usersMap = {for (var u in users) u.id: u.toJson()};
          final bookingsMap = {for (var b in bookings) b.id: b.toJson()};
          final renewalsMap = {for (var r in renewals) r.id: r.toJson()};

          await _rootRef!.update({
            'services': servicesMap,
            'technicians': techsMap,
            'users': usersMap,
            'bookings': bookingsMap,
            'renewals': renewalsMap,
          }).timeout(const Duration(seconds: 3));
          debugPrint('Realtime Database successfully seeded!');
        }
      }
    } catch (e) {
      debugPrint('Error seeding Firebase initial data: $e');
    }
  }

  // ========================================================
  // REALTIME WRITE METHODS (Cloud Firestore & RTDB & Auth)
  // Non-blocking with timeout so UI never freezes!
  // ========================================================

  /// Save or update user in Cloud Firestore & Auth & RTDB
  Future<void> saveUser(UserAccount user) async {
    // 1. Ensure in Firebase Auth
    try {
      await ensureAuthUser(user);
    } catch (e) {
      debugPrint('ensureAuthUser in saveUser note: $e');
    }

    // 2. Save in Cloud Firestore
    if (_firestore != null) {
      try {
        final userData = user.toJson();
        await _firestore!
            .collection('users')
            .doc(user.id)
            .set(userData, SetOptions(merge: true))
            .timeout(const Duration(seconds: 8), onTimeout: () {
          debugPrint('Firestore saveUser timeout for ${user.email}');
        });
        debugPrint('Firestore: User ${user.email} (${user.role.name}) saved under "users" collection');
      } catch (e) {
        debugPrint('Error saving user to Firestore: $e');
      }
    }

    // 3. Dual-sync to Realtime Database
    if (_rootRef != null) {
      try {
        await _rootRef!
            .child('users')
            .child(user.id)
            .set(user.toJson())
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Error saving user to RTDB: $e');
      }
    }
  }

  /// Query a user by email directly from Cloud Firestore & Realtime Database
  Future<UserAccount?> getUserByEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return null;

    // 1. Try Cloud Firestore query
    if (_firestore != null) {
      try {
        final query = await _firestore!
            .collection('users')
            .where('email', isEqualTo: cleanEmail)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 8));
        if (query.docs.isNotEmpty) {
          final u = UserAccount.fromJson(query.docs.first.data());
          debugPrint('Firestore found user: ${u.email} (${u.role.name})');
          return u;
        }
      } catch (e) {
        debugPrint('Firestore getUserByEmail query note: $e');
      }

      // Fallback: search all users docs in firestore if indexed query had delay
      try {
        final allDocs = await _firestore!
            .collection('users')
            .get()
            .timeout(const Duration(seconds: 6));
        for (var doc in allDocs.docs) {
          final data = doc.data();
          if (data['email']?.toString().trim().toLowerCase() == cleanEmail) {
            final u = UserAccount.fromJson(data);
            debugPrint('Firestore fallback found user: ${u.email}');
            return u;
          }
        }
      } catch (e) {
        debugPrint('Firestore scan users note: $e');
      }
    }

    // 2. Try Realtime Database
    if (_rootRef != null) {
      try {
        final snapshot = await _rootRef!
            .child('users')
            .get()
            .timeout(const Duration(seconds: 6));
        if (snapshot.exists && snapshot.value is Map) {
          final data = snapshot.value as Map;
          for (var entry in data.values) {
            if (entry is Map) {
              try {
                final u = UserAccount.fromJson(entry);
                if (u.email.trim().toLowerCase() == cleanEmail) {
                  debugPrint('RTDB found user: ${u.email}');
                  return u;
                }
              } catch (_) {}
            }
          }
        }
      } catch (e) {
        debugPrint('RTDB getUserByEmail note: $e');
      }
    }

    return null;
  }

  /// Get technician details from Firestore / RTDB by technician ID
  Future<Technician?> getTechnicianById(String techId) async {
    if (techId.isEmpty) return null;

    if (_firestore != null) {
      try {
        final doc = await _firestore!
            .collection('technicians')
            .doc(techId)
            .get()
            .timeout(const Duration(seconds: 6));
        if (doc.exists && doc.data() != null) {
          return Technician.fromJson(doc.data()!);
        }
      } catch (e) {
        debugPrint('Firestore getTechnicianById note: $e');
      }
    }

    if (_rootRef != null) {
      try {
        final snapshot = await _rootRef!
            .child('technicians')
            .child(techId)
            .get()
            .timeout(const Duration(seconds: 5));
        if (snapshot.exists && snapshot.value is Map) {
          return Technician.fromJson(
            Map<String, dynamic>.from(snapshot.value as Map),
          );
        }
      } catch (e) {
        debugPrint('RTDB getTechnicianById note: $e');
      }
    }

    return null;
  }

  /// Save or update a booking in Cloud Firestore & RTDB
  Future<void> saveBooking(Booking booking) async {
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('bookings')
            .doc(booking.id)
            .set(booking.toJson(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 3), onTimeout: () {
          debugPrint('Firestore saveBooking timeout for ${booking.id}');
        });
        debugPrint('Firestore: Booking ${booking.id} saved under "bookings" collection');
      } catch (e) {
        debugPrint('Error saving booking to Firestore: $e');
      }
    }

    if (_rootRef != null) {
      try {
        await _rootRef!
            .child('bookings')
            .child(booking.id)
            .set(booking.toJson())
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  /// Delete a booking from Cloud Firestore & RTDB
  Future<void> deleteBooking(String bookingId) async {
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('bookings')
            .doc(bookingId)
            .delete()
            .timeout(const Duration(seconds: 3));
        debugPrint('Firestore: Booking $bookingId deleted');
      } catch (e) {
        debugPrint('Error deleting booking from Firestore: $e');
      }
    }

    if (_rootRef != null) {
      try {
        await _rootRef!
            .child('bookings')
            .child(bookingId)
            .remove()
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  /// Save or update a service package in Cloud Firestore & RTDB
  Future<void> saveService(ServicePackage service) async {
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('services')
            .doc(service.id)
            .set(service.toJson(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 3), onTimeout: () {
          debugPrint('Firestore saveService timeout for ${service.id}');
        });
        debugPrint('Firestore: Service ${service.id} saved under "services" collection');
      } catch (e) {
        debugPrint('Error saving service to Firestore: $e');
      }
    }

    if (_rootRef != null) {
      try {
        await _rootRef!
            .child('services')
            .child(service.id)
            .set(service.toJson())
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  /// Delete a service from Cloud Firestore & RTDB
  Future<void> deleteService(String serviceId) async {
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('services')
            .doc(serviceId)
            .delete()
            .timeout(const Duration(seconds: 3));
        debugPrint('Firestore: Service $serviceId deleted from "services" collection');
      } catch (e) {
        debugPrint('Error deleting service from Firestore: $e');
      }
    }

    if (_rootRef != null) {
      try {
        await _rootRef!
            .child('services')
            .child(serviceId)
            .remove()
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  /// Save or update a technician in Cloud Firestore & RTDB
  Future<void> saveTechnician(Technician technician) async {
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('technicians')
            .doc(technician.id)
            .set(technician.toJson(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 3), onTimeout: () {
          debugPrint('Firestore saveTechnician timeout');
        });
        debugPrint('Firestore: Technician ${technician.id} saved under "technicians" collection');
      } catch (e) {
        debugPrint('Error saving technician to Firestore: $e');
      }
    }

    if (_rootRef != null) {
      try {
        await _rootRef!
            .child('technicians')
            .child(technician.id)
            .set(technician.toJson())
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  /// Delete a technician from Cloud Firestore & RTDB
  Future<void> deleteTechnician(String technicianId) async {
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('technicians')
            .doc(technicianId)
            .delete()
            .timeout(const Duration(seconds: 3));
        debugPrint('Firestore: Technician $technicianId deleted from "technicians" collection');
      } catch (e) {
        debugPrint('Error deleting technician from Firestore: $e');
      }
    }

    if (_rootRef != null) {
      try {
        await _rootRef!
            .child('technicians')
            .child(technicianId)
            .remove()
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  /// Delete a user account from Cloud Firestore & RTDB
  Future<void> deleteUser(String userId) async {
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('users')
            .doc(userId)
            .delete()
            .timeout(const Duration(seconds: 3));
        debugPrint('Firestore: User $userId deleted from "users" collection');
      } catch (e) {
        debugPrint('Error deleting user from Firestore: $e');
      }
    }

    if (_rootRef != null) {
      try {
        await _rootRef!
            .child('users')
            .child(userId)
            .remove()
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  /// Save an AMC renewal in Cloud Firestore & RTDB
  Future<void> saveRenewal(AmcRenewal renewal) async {
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('renewals')
            .doc(renewal.id)
            .set(renewal.toJson(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 3), onTimeout: () {
          debugPrint('Firestore saveRenewal timeout');
        });
        debugPrint('Firestore: Renewal ${renewal.id} saved under "renewals" collection');
      } catch (e) {
        debugPrint('Error saving renewal to Firestore: $e');
      }
    }

    if (_rootRef != null) {
      try {
        await _rootRef!
            .child('renewals')
            .child(renewal.id)
            .set(renewal.toJson())
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  /// Delete an AMC renewal from Cloud Firestore & RTDB
  Future<void> deleteRenewal(String renewalId) async {
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('renewals')
            .doc(renewalId)
            .delete()
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Error deleting renewal from Firestore: $e');
      }
    }

    if (_rootRef != null) {
      try {
        await _rootRef!
            .child('renewals')
            .child(renewalId)
            .remove()
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  /// Save or update a notification in Cloud Firestore & RTDB
  Future<void> saveNotification(AppNotification notification) async {
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('notifications')
            .doc(notification.id)
            .set(notification.toJson(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 3), onTimeout: () {
          debugPrint('Firestore saveNotification timeout for ${notification.id}');
        });
        debugPrint('Firestore: Notification ${notification.id} saved');
      } catch (e) {
        debugPrint('Error saving notification to Firestore: $e');
      }
    }

    if (_rootRef != null) {
      try {
        await _rootRef!
            .child('notifications')
            .child(notification.id)
            .set(notification.toJson())
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  /// Mark notification as read
  Future<void> markNotificationRead(String notificationId) async {
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('notifications')
            .doc(notificationId)
            .set({'isRead': true}, SetOptions(merge: true))
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Error marking notification read in Firestore: $e');
      }
    }

    if (_rootRef != null) {
      try {
        await _rootRef!
            .child('notifications')
            .child(notificationId)
            .child('isRead')
            .set(true)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('notifications')
            .doc(notificationId)
            .delete()
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Error deleting notification from Firestore: $e');
      }
    }

    if (_rootRef != null) {
      try {
        await _rootRef!
            .child('notifications')
            .child(notificationId)
            .remove()
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }

  /// Fetch all users from Cloud Firestore (with RTDB fallback)
  Future<List<UserAccount>> fetchUsers() async {
    // 1. Try Cloud Firestore first
    if (_firestore != null) {
      try {
        final snapshot = await _firestore!
            .collection('users')
            .get()
            .timeout(const Duration(seconds: 3));
        if (snapshot.docs.isNotEmpty) {
          final list = <UserAccount>[];
          for (var doc in snapshot.docs) {
            try {
              list.add(UserAccount.fromJson(doc.data()));
            } catch (err) {
              debugPrint('Error parsing user from Firestore doc ${doc.id}: $err');
            }
          }
          if (list.isNotEmpty) return list;
        }
      } catch (e) {
        debugPrint('Firestore fetchUsers error: $e');
      }
    }

    // 2. Fallback to Realtime Database
    if (_rootRef != null) {
      try {
        final snapshot = await _rootRef!
            .child('users')
            .get()
            .timeout(const Duration(seconds: 3));
        if (snapshot.exists && snapshot.value is Map) {
          final data = snapshot.value as Map;
          final list = <UserAccount>[];
          data.forEach((k, v) {
            if (v is Map) {
              try {
                list.add(UserAccount.fromJson(v));
              } catch (_) {}
            }
          });
          return list;
        }
      } catch (e) {
        debugPrint('RTDB fetchUsers error: $e');
      }
    }

    return [];
  }

  /// Full backup & sync of all data into Cloud Firestore, Firebase Auth, and RTDB
  Future<void> syncFullState({
    required List<ServicePackage> services,
    required List<Technician> technicians,
    required List<UserAccount> users,
    required List<Booking> bookings,
    required List<AmcRenewal> renewals,
  }) async {
    debugPrint('Starting full sync to Cloud Firestore and Firebase Authentication...');

    // 1. Ensure all users exist in Firebase Authentication (background)
    for (var u in users) {
      unawaited(ensureAuthUser(u));
    }

    // 2. Sync to Cloud Firestore
    if (_firestore != null) {
      try {
        // Services
        for (var s in services) {
          await _firestore!
              .collection('services')
              .doc(s.id)
              .set(s.toJson(), SetOptions(merge: true))
              .timeout(const Duration(seconds: 2));
        }

        // Technicians
        for (var t in technicians) {
          await _firestore!
              .collection('technicians')
              .doc(t.id)
              .set(t.toJson(), SetOptions(merge: true))
              .timeout(const Duration(seconds: 2));
        }

        // Users
        for (var u in users) {
          await _firestore!
              .collection('users')
              .doc(u.id)
              .set(u.toJson(), SetOptions(merge: true))
              .timeout(const Duration(seconds: 2));
        }

        // Bookings
        for (var b in bookings) {
          await _firestore!
              .collection('bookings')
              .doc(b.id)
              .set(b.toJson(), SetOptions(merge: true))
              .timeout(const Duration(seconds: 2));
        }

        // Renewals
        for (var r in renewals) {
          await _firestore!
              .collection('renewals')
              .doc(r.id)
              .set(r.toJson(), SetOptions(merge: true))
              .timeout(const Duration(seconds: 2));
        }

        // Metadata
        await _firestore!.collection('metadata').doc('homeappliance').set({
          'appName': 'Home Appliances On-Demand',
          'lastSync': DateTime.now().toIso8601String(),
          'totalServices': services.length,
          'totalTechnicians': technicians.length,
          'totalUsers': users.length,
          'totalBookings': bookings.length,
          'totalRenewals': renewals.length,
        }, SetOptions(merge: true)).timeout(const Duration(seconds: 3));

        debugPrint('Cloud Firestore: All collections fully synced!');
      } catch (e) {
        debugPrint('Firestore syncFullState error: $e');
      }
    }

    // 3. Sync to Realtime Database
    if (_rootRef != null) {
      try {
        final servicesMap = {for (var s in services) s.id: s.toJson()};
        final techsMap = {for (var t in technicians) t.id: t.toJson()};
        final usersMap = {for (var u in users) u.id: u.toJson()};
        final bookingsMap = {for (var b in bookings) b.id: b.toJson()};
        final renewalsMap = {for (var r in renewals) r.id: r.toJson()};

        await _rootRef!.update({
          'services': servicesMap,
          'technicians': techsMap,
          'users': usersMap,
          'bookings': bookingsMap,
          'renewals': renewalsMap,
          'metadata': {
            'appName': 'Home Appliances On-Demand',
            'node': 'homeappliance',
            'lastSync': DateTime.now().toIso8601String(),
            'totalServices': services.length,
            'totalTechnicians': technicians.length,
            'totalUsers': users.length,
            'totalBookings': bookings.length,
          },
        }).timeout(const Duration(seconds: 3));
        debugPrint('Realtime Database: Full sync completed!');
      } catch (e) {
        debugPrint('RTDB syncFullState error: $e');
      }
    }
  }

  /// Save or update Washing Machine Specialization configuration in Firestore and RTDB
  Future<void> saveWmConfig(Map<String, dynamic> configJson) async {
    if (_firestore != null) {
      try {
        await _firestore!
            .collection('metadata')
            .doc('wm_specialization')
            .set(configJson, SetOptions(merge: true))
            .timeout(const Duration(seconds: 3));
        debugPrint('Firestore: Washing machine specialization config updated');
      } catch (e) {
        debugPrint('Error saving wm specialization config to Firestore: $e');
      }
    }

    if (_rootRef != null) {
      try {
        await _rootRef!
            .child('wm_specialization')
            .set(configJson)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }
}

