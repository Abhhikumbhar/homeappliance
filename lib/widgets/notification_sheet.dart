import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_notification.dart';
import '../state/app_state.dart';
import '../utils/colors.dart';

class NotificationSheet extends StatelessWidget {
  final NotificationRecipientRole role;
  final String? partnerId;
  final Function(String bookingId)? onOpenBooking;

  const NotificationSheet({
    super.key,
    required this.role,
    this.partnerId,
    this.onOpenBooking,
  });

  static void show(
    BuildContext context, {
    required NotificationRecipientRole role,
    String? partnerId,
    Function(String bookingId)? onOpenBooking,
  }) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NotificationSheet(
        role: role,
        partnerId: partnerId,
        onOpenBooking: onOpenBooking,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isMr = appState.isMarathi;

    final List<AppNotification> notifs = role == NotificationRecipientRole.admin
        ? appState.adminNotifications
        : (role == NotificationRecipientRole.customer
            ? appState.customerNotifications
            : appState.getPartnerNotifications(partnerId ?? appState.activePartnerId));

    final unreadCount = notifs.where((n) => !n.isRead).length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4.5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tr('सूचना केंद्र', 'Notifications'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        role == NotificationRecipientRole.admin
                            ? (tr('नवीन बुकिंग व सिस्टम अपडेट्स', 'New Bookings & System Alerts'))
                            : (role == NotificationRecipientRole.customer
                                ? (tr('ऑर्डर अपडेट्स व अलर्ट्स', 'Booking Updates & Alerts'))
                                : (tr('तुम्हाला सोपवलेली कामे व अलर्ट्स', 'Assigned Jobs & Incoming Requests'))),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unreadCount > 0)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: Text(
                      tr('सर्व वाचा', 'Read All'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      if (role == NotificationRecipientRole.admin) {
                        appState.markAllAdminNotificationsAsRead();
                      } else if (role == NotificationRecipientRole.customer) {
                        appState.markAllCustomerNotificationsAsRead();
                      } else {
                        appState.markAllPartnerNotificationsAsRead(
                          partnerId ?? appState.activePartnerId,
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // Notifications List
          Expanded(
            child: notifs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_off_outlined,
                              size: 44,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            tr('कोणत्याही नवीन सूचना नाहीत', 'No Notifications Yet'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            role == NotificationRecipientRole.admin
                                ? (tr('ग्राहकांनी नवीन बुकिंग केल्यावर येथे लगेच सूचना दिसेल.', 'When customers place new bookings, alerts will appear here instantly.'))
                                : (tr('नवीन काम सोपवल्यावर तुम्हाला येथे लगेच सूचना दिसेल.', 'When jobs are assigned to you, alerts will appear here instantly.')),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: notifs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final item = notifs[index];
                      return _buildNotificationCard(
                        context,
                        appState,
                        item,
                        isMr,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppState appState,
    AppNotification notif,
    bool isMr,
  ) {
    Color iconBg;
    Color iconColor;
    IconData iconData;

    switch (notif.type) {
      case NotificationType.newBooking:
        iconBg = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFD97706);
        iconData = Icons.calendar_month_rounded;
        break;
      case NotificationType.jobAssigned:
        iconBg = const Color(0xFFDCFCE7);
        iconColor = const Color(0xFF16A34A);
        iconData = Icons.handyman_rounded;
        break;
      case NotificationType.statusUpdate:
        iconBg = const Color(0xFFDBEAFE);
        iconColor = const Color(0xFF2563EB);
        iconData = Icons.alt_route_rounded;
        break;
      case NotificationType.general:
        iconBg = const Color(0xFFF1F5F9);
        iconColor = AppColors.textSecondary;
        iconData = Icons.notifications_rounded;
        break;
    }

    final timeAgo = _formatTimeAgo(notif.createdAt, isMr);

    return InkWell(
      onTap: () {
        if (!notif.isRead) {
          appState.markNotificationAsRead(notif.id);
        }
        if (notif.bookingId != null && onOpenBooking != null) {
          Navigator.pop(context);
          onOpenBooking!(notif.bookingId!);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead ? AppColors.border : AppColors.primary.withOpacity(0.35),
            width: notif.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tr(notif.titleMr, notif.titleEn),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr(notif.messageMr, notif.messageEn),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (notif.bookingId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tr('तपशील पहा', 'View Details'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 13,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt, bool isMr) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 45) {
      return tr('आत्ताच', 'Just now');
    } else if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return tr('$m मिनीटांपूर्वी', '${m}m ago');
    } else if (diff.inHours < 24) {
      final h = diff.inHours;
      return tr('$h तासांपूर्वी', '${h}h ago');
    } else {
      final d = diff.inDays;
      return tr('$d दिवसांपूर्वी', '${d}d ago');
    }
  }
}
