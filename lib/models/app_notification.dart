enum NotificationType {
  newBooking, // When customer books a new appointment
  jobAssigned, // When a partner is assigned to a job
  statusUpdate, // Status updates (on the way, completed, etc.)
  general,
}

enum NotificationRecipientRole {
  admin,
  partner,
  customer,
  all,
}

class AppNotification {
  final String id;
  final String titleEn;
  final String titleMr;
  final String messageEn;
  final String messageMr;
  final NotificationType type;
  final NotificationRecipientRole recipientRole;
  final String? targetPartnerId; // Technician ID if intended for specific partner
  final String? bookingId;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.titleEn,
    required this.titleMr,
    required this.messageEn,
    required this.messageMr,
    required this.type,
    required this.recipientRole,
    this.targetPartnerId,
    this.bookingId,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titleEn': titleEn,
    'titleMr': titleMr,
    'messageEn': messageEn,
    'messageMr': messageMr,
    'type': type.name,
    'recipientRole': recipientRole.name,
    'targetPartnerId': targetPartnerId,
    'bookingId': bookingId,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      titleEn: json['titleEn'] ?? '',
      titleMr: json['titleMr'] ?? '',
      messageEn: json['messageEn'] ?? '',
      messageMr: json['messageMr'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      recipientRole: NotificationRecipientRole.values.firstWhere(
        (e) => e.name == json['recipientRole'],
        orElse: () => NotificationRecipientRole.all,
      ),
      targetPartnerId: json['targetPartnerId'],
      bookingId: json['bookingId'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  AppNotification copyWith({
    String? id,
    String? titleEn,
    String? titleMr,
    String? messageEn,
    String? messageMr,
    NotificationType? type,
    NotificationRecipientRole? recipientRole,
    String? targetPartnerId,
    String? bookingId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleMr: titleMr ?? this.titleMr,
      messageEn: messageEn ?? this.messageEn,
      messageMr: messageMr ?? this.messageMr,
      type: type ?? this.type,
      recipientRole: recipientRole ?? this.recipientRole,
      targetPartnerId: targetPartnerId ?? this.targetPartnerId,
      bookingId: bookingId ?? this.bookingId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
