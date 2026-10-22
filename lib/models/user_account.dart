enum UserRole { admin, partner, customer }

extension UserRoleExt on UserRole {
  String get labelEn {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.partner:
        return 'Partner / Technician';
      case UserRole.customer:
        return 'Customer';
    }
  }

  String get labelMr {
    switch (this) {
      case UserRole.admin:
        return 'ॲडमिन';
      case UserRole.partner:
        return 'कामगार / पार्टनर';
      case UserRole.customer:
        return 'ग्राहक';
    }
  }
}

class UserAccount {
  final String id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final UserRole role;
  final String? technicianId;

  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
    this.technicianId,
  });

  UserAccount copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    UserRole? role,
    String? technicianId,
  }) {
    return UserAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      technicianId: technicianId ?? this.technicianId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role.index,
      'technicianId': technicianId,
    };
  }

  factory UserAccount.fromJson(Map<dynamic, dynamic> json) {
    UserRole parsedRole = UserRole.customer;
    final roleRaw = json['role'];
    if (roleRaw is int) {
      if (roleRaw >= 0 && roleRaw < UserRole.values.length) {
        parsedRole = UserRole.values[roleRaw];
      }
    } else if (roleRaw is num) {
      final intVal = roleRaw.toInt();
      if (intVal >= 0 && intVal < UserRole.values.length) {
        parsedRole = UserRole.values[intVal];
      }
    } else if (roleRaw is String) {
      final intVal = int.tryParse(roleRaw);
      if (intVal != null && intVal >= 0 && intVal < UserRole.values.length) {
        parsedRole = UserRole.values[intVal];
      } else {
        for (var r in UserRole.values) {
          if (r.name.toLowerCase() == roleRaw.toLowerCase()) {
            parsedRole = r;
            break;
          }
        }
      }
    }

    return UserAccount(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: parsedRole,
      technicianId: json['technicianId']?.toString(),
    );
  }
}
