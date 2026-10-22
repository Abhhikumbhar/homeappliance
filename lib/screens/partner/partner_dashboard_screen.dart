import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/booking.dart';
import '../../models/technician.dart';
import '../../models/appliance_service.dart';
import '../../models/app_notification.dart';
import '../../state/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import 'active_job_screen.dart';
import '../auth/login_screen.dart';
import '../../widgets/language_dropdown.dart';
import '../../widgets/design_components.dart';
import '../../widgets/notification_sheet.dart';

class PartnerDashboardScreen extends StatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final activeTech = appState.activeTechnician;
    final isMr = appState.isMarathi;

    if (activeTech == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.partnerDark,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            tr('पार्टनर डॅशबोर्ड', 'Partner Dashboard'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LanguageDropdown(
                compact: true,
                backgroundColor: Color(0x26FFFFFF),
                textColor: Colors.white,
                iconColor: Colors.white,
                borderColor: Colors.white24,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              tooltip: tr('साइन आउट', 'Logout'),
              onPressed: () {
                appState.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: Center(
          child: EmptyStateWidget(
            icon: Icons.engineering_outlined,
            title: tr('कोणताही कामगार प्रोफाईल सापडला नाही', 'No Partner Profile Found'),
            description: tr('प्रथम ॲडमिन पॅनेलमध्ये जाऊन "+ नवीन पार्टनर जोडा" द्वारे कामगाराची नोंदणी करा आणि त्या ईमेल व पासवर्डने लॉगिन करा.', 'Please add a technician from Admin Panel first and log in with those credentials.'),
            iconColor: AppColors.partnerTheme,
          ),
        ),
      );
    }

    // Filter jobs assigned to this technician (newest on top)
    final myAssignedJobs = appState.bookings.where((b) {
      return b.technicianId == activeTech.id &&
          b.status != BookingStatus.completed &&
          b.status != BookingStatus.cancelled;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final myCompletedJobs = appState.bookings.where((b) {
      return b.technicianId == activeTech.id &&
          (b.status == BookingStatus.completed ||
              b.status == BookingStatus.cancelled);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Check if there are any unassigned pending bookings matching this technician's skills
    final incomingRequests = appState.bookings.where((b) {
      if (b.status != BookingStatus.pending) return false;
      if (activeTech.skills.isEmpty) return true;
      final matchingTechs = appState.getTechniciansForCategory(b.service.category);
      if (matchingTechs.any((t) => t.id == activeTech.id)) return true;
      return activeTech.skills.any((s) {
        final sl = s.toLowerCase();
        if (sl.contains('all') || sl.contains('सर्व')) return true;
        final catEn = b.service.category.nameEn.toLowerCase();
        final catMr = b.service.category.nameMr.toLowerCase();
        final customCat = b.service.customCategoryName?.toLowerCase() ?? '';
        final titleEn = b.service.titleEn.toLowerCase();
        final titleMr = b.service.titleMr.toLowerCase();
        return catEn.contains(sl) ||
            sl.contains(catEn) ||
            catMr.contains(sl) ||
            sl.contains(catMr) ||
            (customCat.isNotEmpty && (customCat.contains(sl) || sl.contains(customCat))) ||
            titleEn.contains(sl) ||
            sl.contains(titleEn) ||
            titleMr.contains(sl) ||
            sl.contains(titleMr);
      });
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.partnerDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: tr('भूमिका बदला', 'Switch Role'),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppHelpers.localizedText(activeTech.name, isMr),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${activeTech.skills.map((s) => AppHelpers.localizedText(s, isMr)).join(", ")} • ${AppHelpers.localizedText(activeTech.locationArea, isMr)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // Partner Real-time Notifications Bell with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_active_rounded, color: Colors.white),
                tooltip: tr('सूचना केंद्र', 'Notifications'),
                onPressed: () {
                  NotificationSheet.show(
                    context,
                    role: NotificationRecipientRole.partner,
                    partnerId: activeTech.id,
                    onOpenBooking: (bookingId) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActiveJobScreen(bookingId: bookingId),
                        ),
                      );
                    },
                  );
                },
              ),
              if (appState.getPartnerUnreadCount(activeTech.id) > 0)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${appState.getPartnerUnreadCount(activeTech.id)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LanguageDropdown(
              compact: true,
              backgroundColor: Color(0x26FFFFFF),
              textColor: Colors.white,
              iconColor: Colors.white,
              borderColor: Colors.white24,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: tr('साइन आउट', 'Logout'),
            onPressed: () {
              appState.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Online / Offline Duty Switcher & Today's Earnings (4 KPI Cards)
            _buildDutyAndEarningsBar(
              context,
              appState,
              activeTech,
              isMr,
              myAssignedJobs.length,
            ),

            // 2. Incoming Job Radar Alert (if new inquiry matching skill arrives)
            if (activeTech.isOnline && incomingRequests.isNotEmpty)
              _buildIncomingRadarAlert(
                context,
                appState,
                incomingRequests.first,
                isMr,
              ),

            // 2B. All Incoming Customer Bookings Section (Clearly visible with complete address & map button)
            if (incomingRequests.isNotEmpty) ...[
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr('नवीन ग्राहक बुकिंग विनंत्या (${incomingRequests.length})', 'New Customer Requests (${incomingRequests.length})'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Text(
                        tr('स्वीकारा व काम सुरू करा', 'Available to Accept'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: incomingRequests
                      .map((b) => _buildIncomingRequestCard(
                            context,
                            appState,
                            b,
                            isMr,
                          ))
                      .toList(),
                ),
              ),
            ],

            const SizedBox(height: 18),

            // 3. Active & Assigned Jobs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('चालू कामे', 'Assigned Active Tasks'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.successBorder),
                    ),
                    child: Text(
                      '${myAssignedJobs.length} ${tr("कामे", "jobs")}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (myAssignedJobs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.task_alt_rounded,
                          size: 44,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tr('सध्या कोणतेही नवीन काम नाही', 'No active tasks assigned right now'),
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr('ड्युटी चालू ठेवा, नवीन बुकिंग येताच अलर्ट येईल.', 'Stay online. You will receive an immediate alert when a job arrives.'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: myAssignedJobs.length,
                itemBuilder: (context, index) {
                  return _buildAssignedJobCard(
                    context,
                    myAssignedJobs[index],
                    isMr,
                  );
                },
              ),

            // Completed Operations Section (Placed at the BOTTOM!)
            if (myCompletedJobs.isNotEmpty) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr('पूर्ण झालेली कामे (${myCompletedJobs.length})', 'Completed Jobs (${myCompletedJobs.length})'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Text(
                        '${myCompletedJobs.length} ${tr("पूर्ण", "done")}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: myCompletedJobs.length,
                itemBuilder: (context, index) {
                  return _buildAssignedJobCard(
                    context,
                    myCompletedJobs[index],
                    isMr,
                  );
                },
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDutyAndEarningsBar(
    BuildContext context,
    AppState appState,
    Technician tech,
    bool isMr,
    int activeJobsCount,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      decoration: const BoxDecoration(
        color: AppColors.partnerDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Online / Offline Duty Switcher
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tech.isOnline
                              ? const Color(0xFF34D399)
                              : Colors.orangeAccent,
                          boxShadow: tech.isOnline
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF34D399)
                                        .withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tech.isOnline
                                  ? (tr('ड्युटी चालू आहे', 'You are Online'))
                                  : (tr('ड्युटी बंद आहे', 'You are Offline')),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              tech.isOnline
                                  ? (tr('सांगली हबमधून नवीन कामे स्वीकारण्यासाठी तयार', 'Ready to receive instant jobs in Sangli'))
                                  : (tr('नवीन कॉल्स मिळवण्यासाठी ड्युटी चालू करा', 'Turn on duty to receive incoming jobs')),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: tech.isOnline,
                  activeThumbColor: const Color(0xFF34D399),
                  activeTrackColor: Colors.white24,
                  onChanged: (val) {
                    appState.toggleTechnicianDuty(tech.id);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4-Metrics KPI Grid (Matching stitch_design_technician_dashboard.png)
          Row(
            children: [
              // KPI 1: Today's Earnings
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.currency_rupee_rounded,
                  title: tr('आजची कमाई', "Today's Earnings"),
                  value: AppHelpers.formatCurrency(tech.todayEarnings),
                  trendText: tr('कालपेक्षा +१८%', '+18% vs yday'),
                  trendColor: const Color(0xFF34D399),
                ),
              ),
              const SizedBox(width: 10),
              // KPI 2: Completed Jobs
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.check_circle_rounded,
                  title: tr('पूर्ण कामे', "Completed Jobs"),
                  value: '${tech.todayCompletedJobs} / 5',
                  trendText: tr('६०% पूर्ण', '60% Target'),
                  trendColor: const Color(0xFF67E8F9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // KPI 3: Pending Active Jobs
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.pending_actions_rounded,
                  title: tr('शिल्लक कामे', "Active Tasks"),
                  value: '$activeJobsCount',
                  trendText: tr('आजचे शेड्युल', "Today's Schedule"),
                  trendColor: const Color(0xFFFDE047),
                ),
              ),
              const SizedBox(width: 10),
              // KPI 4: Performance Rating
              Expanded(
                child: _buildKpiCard(
                  icon: Icons.star_rounded,
                  title: tr('ग्राहक रेटिंग', "Partner Rating"),
                  value: tr('४.९ ★', '4.9 ★'),
                  trendText: tr('८४०+ कामे पूर्ण', '840+ Jobs (PRO)'),
                  trendColor: const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String title,
    required String value,
    required String trendText,
    required Color trendColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.white70),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            trendText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingRadarAlert(
    BuildContext context,
    AppState state,
    Booking booking,
    bool isMr,
  ) {
    return Container(
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.errorBorder, width: 1.5),
        boxShadow: AppColors.coloredShadow(
          AppColors.error,
          opacity: 0.15,
          blur: 12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('नवीन कामाचा अलर्ट!', 'NEW JOB RADAR ALERT!'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    Text(
                      tr('४५ सेकंदांत उत्तर द्या', 'Quickly respond to lock job'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.errorBorder),
                ),
                child: const Text(
                  '00:38',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tr(booking.service.titleMr, booking.service.titleEn),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_rounded, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                booking.customerName,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (booking.customerPhone.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  '• ${booking.customerPhone}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0F766E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Customer Address Box (Clickable to open Google Maps directly)
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              AppHelpers.openGoogleMaps(
                address: booking.address,
                landmark: booking.landmark,
                lat: booking.latitude,
                lng: booking.longitude,
                context: context,
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 15,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          booking.address.isNotEmpty
                              ? booking.address
                              : (tr('पत्ता उपलब्ध नाही', 'No address provided')),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 13,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                  if (booking.landmark.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 21),
                      child: Text(
                        '${tr("खूण:", "Landmark:")} ${booking.landmark}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          if (booking.notes.isNotEmpty) ...[
            Text(
              '${tr("समस्या:", "Issue:")} ${booking.notes}',
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
          ],

          Text(
            '${tr("अंदाजे मजुरी:", "Labor Cost:")} ${AppHelpers.formatCurrency(booking.laborCost)}',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 14),

          // Accept / Map / Decline Buttons
          Row(
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(
                    color: AppColors.errorBorder,
                    width: 1.2,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tr('काम नाकारले', 'Job declined')),
                    ),
                  );
                },
                child: Text(
                  tr('नाकारा', 'Decline'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    backgroundColor: const Color(0xFFEFF6FF),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.navigation_rounded, size: 15),
                  label: Text(
                    tr('नकाशा', 'Maps'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  onPressed: () {
                    AppHelpers.openGoogleMaps(
                      address: booking.address,
                      landmark: booking.landmark,
                      lat: booking.latitude,
                      lng: booking.longitude,
                      context: context,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(
                    tr('स्वीकारा', 'Accept'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  onPressed: () {
                    state.assignBookingManually(
                      bookingId: booking.id,
                      technicianId: state.activePartnerId,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tr('काम यशस्वीरीत्या स्वीकारले!', 'Job Accepted!'),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================================================
  // INCOMING REQUEST CARD FOR ALL AVAILABLE ORDERS
  // ========================================================
  Widget _buildIncomingRequestCard(
    BuildContext context,
    AppState state,
    Booking booking,
    bool isMr,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: ID, Slot & Labor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${booking.id} • ${booking.scheduledSlot}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Text(
                  AppHelpers.formatCurrency(booking.laborCost),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Service title
            Text(
              tr(booking.service.titleMr, booking.service.titleEn),
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            // Customer Name & Phone
            Row(
              children: [
                const Icon(Icons.person_rounded, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  booking.customerName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (booking.customerPhone.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${booking.customerPhone})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0F766E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Customer Address Container (Clickable to open Maps)
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                AppHelpers.openGoogleMaps(
                  address: booking.address,
                  landmark: booking.landmark,
                  lat: booking.latitude,
                  lng: booking.longitude,
                  context: context,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 15,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            booking.address.isNotEmpty
                                ? booking.address
                                : (tr('पत्ता उपलब्ध नाही', 'No address provided')),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.open_in_new_rounded,
                          size: 13,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                    if (booking.landmark.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 21),
                        child: Text(
                          '${tr("खूण:", "Landmark:")} ${booking.landmark}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Actions: Open Map + Accept Job
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      backgroundColor: const Color(0xFFEFF6FF),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.navigation_rounded, size: 14),
                    label: Text(
                      tr('नकाशा उघडा', 'Open Map'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      AppHelpers.openGoogleMaps(
                        address: booking.address,
                        landmark: booking.landmark,
                        lat: booking.latitude,
                        lng: booking.longitude,
                        context: context,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text(
                      tr('काम स्वीकारा', 'Accept Job'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      state.assignBookingManually(
                        bookingId: booking.id,
                        technicianId: state.activePartnerId,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tr('काम यशस्वीरीत्या स्वीकारले!', 'Job Accepted!'),
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedJobCard(
    BuildContext context,
    Booking booking,
    bool isMr,
  ) {
    final customerPhone = booking.customerPhone;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Time Slot Pill + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: Color(0xFF0F766E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        booking.scheduledSlot.isNotEmpty
                            ? '${booking.scheduledSlot} • आज'
                            : (tr('११:३० AM - ०१:०० PM • आज', '11:30 AM - 01:00 PM • Today')),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tr(booking.status.nameMr, booking.status.nameEn),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Service details with category icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCCFBF1)),
                  ),
                  child: Icon(
                    booking.service.category.icon,
                    color: const Color(0xFF0F766E),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(booking.service.titleMr, booking.service.titleEn),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'बुकिंग: #${booking.id} • ${AppHelpers.formatCurrency(booking.totalAmount)}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Customer Details & Location Container (Proper Spacing & Multi-line)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                AppHelpers.openGoogleMaps(
                  address: booking.address,
                  landmark: booking.landmark,
                  lat: booking.latitude,
                  lng: booking.longitude,
                  context: context,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          booking.customerName,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (booking.customerPhone.isNotEmpty)
                          Text(
                            '📞 ${booking.customerPhone}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF0F766E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.address.isNotEmpty
                                    ? booking.address
                                    : (tr('पत्ता उपलब्ध नाही', 'No address provided')),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (booking.landmark.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${tr("खूण:", "Landmark:")} ${booking.landmark}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.open_in_new_rounded,
                          size: 13,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                    if (booking.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${tr("तक्रार:", "Issue:")} ${booking.notes}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Action Pills: Call + Google Maps + Full Message
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF059669),
                      side: const BorderSide(color: Color(0xFFA7F3D0)),
                      backgroundColor: const Color(0xFFECFDF5),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.phone_rounded, size: 14),
                    label: Text(
                      tr('कॉल', 'Call'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () =>
                        AppHelpers.makePhoneCall(customerPhone, context),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      backgroundColor: const Color(0xFFEFF6FF),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.navigation_rounded, size: 14),
                    label: Text(
                      tr('नकाशा', 'Maps'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      AppHelpers.openGoogleMaps(
                        address: booking.address,
                        landmark: booking.landmark,
                        lat: booking.latitude,
                        lng: booking.longitude,
                        context: context,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7C3AED),
                      side: const BorderSide(color: Color(0xFFDDD6FE)),
                      backgroundColor: const Color(0xFFF5F3FF),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.receipt_long_rounded, size: 14),
                    label: Text(
                      tr('मेसेज', 'Message'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      _showJobMessageDialog(context, booking, isMr);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Main Primary Action: Open Job Action & OTP Verification
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.partnerDark,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(
                tr('कामाचा तपशील व OTP पडताळणी उघडा', 'Open Job Details & Start Verification'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActiveJobScreen(bookingId: booking.id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showJobMessageDialog(BuildContext context, Booking booking, bool isMr) {
    final formattedMessage = AppHelpers.buildJobAssignmentMessage(booking, isMr: isMr);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).padding.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tr('कामाचा संपूर्ण मेसेज (Proper Spacing)', 'Full Job Assignment Message'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 340),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SelectableText(
                    formattedMessage,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.6,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: Text(
                        tr('मेसेज कॉपी करा', 'Copy Message'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: formattedMessage));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr('कामाचा मेसेज क्लिपबोर्डवर कॉपी केला!', 'Job message copied to clipboard!'),
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                      label: Text(
                        tr('WhatsApp वर पाठवा', 'Send WhatsApp'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        AppHelpers.openWhatsApp(
                          phone: booking.technicianPhone ?? '',
                          message: formattedMessage,
                          context: context,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
