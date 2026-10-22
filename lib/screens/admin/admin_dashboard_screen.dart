
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/booking.dart';
import '../../models/technician.dart';
import '../../models/amc_renewal.dart';
import '../../models/appliance_service.dart';
import '../../models/app_notification.dart';
import '../../models/user_account.dart';
import '../../state/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import '../auth/login_screen.dart';
import '../../widgets/language_dropdown.dart';
import '../../widgets/design_components.dart';
import '../../widgets/notification_sheet.dart';
import '../customer/amc_contract_document_screen.dart';
import 'admin_amc_form_screen.dart';
import 'admin_wm_specialization_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isMr = appState.isMarathi;

    // Automatic 7-day data retention cleanup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        appState.cleanupExpiredBookings(retentionDays: 7);
      }
    });

    final pendingCount = appState.bookings
        .where((b) => b.status == BookingStatus.pending)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00358E), Color(0xFF0047BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                tooltip: tr('भूमिका बदला', 'Switch Role'),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr('सुपर ॲडमिन', 'Super Admin'),
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              tr('सर्व्हिस ऑपरेशन्स नियंत्रण', 'Operations Control Center'),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          // Admin Real-time Notifications Bell with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_active_rounded, color: Colors.white),
                tooltip: tr('सूचना केंद्र', 'Notifications'),
                onPressed: () {
                  NotificationSheet.show(
                    context,
                    role: NotificationRecipientRole.admin,
                    onOpenBooking: (bookingId) {
                      _tabController.animateTo(0);
                    },
                  );
                },
              ),
              if (appState.adminUnreadNotificationsCount > 0)
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
                      '${appState.adminUnreadNotificationsCount}',
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
              backgroundColor: Color(0x33FFFFFF),
              textColor: Colors.white,
              iconColor: Colors.white,
              borderColor: Colors.white38,
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: const Color(0xFFFFB800),
          indicatorWeight: 3.5,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12.5,
          ),
          tabs: [
            Tab(
              icon: const Icon(Icons.alt_route_rounded, size: 17),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(appState.tr('डिस्पेच', 'Dispatch', hi: 'डिस्पैच', kn: 'ರವಾನೆ', gu: 'ડિસ્પેચ')),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$pendingCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              icon: const Icon(Icons.home_repair_service_rounded, size: 17),
              text: appState.tr('कॅटलॉग', 'Services', hi: 'सेवाएं', kn: 'ಸೇವೆಗಳು', gu: 'સેવાઓ'),
            ),
            Tab(
              icon: const Icon(Icons.people_alt_rounded, size: 17),
              text: appState.tr('पार्टनर्स', 'Partners', hi: 'पार्टनर्स', kn: 'ಪಾಲುದಾರರು', gu: 'ભાગીદારો'),
            ),
            Tab(
              icon: const Icon(Icons.autorenew_rounded, size: 17),
              text: appState.tr('रिन्युअल्स', 'Renewals', hi: 'रिन्यूअल', kn: 'ನವೀಕರಣಗಳು', gu: 'રિન્યૂઅલ્સ'),
            ),
            Tab(
              icon: const Icon(Icons.insights_rounded, size: 17),
              text: appState.tr('आकडेवारी', 'Analytics', hi: 'एनालिटिक्स', kn: 'ವಿಶ್ಲೇಷಣೆ', gu: 'એનાલિટિક્સ'),
            ),
            Tab(
              icon: const Icon(Icons.precision_manufacturing_rounded, size: 17),
              text: appState.tr('WM स्पेशालिस्ट', 'WM Specialist'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Dispatch Engine
          _wrapWithRefresh(_buildDispatchTab(context, appState, isMr), appState, isMr),

          // Tab 2: Services Catalog Management
          _wrapWithRefresh(_buildServicesCatalogTab(context, appState, isMr), appState, isMr),

          // Tab 3: Technicians / Partners Management
          _wrapWithRefresh(_buildTechniciansTab(context, appState, isMr), appState, isMr),

          // Tab 4: AMC Renewal Tracker Board
          _wrapWithRefresh(_buildRenewalsTab(context, appState, isMr), appState, isMr),

          // Tab 5: Analytics Overview
          _wrapWithRefresh(_buildAnalyticsTab(appState, isMr), appState, isMr),

          // Tab 6: Washing Machine Specialization Control Panel
          _wrapWithRefresh(const AdminWmSpecializationView(), appState, isMr),
        ],
      ),
    );
  }

  Widget _wrapWithRefresh(
    Widget child,
    AppState appState,
    bool isMr,
  ) {
    return RefreshIndicator(
      color: AppColors.adminPrimary,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await appState.syncAllToFirebase();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF10B981),
              content: Text(
                tr('Cloud Firestore आणि Authentication वर डेटा सिंक झाला!', 'Data successfully synced with Cloud Firestore & Auth!'),
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: child,
    );
  }

  // ========================================================
  // TAB 1: SMART DISPATCH ENGINE
  // ========================================================
  Widget _buildDispatchTab(BuildContext context, AppState appState, bool isMr) {
    final pendingBookings = appState.bookings
        .where((b) => b.status == BookingStatus.pending)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final activeBookings = appState.bookings
        .where((b) =>
            b.status == BookingStatus.assigned ||
            b.status == BookingStatus.onTheWay ||
            b.status == BookingStatus.inProgress)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final completedBookings = appState.bookings
        .where((b) =>
            b.status == BookingStatus.completed ||
            b.status == BookingStatus.cancelled)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pending Approvals Queue
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: pendingBookings.isNotEmpty
                      ? AppColors.warningLight
                      : AppColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: pendingBookings.isNotEmpty
                        ? AppColors.warningBorder
                        : AppColors.successBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      pendingBookings.isNotEmpty
                          ? Icons.pending_actions_rounded
                          : Icons.check_circle_rounded,
                      size: 13,
                      color: pendingBookings.isNotEmpty
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${pendingBookings.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: pendingBookings.isNotEmpty
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tr("नवीन बुकिंग्ज (मंजुरी आवश्यक)", "Pending Approvals Queue"),
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (pendingBookings.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(22),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.task_alt_rounded,
                      size: 36,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr('मंजुरीसाठी कोणतीही नवीन बुकिंग प्रलंबित नाही.', 'No new bookings waiting for approval.'),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tr('ग्राहकाने नवीन सर्व्हिस बुक केल्यास ती येथे थेट मंजुरीसाठी दिसेल.', 'When a customer books a service, it will appear here for assignment.'),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...pendingBookings.map(
              (b) => _buildPendingBookingCard(context, appState, b, isMr),
            ),

          const SizedBox(height: 22),

          // 2. Active Ongoing Tasks Section (Newest at Top!)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: activeBookings.isNotEmpty
                      ? const Color(0xFFEFF6FF)
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: activeBookings.isNotEmpty
                        ? const Color(0xFFBFDBFE)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.engineering_rounded,
                      size: 13,
                      color: activeBookings.isNotEmpty
                          ? const Color(0xFF2563EB)
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${activeBookings.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: activeBookings.isNotEmpty
                            ? const Color(0xFF2563EB)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tr("सक्रिय कामे (चालू)", "Active Operations (In-Progress)"),
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (activeBookings.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 30,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr('सध्या कोणतेही काम चालू नाही.', 'No active operations currently in progress.'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...activeBookings.map(
              (b) => _buildActiveBookingCard(context, appState, b, isMr),
            ),

          const SizedBox(height: 24),

          // 3. Completed Operations Section (Placed at the BOTTOM!)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${completedBookings.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tr("पूर्ण झालेली कामे (इतिहास)", "Completed Operations (History)"),
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.history_toggle_off_rounded,
                      size: 13,
                      color: Color(0xFF475569),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tr('७ दिवस मर्यादा', '7-Day Limit'),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 7-day data limit info banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7.5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_delete_outlined,
                  size: 15,
                  color: Color(0xFF1D4ED8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr(
                      'डेटा मर्यादा: सर्व पूर्ण झालेल्या नोंदी ७ दिवसांनंतर आपोआप हटवल्या जातात. आवश्यक असल्यास त्वरित हटवण्यासाठी खाली "हटवा" पर्याय दिला आहे.',
                      'Data retention: Completed records auto-delete after 7 days. Use the "Delete" button below to remove records immediately.',
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1E40AF),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          if (completedBookings.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  tr('कोणतेही पूर्ण झालेले काम नाही.', 'No completed bookings yet.'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...completedBookings.map(
              (b) => _buildActiveBookingCard(context, appState, b, isMr),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingBookingCard(
    BuildContext context,
    AppState appState,
    Booking booking,
    bool isMr,
  ) {
    String? selectedTechId;

    return StatefulBuilder(
      builder: (context, setCardState) {
        final matchingTechs = appState.getTechniciansForCategory(
          booking.service.category,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: AppCard(
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.warningBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.pending_actions_rounded,
                            color: AppColors.warning,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          booking.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 19,
                            color: AppColors.error,
                          ),
                          tooltip: tr('चौकशी हटवा', 'Delete Inquiry'),
                          onPressed: () => _confirmDeleteBooking(
                            context,
                            appState,
                            booking,
                            isMr,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.warningBorder),
                          ),
                          child: Text(
                            tr('मंजुरी प्रलंबित', 'Pending Approval'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Service Name & Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tr(booking.service.titleMr, booking.service.titleEn),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                    Text(
                      AppHelpers.formatCurrency(booking.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Customer details
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 15,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${booking.customerName} • ${booking.customerPhone}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.phone_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            onPressed: () => AppHelpers.makePhoneCall(
                              booking.customerPhone,
                              context,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => AppHelpers.openGoogleMaps(
                          address: booking.address,
                          landmark: booking.landmark,
                          lat: booking.latitude,
                          lng: booking.longitude,
                          context: context,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${booking.address} (${booking.landmark})',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
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
                      ),
                      if (booking.notes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.notes_rounded,
                              size: 15,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'समस्या: ${booking.notes}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Matching Technicians Selector
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.engineering_rounded,
                            size: 16,
                            color: AppColors.adminPrimary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tr('या सेवेसाठीचे पार्टनर्स (${booking.service.getCategoryName(isMr)}):', 'Matching Partners (${booking.service.getCategoryName(isMr)}):'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.adminPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (matchingTechs.isNotEmpty) ...[
                        Wrap(
                          spacing: 7,
                          runSpacing: 6,
                          children: matchingTechs.map((t) {
                            final isSelected = selectedTechId == t.id;
                            return ChoiceChip(
                              label: Text('${AppHelpers.localizedText(t.name, isMr)} • ${AppHelpers.localizedText(t.locationArea, isMr)}'),
                              selected: isSelected,
                              selectedColor: AppColors.adminPrimary,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.adminPrimary
                                      : AppColors.border,
                                ),
                              ),
                              labelStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              onSelected: (selected) {
                                setCardState(() {
                                  selectedTechId = selected ? t.id : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tr('या सर्व्हिससाठी कोणताही पार्टनर जोडलेला नाही.', 'No partner registered for this category yet.'),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.adminPrimary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(
                                Icons.person_add_rounded,
                                size: 13,
                              ),
                              label: Text(
                                tr('+ पार्टनर जोडा', '+ Add Partner'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                _showAddPartnerDialog(
                                  context,
                                  appState,
                                  isMr,
                                  preselectedCategory: booking.service.category,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Actions: Reject vs Approve
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.errorBorder),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: Text(tr('रद्द करा', 'Reject')),
                      onPressed: () {
                        appState.rejectBooking(booking.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr('बुकिंग रद्द केले.', 'Booking rejected.'),
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
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
                        icon: const Icon(Icons.check_circle_rounded, size: 17),
                        label: Text(
                          tr('बुकिंग मंजूर करा', 'Approve Booking'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          final assignedTech = selectedTechId != null
                              ? appState.technicians
                                  .where((t) => t.id == selectedTechId)
                                  .firstOrNull
                              : null;
                          final techPhone = assignedTech?.phone ?? '';

                          appState.approveBooking(
                            bookingId: booking.id,
                            technicianId: selectedTechId,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                tr('बुकिंग मंजूर झाले आणि कामगाराला सूचना दिली!', 'Booking approved successfully!'),
                              ),
                              backgroundColor: AppColors.success,
                              action: techPhone.isNotEmpty
                                  ? SnackBarAction(
                                      label: tr('WhatsApp पाठवा', 'WhatsApp'),
                                      textColor: Colors.white,
                                      onPressed: () {
                                        final updatedBooking = appState.bookings
                                                .where((b) => b.id == booking.id)
                                                .firstOrNull ??
                                            booking;
                                        final msg =
                                            AppHelpers.buildJobAssignmentMessage(
                                          updatedBooking,
                                          isMr: isMr,
                                        );
                                        AppHelpers.openWhatsApp(
                                          phone: techPhone,
                                          message: msg,
                                          context: context,
                                        );
                                      },
                                    )
                                  : null,
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
      },
    );
  }

  Widget _buildActiveBookingCard(
    BuildContext context,
    AppState appState,
    Booking booking,
    bool isMr,
  ) {
    bool isChangingPartner = false;

    final double progressValue;
    final int currentStep;
    final Color statusColor;
    final String statusLabel;

    switch (booking.status) {
      case BookingStatus.pending:
        progressValue = 0.10;
        currentStep = 1;
        statusColor = AppColors.warning;
        statusLabel = tr('मंजुरी प्रलंबित', 'Pending Approval');
        break;
      case BookingStatus.assigned:
        progressValue = 0.25;
        currentStep = 1;
        statusColor = AppColors.primary;
        statusLabel = tr('मंजूर (काम सोपवले)', 'Approved & Assigned');
        break;
      case BookingStatus.onTheWay:
        progressValue = 0.50;
        currentStep = 2;
        statusColor = AppColors.info;
        statusLabel = tr('कामगार निघाला 🛵', 'Partner On The Way 🛵');
        break;
      case BookingStatus.inProgress:
        progressValue = 0.75;
        currentStep = 3;
        statusColor = const Color(0xFF7C3AED);
        statusLabel = tr('काम चालू आहे ⚙️', 'Work In Progress ⚙️');
        break;
      case BookingStatus.completed:
        progressValue = 1.0;
        currentStep = 4;
        statusColor = AppColors.success;
        statusLabel = tr('काम पूर्ण ✅', 'Work Completed & Paid ✅');
        break;
      case BookingStatus.cancelled:
        progressValue = 0.0;
        currentStep = 0;
        statusColor = AppColors.error;
        statusLabel = tr('रद्द केले', 'Cancelled');
        break;
    }

    final matchingTechs = appState.getTechniciansForCategory(
      booking.service.category,
    );
    final hasAssignedTech =
        booking.technicianId != null &&
        booking.technicianId!.isNotEmpty &&
        booking.technicianName != 'मंजूर (कामगार वाटप चालू)';

    return StatefulBuilder(
      builder: (context, setCardState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: booking.service.category.color.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        booking.service.category.icon,
                        color: booking.service.category.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${booking.id} • ${booking.customerName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            tr(booking.service.titleMr, booking.service.titleEn),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      AppHelpers.formatCurrency(booking.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Scheduled & Location
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 15,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${booking.address} (${booking.landmark})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.directions_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Maps',
                        onPressed: () => AppHelpers.openGoogleMaps(
                          address: booking.address,
                          landmark: booking.landmark,
                          lat: booking.latitude,
                          lng: booking.longitude,
                          context: context,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.phone_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Call',
                        onPressed: () => AppHelpers.makePhoneCall(
                          booking.customerPhone,
                          context,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Live Process Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timeline_rounded,
                                size: 16,
                                color: statusColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tr('कामाची प्रत्यक्ष प्रगती', 'Work Progress'),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildProgressSteps(currentStep, isMr),
                      const SizedBox(height: 10),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 6,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            statusColor,
                          ),
                        ),
                      ),

                      if (booking.status != BookingStatus.completed &&
                          booking.status != BookingStatus.cancelled) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'OTP: ${booking.startOtp}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Quick Status Transition Actions
                            if (booking.status == BookingStatus.assigned)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warning,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () =>
                                    appState.partnerOnTheWay(booking.id),
                                child: Text(
                                  tr('निघाला 🛵', 'On The Way 🛵'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (booking.status == BookingStatus.onTheWay)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7C3AED),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () => appState.startJobWithOtp(
                                  booking.id,
                                  booking.startOtp,
                                ),
                                child: Text(
                                  tr('काम सुरू ⚙️', 'Start Job ⚙️'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (booking.status == BookingStatus.inProgress)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () => appState.completeJob(
                                  bookingId: booking.id,
                                  isPaidOnline: booking.isPaid,
                                ),
                                child: Text(
                                  tr('पूर्ण करा ✅', 'Mark Done ✅'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Assigned Partner Bar
                if (hasAssignedTech && !isChangingPartner) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.successBorder),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.success,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.technicianName!,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                              if (booking.technicianPhone != null &&
                                  booking.technicianPhone!.isNotEmpty)
                                Text(
                                  booking.technicianPhone!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Send WhatsApp Job Assignment Message to Partner
                        if (booking.technicianPhone != null &&
                            booking.technicianPhone!.isNotEmpty) ...[
                          IconButton(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.chat_bubble_rounded,
                              size: 19,
                              color: Color(0xFF25D366),
                            ),
                            tooltip: tr('पार्टनरला WhatsApp पाठवा', 'WhatsApp Job to Partner'),
                            onPressed: () {
                              final msg = AppHelpers.buildJobAssignmentMessage(
                                booking,
                                isMr: isMr,
                              );
                              AppHelpers.openWhatsApp(
                                phone: booking.technicianPhone!,
                                message: msg,
                                context: context,
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                        ],
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: const BorderSide(color: AppColors.success),
                          ),
                          onPressed: () {
                            setCardState(() {
                              isChangingPartner = true;
                            });
                          },
                          child: Text(
                            tr('बदला', 'Change'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Partner Reassignment Selector
                if (!hasAssignedTech || isChangingPartner) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('पार्टनर नेमा:', 'Assign / Reassign Partner:'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...matchingTechs.map((t) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${AppHelpers.localizedText(t.name, isMr)} • ${AppHelpers.localizedText(t.locationArea, isMr)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.adminPrimary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    appState.assignBookingManually(
                                      bookingId: booking.id,
                                      technicianId: t.id,
                                    );
                                    setCardState(() {
                                      isChangingPartner = false;
                                    });
                                  },
                                  child: Text(
                                    tr('नेमा', 'Assign'),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
                // Bottom Delete & 7-Day Auto-Retention Action Bar
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Retention / Expiry Info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_delete_rounded,
                            size: 13,
                            color: Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getRetentionText(booking.createdAt, isMr),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Delete Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 15,
                        color: AppColors.error,
                      ),
                      label: Text(
                        tr('हटवा', 'Delete'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                      onPressed: () => _confirmDeleteBooking(
                        context,
                        appState,
                        booking,
                        isMr,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getRetentionText(DateTime createdAt, bool isMr) {
    final daysPassed = DateTime.now().difference(createdAt).inDays;
    final daysRemaining = (7 - daysPassed).clamp(0, 7);
    if (daysRemaining <= 0) {
      return isMr ? 'मुदत संपली • आपोआप हटवले जाईल' : 'Expired • Auto-removing';
    }
    return isMr
        ? '$daysRemaining दिवस शिल्लक (७ दिवसांची मर्यादा)'
        : '$daysRemaining days left (7-day limit)';
  }

  void _confirmDeleteBooking(
    BuildContext context,
    AppState appState,
    Booking booking,
    bool isMr,
  ) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: AppColors.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                tr('नोंद हटवायची आहे का?', 'Delete Inquiry Record?'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(
                'नोंद #${booking.id} (${booking.customerName}) कायमची काढून टाकली जाईल.',
                'Record #${booking.id} for ${booking.customerName} will be permanently deleted.',
              ),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: Color(0xFF475569),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      tr(
                        'टीप: सर्व पूर्ण झालेला डेटा ७ दिवसांनंतर आपोआप देखील हटवला जातो.',
                        'Note: All completed inquiry data auto-deletes after 7 days.',
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text(
              tr('रद्द करा', 'Cancel'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () {
              appState.deleteBooking(booking.id);
              Navigator.pop(dCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    tr(
                      'नोंद #${booking.id} सिस्टीममधून कायमची हटवली!',
                      'Record #${booking.id} permanently deleted!',
                    ),
                  ),
                ),
              );
            },
            child: Text(
              tr('होय, हटवा', 'Yes, Delete'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSteps(int currentStep, bool isMr) {
    final steps = [
      {
        'label': tr('मंजूर', 'Approved'),
        'icon': Icons.check_circle_outline,
      },
      {'label': tr('निघाला', 'On Way'), 'icon': Icons.two_wheeler},
      {'label': tr('चालू', 'Working'), 'icon': Icons.build_circle_outlined},
      {'label': tr('पूर्ण', 'Done'), 'icon': Icons.task_alt},
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          final isPastLine = (stepIndex + 1) < currentStep;
          return Expanded(
            child: Container(
              height: 2.5,
              color: isPastLine ? AppColors.success : AppColors.border,
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final stepNumber = stepIndex + 1;
        final isCompleted = stepNumber < currentStep;
        final isCurrent = stepNumber == currentStep;
        final step = steps[stepIndex];

        final Color circleColor = isCompleted
            ? AppColors.success
            : (isCurrent ? AppColors.primary : AppColors.border);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : Icon(
                        step['icon'] as IconData,
                        size: 12,
                        color: isCurrent
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              step['label'] as String,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isCurrent ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }

  // ========================================================
  // TAB 2: SERVICES CATALOG MANAGEMENT
  // ========================================================
  Widget _buildServicesCatalogTab(
    BuildContext context,
    AppState appState,
    bool isMr,
  ) {
    final services = appState.services;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(18),
      children: [
        // Action Banner
        Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: AppColors.adminGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.coloredShadow(
              AppColors.adminPrimary,
              opacity: 0.25,
              blur: 12,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.home_repair_service_rounded,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    tr('सर्व्हिस कॅटलॉग व्यवस्थापन', 'Services Catalog Management'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                tr('येथे तुम्ही नवीन सर्व्हिसेस जोडू, अपडेट करू किंवा काढू शकता. हीच माहिती ग्राहकांना होम स्क्रीनवर दिसते.', 'Manage appliance services catalog in real time. Only active services configured here will appear in customer app.'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.adminPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(
                      tr('+ नवीन सर्व्हिस', '+ Add Service'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    onPressed: () =>
                        _showAddServiceDialog(context, appState, isMr),
                  ),
                  if (services.isEmpty) ...[
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(
                        tr('कॅटलॉग रीस्टोअर करा', 'Restore Default Catalog'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      onPressed: () {
                        appState.loadSampleServices();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr('कॅटलॉग यशस्वीरित्या लोड झाला!', 'Default catalog restored successfully!'),
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Count Label
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 2),
          child: Text(
            tr('सक्रिय सर्व्हिसेस (${services.length})', 'Active Services (${services.length})'),
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        if (services.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.category_outlined,
                    size: 42,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tr('सध्या कोणतीही सर्व्हिस उपलब्ध नाही.', 'Catalog is empty.'),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('नवीन सर्व्हिस जोडण्यासाठी किंवा कॅटलॉग लोड करण्यासाठी वरील बटणावर क्लिक करा.', 'Click "+ Add Service" or "Restore Default Catalog" above.'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...services.map(
            (s) => _buildAdminServiceCard(context, appState, s, isMr),
          ),
      ],
    );
  }

  Widget _buildAdminServiceCard(
    BuildContext context,
    AppState appState,
    ServicePackage s,
    bool isMr,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: s.category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    s.category.icon,
                    color: s.category.color,
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
                          Expanded(
                            child: Text(
                              tr(s.titleMr, s.titleEn),
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (s.isFestiveOffer)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tr('ऑफर', 'OFFER'),
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.getCategoryName(isMr),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: s.category.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              tr(s.descriptionMr, s.descriptionEn),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  AppHelpers.formatCurrency(s.basePrice),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  AppHelpers.formatCurrency(s.originalPrice),
                  style: const TextStyle(
                    fontSize: 11,
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                // Edit Button
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 19,
                    color: AppColors.adminPrimary,
                  ),
                  tooltip: 'Edit',
                  onPressed: () => _showAddServiceDialog(
                    context,
                    appState,
                    isMr,
                    serviceToEdit: s,
                  ),
                ),
                // Delete Button
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 19,
                    color: AppColors.error,
                  ),
                  tooltip: 'Delete',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dCtx) => AlertDialog(
                        title: Text(
                          tr('सर्व्हिस काढायची आहे का?', 'Delete Service?'),
                        ),
                        content: Text(
                          tr('ही सर्व्हिस कॅटलॉगमधून कायमची काढली जाईल.', 'This service will be removed from catalog.'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx),
                            child: Text(tr('रद्द', 'Cancel')),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              appState.deleteService(s.id);
                              Navigator.pop(dCtx);
                            },
                            child: Text(tr('काढा', 'Delete')),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddServiceDialog(
    BuildContext context,
    AppState appState,
    bool isMr, {
    ServicePackage? serviceToEdit,
  }) {
    final isEditing = serviceToEdit != null;
    final customCatCtrl = TextEditingController(
      text: serviceToEdit?.customCategoryName ?? '',
    );
    bool isCustomCat = (serviceToEdit?.customCategoryName != null &&
            serviceToEdit!.customCategoryName!.trim().isNotEmpty) ||
        serviceToEdit?.category == ServiceCategory.other;
    final titleMrCtrl = TextEditingController(
      text: serviceToEdit?.titleMr ?? '',
    );
    final titleEnCtrl = TextEditingController(
      text: serviceToEdit?.titleEn ?? '',
    );
    final descMrCtrl = TextEditingController(
      text: serviceToEdit?.descriptionMr ?? '',
    );
    final descEnCtrl = TextEditingController(
      text: serviceToEdit?.descriptionEn ?? '',
    );
    final basePriceCtrl = TextEditingController(
      text: serviceToEdit != null
          ? serviceToEdit.basePrice.toInt().toString()
          : '499',
    );
    final origPriceCtrl = TextEditingController(
      text: serviceToEdit != null
          ? serviceToEdit.originalPrice.toInt().toString()
          : '799',
    );
    final durationCtrl = TextEditingController(
      text: serviceToEdit != null
          ? serviceToEdit.durationMinutes.toString()
          : '45',
    );
    final warrantyCtrl = TextEditingController(
      text: serviceToEdit != null
          ? serviceToEdit.warrantyDays.toString()
          : '30',
    );
    final inclusionsCtrl = TextEditingController(
      text:
          serviceToEdit?.inclusions.join(', ') ??
          'तपासणी, डीप क्लिनिंग, गॅस प्रेशर चेक',
    );

    ServiceCategory selectedCat = serviceToEdit?.category ?? ServiceCategory.ac;
    bool isFestive = serviceToEdit?.isFestiveOffer ?? false;
    String? formError;

    showDialog(
      context: context,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (context, setDState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                isEditing
                    ? (tr('सर्व्हिस अपडेट करा', 'Edit Service'))
                    : (tr('+ नवीन सर्व्हिस जोडा', '+ Add New Service')),
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (formError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            formError!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                      // Category Mode Switcher
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setDState(() => isCustomCat = false),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: !isCustomCat
                                        ? AppColors.adminPrimary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    tr('यादीतून निवडा', 'Select Category'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: !isCustomCat
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: !isCustomCat
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: InkWell(
                                onTap: () => setDState(() => isCustomCat = true),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isCustomCat
                                        ? AppColors.adminPrimary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit_note_rounded,
                                        size: 15,
                                        color: isCustomCat
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        tr('स्वतः टाईप करा ✍️', 'Type Custom ✍️'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isCustomCat
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: isCustomCat
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (!isCustomCat) ...[
                        DropdownButtonFormField<ServiceCategory>(
                          initialValue: selectedCat,
                          decoration: InputDecoration(
                            labelText: tr('प्रकार (Category)', 'Category'),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          items: ServiceCategory.values.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Row(
                                children: [
                                  Icon(cat.icon, size: 16, color: cat.color),
                                  const SizedBox(width: 8),
                                  Text(
                                    tr(cat.nameMr, cat.nameEn),
                                    style: const TextStyle(fontSize: 12.5),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDState(() {
                                selectedCat = val;
                                if (val == ServiceCategory.other) {
                                  isCustomCat = true;
                                }
                              });
                            }
                          },
                        ),
                      ] else ...[
                        TextField(
                          controller: customCatCtrl,
                          decoration: InputDecoration(
                            labelText: tr('कॅटेगरी / प्रकार नाव टाईप करा *', 'Custom Category Name *'),
                            hintText: tr('उदा. मायक्रोव्हेव, CCTV, सोलर वॉटर हीटर...', 'e.g. Microwave, CCTV, Solar...'),
                            prefixIcon: const Icon(
                              Icons.category_rounded,
                              color: AppColors.adminPrimary,
                              size: 20,
                            ),
                            helperText: tr('कोणताही नवीन प्रकार येथे थेट टाईप करा', 'Type any new category name directly'),
                            helperStyle: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      TextField(
                        controller: titleMrCtrl,
                        decoration: InputDecoration(
                          labelText: tr('सर्व्हिस शीर्षक (मराठी) *', 'Service Title (Marathi) *'),
                          hintText: tr('उदा. मायक्रोव्हेव दुरुस्ती व सर्व्हिस', 'e.g. Microwave Repair & Service'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: titleEnCtrl,
                        decoration: InputDecoration(
                          labelText: tr('सर्व्हिस शीर्षक (इंग्रजी)', 'Service Title (English)'),
                          hintText: tr('उदा. Microwave Repair & Service', 'e.g. Microwave Repair & Service'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: basePriceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: tr('किंमत (₹) *', 'Price (₹) *'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: origPriceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: tr('मूळ किंमत', 'Orig Price'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: durationCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: tr('कालावधी (मिनिटे)', 'Duration (mins)'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: warrantyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: tr('वॉरंटी (दिवस)', 'Warranty (Days)'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descMrCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: tr('वर्णन (मराठी)', 'Description (Marathi)'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: inclusionsCtrl,
                        decoration: InputDecoration(
                          labelText: tr('समाविष्ट कामे (स्वल्पविरामाने वेगळी करा)', 'Inclusions (comma separated)'),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SwitchListTile(
                        title: Text(
                          tr('दिवाळी/सण ऑफर म्हणून दाखवा', 'Mark as Festive Offer'),
                          style: const TextStyle(fontSize: 12.5),
                        ),
                        value: isFestive,
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppColors.accent,
                        onChanged: (val) => setDState(() => isFestive = val),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dCtx),
                  child: Text(tr('रद्द', 'Cancel')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.adminPrimary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final rawMr = titleMrCtrl.text.trim();
                    final rawEn = titleEnCtrl.text.trim();
                    final tMr = rawMr.isNotEmpty ? rawMr : rawEn;
                    final tEn = rawEn.isNotEmpty ? rawEn : rawMr;

                    final bPrice =
                        double.tryParse(basePriceCtrl.text.trim()) ?? 0.0;
                    final oPrice =
                        double.tryParse(origPriceCtrl.text.trim()) ?? bPrice;
                    final dur = int.tryParse(durationCtrl.text.trim()) ?? 45;
                    final war = int.tryParse(warrantyCtrl.text.trim()) ?? 30;

                    final customTyped = customCatCtrl.text.trim();
                    final categoryToUse =
                        isCustomCat ? ServiceCategory.other : selectedCat;
                    final customCatNameToSave = isCustomCat
                        ? (customTyped.isNotEmpty
                            ? customTyped
                            : (tMr.isNotEmpty
                                ? tMr
                                : (tr('इतर सेवा', 'Other Service'))))
                        : (selectedCat == ServiceCategory.other &&
                                customTyped.isNotEmpty
                            ? customTyped
                            : null);

                    if (tMr.isEmpty || bPrice <= 0) {
                      setDState(
                        () => formError = tr('कृपया सेवेचे नाव आणि वैध किंमत भरा.', 'Please enter service title and valid price.'),
                      );
                      return;
                    }

                    final rawDescMr = descMrCtrl.text.trim();
                    final rawDescEn = descEnCtrl.text.trim();
                    final dMr = rawDescMr.isNotEmpty
                        ? rawDescMr
                        : (rawDescEn.isNotEmpty
                            ? rawDescEn
                            : (tr('तपासणी, सर्व्हिसिंग व संपूर्ण दुरुस्ती सेवा.', 'Inspection, servicing and repair service.')));
                    final dEn = rawDescEn.isNotEmpty
                        ? rawDescEn
                        : (rawDescMr.isNotEmpty
                            ? rawDescMr
                            : 'Inspection, servicing and repair service.');

                    final inclusions = inclusionsCtrl.text
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();

                    if (isEditing) {
                      final updated = serviceToEdit.copyWith(
                        category: categoryToUse,
                        customCategoryName: customCatNameToSave,
                        titleMr: tMr,
                        titleEn: tEn,
                        descriptionMr: dMr,
                        descriptionEn: dEn,
                        basePrice: bPrice,
                        originalPrice: oPrice,
                        durationMinutes: dur,
                        warrantyDays: war,
                        inclusions: inclusions.isNotEmpty
                            ? inclusions
                            : ['तपासणी व दुरुस्ती'],
                        isFestiveOffer: isFestive,
                      );
                      appState.updateService(updated);
                    } else {
                      final newService = ServicePackage(
                        id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
                        category: categoryToUse,
                        customCategoryName: customCatNameToSave,
                        titleMr: tMr,
                        titleEn: tEn,
                        descriptionMr: dMr,
                        descriptionEn: dEn,
                        basePrice: bPrice,
                        originalPrice: oPrice,
                        durationMinutes: dur,
                        warrantyDays: war,
                        inclusions: inclusions.isNotEmpty
                            ? inclusions
                            : ['तपासणी व दुरुस्ती'],
                        exclusions: const ['सुटे भाग खर्च वेगळा'],
                        isFestiveOffer: isFestive,
                      );
                      appState.addService(newService);
                    }

                    Navigator.pop(dCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? (tr('सर्व्हिस अपडेट झाली!', 'Service updated!'))
                              : (tr('नवीन सर्व्हिस जोडली!', 'Service added!')),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: Text(
                    isEditing
                        ? (tr('अपडेट करा', 'Update'))
                        : (tr('जोडा', 'Add')),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ========================================================
  // TAB 3: TECHNICIANS / PARTNERS ROSTER
  // ========================================================
  Widget _buildTechniciansTab(
    BuildContext context,
    AppState appState,
    bool isMr,
  ) {
    final techs = appState.technicians;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(18),
      children: [
        // Action Banner
        Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: AppColors.partnerGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.coloredShadow(
              AppColors.partnerTheme,
              opacity: 0.25,
              blur: 12,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('फील्ड पार्टनर (कामगार) व्यवस्थापन', 'Field Partner Management'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr('नवीन कामगाराचे ईमेल व पासवर्ड सेट करून जोडा. पार्टनर ॲपमधून थेट लॉगिन करू शकतील.', 'Add technicians with credentials. Field technicians can log in directly using the partner portal.'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.partnerDark,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: Text(
                  tr('+ नवीन पार्टनर जोडा', '+ Add New Partner'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                onPressed: () => _showAddPartnerDialog(context, appState, isMr),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 2),
          child: Text(
            tr('नोंदणीकृत कामगार (${techs.length})', 'Registered Technicians (${techs.length})'),
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        if (techs.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.people_outline_rounded,
                    size: 42,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tr('अद्याप कोणताही कामगार जोडलेला नाही.', 'No technicians added yet.'),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('वरील "+ नवीन पार्टनर जोडा" बटणावर क्लिक करून कामगार जोडा.', 'Click "+ Add New Partner" above to register field engineers.'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...techs.map((t) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: t.isOnline
                          ? AppColors.successLight
                          : AppColors.surfaceMuted,
                      child: Icon(
                        Icons.engineering_rounded,
                        color: t.isOnline
                            ? AppColors.success
                            : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  AppHelpers.localizedText(t.name, isMr),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: t.isOnline
                                      ? AppColors.success
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          if (t.email != null && t.email!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t.email!,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            t.skills.map((s) => AppHelpers.localizedText(s, isMr)).join(', '),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            AppHelpers.localizedText(t.locationArea, isMr),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (t.totalJobs > 0)
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                Text(
                                  ' ${t.rating} ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '• ${t.totalJobs} ${tr("कामे", "Jobs")}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              tr('नवीन पार्टनर • ० कामे', 'New Partner • 0 Jobs'),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppHelpers.formatCurrency(t.todayEarnings),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          tr('आजची कमाई', "Today's"),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.phone_rounded,
                                color: AppColors.primary,
                                size: 19,
                              ),
                              tooltip: tr('कॉल करा', 'Call'),
                              onPressed: () =>
                                  AppHelpers.makePhoneCall(t.phone, context),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                                size: 19,
                              ),
                              tooltip: tr('पार्टनर काढा', 'Delete Partner'),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (dCtx) => AlertDialog(
                                    title: Text(
                                      tr('पार्टनर काढायचा आहे का?', 'Remove Partner?'),
                                    ),
                                    content: Text(
                                      tr('${AppHelpers.localizedText(t.name, isMr)} यांना पार्टनर यादीतून काढले जाईल.', 'This partner will be removed from the registered list.'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(dCtx),
                                        child: Text(tr('रद्द', 'Cancel')),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          appState.deleteTechnician(t.id);
                                          Navigator.pop(dCtx);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                tr('पार्टनर यशस्वीरित्या काढला.', 'Partner removed successfully.'),
                                              ),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        },
                                        child: Text(tr('काढा', 'Delete')),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  void _showAddPartnerDialog(
    BuildContext context,
    AppState appState,
    bool isMr, {
    ServiceCategory? preselectedCategory,
  }) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final locationController = TextEditingController();
    final customSkillController = TextEditingController();

    String? dialogError;
    bool isOtherSelected = false;
    final List<String> customSkills = [];

    final availableSkills = [
      'वॉटर प्युरिफायर (RO Filter)',
      'एअर कंडिशनर (AC)',
      'वॉशिंग मशीन (Washing Machine)',
      'रेफ्रिजरेटर (Refrigerator)',
      'मायक्रोव्हेव्ह (Microwave)',
      'इलेक्ट्रिकल (Electrical)',
      'प्लंबिंग (Plumbing)',
      'गिझर (Geyser Repair)',
    ];

    String? defaultSkill;
    if (preselectedCategory != null) {
      switch (preselectedCategory) {
        case ServiceCategory.roWater:
          defaultSkill = 'वॉटर प्युरिफायर (RO Filter)';
          break;
        case ServiceCategory.ac:
          defaultSkill = 'एअर कंडिशनर (AC)';
          break;
        case ServiceCategory.washingMachine:
          defaultSkill = 'वॉशिंग मशीन (Washing Machine)';
          break;
        case ServiceCategory.refrigerator:
          defaultSkill = 'रेफ्रिजरेटर (Refrigerator)';
          break;
        case ServiceCategory.geyser:
          defaultSkill = 'गिझर (Geyser Repair)';
          break;
        case ServiceCategory.plumbing:
        case ServiceCategory.chimney:
          defaultSkill = 'प्लंबिंग (Plumbing)';
          break;
        case ServiceCategory.electrical:
        case ServiceCategory.other:
          defaultSkill = 'इलेक्ट्रिकल (Electrical)';
          break;
      }
    }

    final List<String> selectedSkills = defaultSkill != null
        ? [defaultSkill]
        : ['वॉटर प्युरिफायर (RO Filter)', 'एअर कंडिशनर (AC)'];

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                tr('+ नवीन पार्टनर जोडा', '+ Register Field Partner'),
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dialogError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dialogError!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: tr('नाव', 'Full Name'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: tr('मोबाईल नंबर', 'Phone Number'),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: tr('ईमेल (लॉगिनसाठी)', 'Email (for login)'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: tr('पासवर्ड', 'Password'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: tr('कार्यक्षेत्र / शहर', 'Operating Area / City'),
                          hintText: tr(
                            'उदा. सांगली, सातारा, पुणे, कोल्हापूर...',
                            'e.g. Sangli, Satara, Pune, Kolhapur...',
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          tr('कौशल्ये निवडा:', 'Select Skills:'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ...availableSkills.map((skill) {
                            final isSelected = selectedSkills.contains(skill);
                            return FilterChip(
                              label: Text(
                                AppHelpers.localizedText(skill, isMr),
                                style: const TextStyle(fontSize: 11),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.partnerLight,
                              checkmarkColor: AppColors.partnerTheme,
                              onSelected: (val) {
                                setDialogState(() {
                                  if (val) {
                                    selectedSkills.add(skill);
                                  } else {
                                    selectedSkills.remove(skill);
                                  }
                                });
                              },
                            );
                          }),
                          // Custom Skills chips
                          ...customSkills.map((cSkill) {
                            final isSelected = selectedSkills.contains(cSkill);
                            return FilterChip(
                              label: Text(
                                cSkill,
                                style: const TextStyle(fontSize: 11),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.partnerLight,
                              checkmarkColor: AppColors.partnerTheme,
                              onSelected: (val) {
                                setDialogState(() {
                                  if (val) {
                                    selectedSkills.add(cSkill);
                                  } else {
                                    selectedSkills.remove(cSkill);
                                  }
                                });
                              },
                            );
                          }),
                          // "+ इतर / Other" chip
                          FilterChip(
                            avatar: Icon(
                              isOtherSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.add_circle_outline_rounded,
                              size: 14,
                              color: isOtherSelected
                                  ? AppColors.partnerTheme
                                  : AppColors.textSecondary,
                            ),
                            label: Text(
                              tr('इतर (Other)', 'Other'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isOtherSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: isOtherSelected,
                            selectedColor: AppColors.partnerLight,
                            checkmarkColor: AppColors.partnerTheme,
                            onSelected: (val) {
                              setDialogState(() {
                                isOtherSelected = val;
                              });
                            },
                          ),
                        ],
                      ),
                      // Text input for typing custom skills when "Other" is selected
                      if (isOtherSelected) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.partnerTheme.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.edit_note_rounded,
                                    size: 16,
                                    color: AppColors.partnerTheme,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    tr(
                                      'इतर कौशल्य / वर्ग टाईप करा:',
                                      'Type Other Skill / Category:',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.partnerDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: customSkillController,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        hintText: tr(
                                          'उदा. चिमणी, टीव्ही, सोलर, सुतारकाम...',
                                          'e.g. Chimney, TV, Solar, Handyman...',
                                        ),
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFCBD5E1),
                                          ),
                                        ),
                                      ),
                                      onSubmitted: (val) {
                                        final text = val.trim();
                                        if (text.isNotEmpty) {
                                          setDialogState(() {
                                            if (!selectedSkills.contains(text)) {
                                              selectedSkills.add(text);
                                            }
                                            if (!customSkills.contains(text)) {
                                              customSkills.add(text);
                                            }
                                            customSkillController.clear();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.partnerTheme,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 11,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      final text =
                                          customSkillController.text.trim();
                                      if (text.isNotEmpty) {
                                        setDialogState(() {
                                          if (!selectedSkills.contains(text)) {
                                            selectedSkills.add(text);
                                          }
                                          if (!customSkills.contains(text)) {
                                            customSkills.add(text);
                                          }
                                          customSkillController.clear();
                                        });
                                      }
                                    },
                                    child: Text(
                                      tr('जोडा', 'Add'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (customSkills.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: customSkills.map((cSkill) {
                                    return Chip(
                                      label: Text(
                                        cSkill,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.partnerDark,
                                        ),
                                      ),
                                      backgroundColor: AppColors.partnerLight,
                                      deleteIcon: const Icon(
                                        Icons.close_rounded,
                                        size: 13,
                                        color: AppColors.partnerDark,
                                      ),
                                      onDeleted: () {
                                        setDialogState(() {
                                          selectedSkills.remove(cSkill);
                                          customSkills.remove(cSkill);
                                        });
                                      },
                                      side: BorderSide(
                                        color: AppColors.partnerTheme
                                            .withValues(alpha: 0.5),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(tr('रद्द', 'Cancel')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.partnerDark,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final phone = phoneController.text.trim();
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();
                    final area = locationController.text.trim();

                    // If user typed in custom skill box without pressing "Add", auto-add it
                    final typedOther = customSkillController.text.trim();
                    if (isOtherSelected &&
                        typedOther.isNotEmpty &&
                        !selectedSkills.contains(typedOther)) {
                      selectedSkills.add(typedOther);
                    }

                    if (name.isEmpty ||
                        phone.isEmpty ||
                        email.isEmpty ||
                        password.isEmpty ||
                        area.isEmpty) {
                      setDialogState(
                        () => dialogError = tr('कृपया सर्व आवश्यक माहिती भरा.', 'Please fill all required fields.'),
                      );
                      return;
                    }

                    if (phone.length != 10) {
                      setDialogState(
                        () => dialogError = tr('कृपया किमान १० अंकी वैध मोबाईल नंबर टाका.', 'Please enter a valid 10-digit phone number.'),
                      );
                      return;
                    }

                    if (selectedSkills.isEmpty) {
                      setDialogState(
                        () => dialogError = tr('किमान एक कौशल्य निवडा किंवा टाईप करा.', 'Select or enter at least one skill.'),
                      );
                      return;
                    }

                    try {
                      await appState.addPartnerByAdmin(
                        name: name,
                        email: email,
                        password: password,
                        phone: phone,
                        skills: selectedSkills,
                        locationArea: area,
                      );
                      if (context.mounted) {
                        Navigator.pop(dialogCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr('नवीन पार्टनर ($name) जोडला!', 'Partner ($name) registered!'),
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      setDialogState(
                        () => dialogError = e.toString().replaceAll(
                          'Exception: ',
                          '',
                        ),
                      );
                    }
                  },
                  child: Text(tr('जोडा', 'Add Partner')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ========================================================
  // TAB 4: AMC & RENEWALS TRACKER
  // ========================================================
  Widget _buildRenewalsTab(BuildContext context, AppState appState, bool isMr) {
    final renewals = appState.renewals;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(18),
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          backgroundColor: AppColors.infoLight,
          borderColor: AppColors.infoBorder,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.autorenew_rounded,
                    color: AppColors.info,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('अप्लायन्स AMC रिन्युअल ट्रॅकर', 'AMC & Servicing Renewal Radar'),
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0369A1),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr('कोणत्या ग्राहकाचे वॉटर फिल्टर, एसी किंवा गिझरची सर्व्हिसिंग मुदत आली आहे ते येथे दिसते.', 'Track upcoming filter changes, AC maintenance cycles and send 1-click WhatsApp reminders.'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF0284C7),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003B99),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.description_rounded, size: 18),
                    label: Text(
                      tr('📝 नवीन AMC करारपत्र भरा', '📝 Create AMC Agreement'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminAmcFormScreen(),
                        ),
                      );
                    },
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0284C7),
                      side: const BorderSide(color: Color(0xFF0284C7)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.flash_on_rounded, size: 16),
                    label: Text(
                      tr('जलद नोंदणी', 'Quick Add'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () => _showAddAmcDialog(context, appState, isMr),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (renewals.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 40,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tr('सध्या कोणतेही AMC रिन्युअल प्रलंबित नाही.', 'No AMC renewals pending.'),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('ग्राहकांचे वार्षिक मेंटेनन्स प्लॅन्स येथे जोडा व ट्रॅक करा.', 'Customer AMC protection plans will be tracked here.'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003B99),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.description_rounded, size: 18),
                    label: Text(
                      tr('📝 नवीन AMC करारपत्र भरा', '📝 Create AMC Agreement'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminAmcFormScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('सक्रिय AMC रिन्युअल्स (${renewals.length})', 'Active AMC Renewals (${renewals.length})'),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                  label: Text(tr('नवीन AMC करार', 'New AMC Contract')),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF003B99),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminAmcFormScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ...renewals.map(
            (r) => _buildAdminRenewalCard(context, appState, r, isMr),
          ),
        ],
      ],
    );
  }

  Widget _buildAdminRenewalCard(
    BuildContext context,
    AppState appState,
    AmcRenewal r,
    bool isMr,
  ) {
    Color badgeColor;
    switch (r.status) {
      case RenewalStatus.dueThisWeek:
        badgeColor = AppColors.warning;
        break;
      case RenewalStatus.dueThisMonth:
        badgeColor = AppColors.primary;
        break;
      case RenewalStatus.overdue:
        badgeColor = AppColors.error;
        break;
      case RenewalStatus.renewed:
        badgeColor = AppColors.success;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    r.customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: badgeColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    tr(r.status.labelMr, r.status.labelEn),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              r.brandModel,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              r.planName,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              r.address,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${tr("रिन्युअल तारीख:", "Due Date:")} ${AppHelpers.formatDate(r.nextDueDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  AppHelpers.formatCurrency(r.planPrice),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 8),
            Row(
              children: [
                if (r.status != RenewalStatus.renewed)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                    ),
                    label: Text(
                      tr('रिन्यू झाले', 'Mark Renewed'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      appState.renewAmc(r.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text(
                            tr('AMC यशस्वीरित्या रिन्यू झाले!', 'AMC marked as renewed!'),
                          ),
                        ),
                      );
                    },
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 19,
                    color: AppColors.primary,
                  ),
                  tooltip: tr('संपादित करा', 'Edit'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminAmcFormScreen(renewalToEdit: r),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 19,
                    color: AppColors.error,
                  ),
                  tooltip: tr('काढा', 'Delete'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dCtx) => AlertDialog(
                        title: Text(
                          tr('AMC प्लॅन काढायचा?', 'Delete AMC Plan?'),
                        ),
                        content: Text(
                          tr('हा AMC प्लॅन कायमचा काढला जाईल.', 'This AMC plan will be permanently removed.'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx),
                            child: Text(tr('रद्द', 'Cancel')),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              appState.deleteRenewal(r.id);
                              Navigator.pop(dCtx);
                            },
                            child: Text(tr('काढा', 'Delete')),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: Color(0xFF003B99),
                  ),
                  tooltip: tr('AMC करारपत्र पहा', 'View AMC Contract'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AmcContractDocumentScreen(renewal: r),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.phone_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                  tooltip: tr('कॉल करा', 'Call'),
                  onPressed: () =>
                      AppHelpers.makePhoneCall(r.customerPhone, context),
                ),
                const SizedBox(width: 4),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.chat_bubble_rounded, size: 14),
                  label: Text(
                    tr('व्हॉट्सॲप', 'WhatsApp'),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    final message = tr('नमस्कार ${r.customerName}! आपल्या ${r.brandModel} ची सर्व्हिसिंग मुदत आली आहे. त्वरित रिन्यू करण्यासाठी येथे संपर्क करा.', 'Hello ${r.customerName}! Your ${r.brandModel} periodic service is due. Renew now to avoid sudden breakdowns.');
                    AppHelpers.openWhatsApp(
                      phone: r.customerPhone,
                      message: message,
                      context: context,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAmcDialog(
    BuildContext context,
    AppState appState,
    bool isMr, {
    AmcRenewal? renewalToEdit,
  }) {
    final isEditing = renewalToEdit != null;
    final nameCtrl = TextEditingController(
      text: renewalToEdit?.customerName ?? '',
    );
    final phoneCtrl = TextEditingController(
      text: renewalToEdit?.customerPhone ?? '',
    );
    final applianceCtrl = TextEditingController(
      text: renewalToEdit?.applianceName ?? '',
    );
    final brandModelCtrl = TextEditingController(
      text: renewalToEdit?.brandModel ?? '',
    );
    final planNameCtrl = TextEditingController(
      text: renewalToEdit?.planName ?? '',
    );
    final priceCtrl = TextEditingController(
      text: renewalToEdit != null
          ? renewalToEdit.planPrice.toInt().toString()
          : '',
    );
    final addressCtrl = TextEditingController(
      text: renewalToEdit?.address ?? '',
    );
    DateTime selectedDueDate = renewalToEdit?.nextDueDate ??
        DateTime.now().add(const Duration(days: 365));
    RenewalStatus selectedStatus =
        renewalToEdit?.status ?? RenewalStatus.dueThisMonth;
    String? formError;

    showDialog(
      context: context,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (context, setDState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                isEditing
                    ? (tr('AMC प्लॅन अपडेट करा', 'Edit AMC Plan'))
                    : (tr('+ नवीन AMC प्लॅन जोडा', '+ Add AMC Plan')),
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (formError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            formError!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                      if (!isEditing && appState.users.any((u) => u.role == UserRole.customer)) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            tr('नोंदणीकृत ग्राहक निवडा:', 'Select Registered Customer:'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: appState.users
                                .where((u) => u.role == UserRole.customer)
                                .map((u) {
                              final isSelected = nameCtrl.text == u.name;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6, bottom: 8),
                                child: ActionChip(
                                  avatar: Icon(
                                    Icons.person,
                                    size: 14,
                                    color: isSelected ? Colors.white : AppColors.primary,
                                  ),
                                  label: Text(u.name.isNotEmpty ? u.name : u.phone),
                                  backgroundColor: isSelected ? AppColors.primary : Colors.white,
                                  labelStyle: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  onPressed: () {
                                    setDState(() {
                                      nameCtrl.text = u.name;
                                      final rawPh = u.phone.replaceAll(RegExp(r'[^0-9]'), '');
                                      phoneCtrl.text = rawPh.length >= 10
                                          ? rawPh.substring(rawPh.length - 10)
                                          : rawPh;
                                      if (addressCtrl.text.isEmpty) {
                                        for (final b in appState.bookings) {
                                          if ((b.customerPhone.contains(phoneCtrl.text) ||
                                                  b.customerName.toLowerCase() == u.name.toLowerCase()) &&
                                              b.address.isNotEmpty) {
                                            addressCtrl.text = b.address;
                                            break;
                                          }
                                        }
                                      }
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: tr('ग्राहकाचे नाव *', 'Customer Name *'),
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: tr('मोबाईल नंबर *', 'Phone Number *'),
                          counterText: '',
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: applianceCtrl,
                        decoration: InputDecoration(
                          labelText: tr('उपकरण / सर्व्हिस प्रकार *', 'Appliance Type *'),
                          hintText: tr('उदा. वॉटर प्युरिफायर (RO), एसी, फ्रीज', 'e.g. Water Purifier, AC, Refrigerator'),
                          prefixIcon: const Icon(
                            Icons.kitchen_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          'वॉटर प्युरिफायर (RO)',
                          'स्प्लिट एसी (1.5T)',
                          'वॉशिंग मशीन (FL)',
                          'रेफ्रिजरेटर (FF)',
                        ].map((app) {
                          final isSel = applianceCtrl.text == app;
                          return ChoiceChip(
                            label: Text(app),
                            labelStyle: TextStyle(
                              fontSize: 10.5,
                              color: isSel ? Colors.white : AppColors.textPrimary,
                            ),
                            selected: isSel,
                            selectedColor: const Color(0xFF0284C7),
                            onSelected: (sel) {
                              if (sel) {
                                setDState(() {
                                  applianceCtrl.text = app;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: brandModelCtrl,
                        decoration: InputDecoration(
                          labelText: tr('ब्रँड व मॉडेल *', 'Brand & Model *'),
                          hintText: tr('उदा. Kent Grand Plus RO', 'e.g. Kent Grand Plus RO'),
                          prefixIcon: const Icon(
                            Icons.devices_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: planNameCtrl,
                        decoration: InputDecoration(
                          labelText: tr('AMC प्लॅन नाव *', 'AMC Plan Name *'),
                          hintText: tr('उदा. 1 Year Comprehensive AMC', 'e.g. 1 Year Comprehensive AMC'),
                          prefixIcon: const Icon(
                            Icons.shield_outlined,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText:
                                    tr('किंमत (₹) *', 'Plan Price (₹) *'),
                                prefixIcon: const Icon(
                                  Icons.currency_rupee_rounded,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<RenewalStatus>(
                              initialValue: selectedStatus,
                              decoration: InputDecoration(
                                labelText: tr('स्थिती', 'Status'),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                              items: RenewalStatus.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    tr(s.labelMr, s.labelEn),
                                    style: const TextStyle(fontSize: 11.5),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setDState(() => selectedStatus = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dCtx,
                            initialDate: selectedDueDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );
                          if (picked != null) {
                            setDState(() => selectedDueDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: tr('रिन्युअल / पुढील मुदत तारीख', 'Renewal Due Date'),
                            prefixIcon: const Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            AppHelpers.formatDate(selectedDueDate),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: addressCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: tr('ग्राहकाचा पत्ता', 'Customer Address'),
                          hintText: tr('उदा. फ्लॅट २०४, सनशाइन सोसायटी, पुणे', 'e.g. Flat 204, Sunshine Society, Pune'),
                          prefixIcon: const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dCtx),
                  child: Text(tr('रद्द', 'Cancel')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final cName = nameCtrl.text.trim();
                    final cPhone = phoneCtrl.text.trim();
                    final aName = applianceCtrl.text.trim();
                    final bModel = brandModelCtrl.text.trim();
                    final pName = planNameCtrl.text.trim();
                    final price =
                        double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                    final addr = addressCtrl.text.trim();

                    if (cName.isEmpty ||
                        cPhone.isEmpty ||
                        bModel.isEmpty ||
                        price <= 0) {
                      setDState(
                        () => formError = tr('कृपया नाव, मोबाईल, मॉडेल आणि वैध किंमत भरा.', 'Please enter name, phone, model, and valid price.'),
                      );
                      return;
                    }

                    if (cPhone.length != 10) {
                      setDState(
                        () => formError = tr('कृपया किमान १० अंकी वैध मोबाईल नंबर टाका.', 'Please enter a valid 10-digit phone number.'),
                      );
                      return;
                    }

                    // Auto-link customer from registered users if exists
                    UserAccount? matchedUser;
                    final cleanPhone = cPhone.replaceAll(RegExp(r'[^0-9]'), '');
                    for (final u in appState.users) {
                      final uClean = u.phone.replaceAll(RegExp(r'[^0-9]'), '');
                      if ((cleanPhone.isNotEmpty && (uClean.endsWith(cleanPhone) || cleanPhone.endsWith(uClean))) ||
                          (u.name.trim().toLowerCase() == cName.toLowerCase())) {
                        matchedUser = u;
                        break;
                      }
                    }

                    final finalAddr = addr.trim();

                    final contractNo = renewalToEdit?.contractNo ??
                        'AMC-YM-${DateTime.now().year}-${(1000 + DateTime.now().millisecondsSinceEpoch % 9000)}';

                    final eqList = [
                      AmcEquipmentItem(
                        applianceName: aName,
                        brandModel: bModel,
                        serialNo: '',
                        quantity: 1,
                        location: '',
                      ),
                    ];

                    final checkList = [
                      const AmcChecklistItem(
                        checkPoint: 'कुलिंग कॉइल व एअर फिल्टर स्वच्छता (Jet Wash)',
                        status: 'पूर्ण (Done)',
                        remarks: 'जेट वॉशने स्वच्छ केले',
                      ),
                      const AmcChecklistItem(
                        checkPoint: 'कॉम्प्रेसर ॲम्पियर व व्होल्टेज टेस्ट',
                        status: 'योग्य (OK)',
                        remarks: '5.8A (योग्य लोड)',
                      ),
                      const AmcChecklistItem(
                        checkPoint: 'आरओ टीडीएस पातळी व पाणी गळती टेस्ट',
                        status: 'योग्य (OK)',
                        remarks: 'TDS व फिल्टर तपासणी पूर्ण',
                      ),
                      const AmcChecklistItem(
                        checkPoint: 'अर्थिंग, वायरिंग व सुरक्षितता तपासणी',
                        status: 'सुरक्षित (Safe)',
                        remarks: 'अर्थिंग व्होल्टेज योग्य',
                      ),
                    ];

                    if (isEditing) {
                      final updated = renewalToEdit.copyWith(
                        customerId: matchedUser?.id ?? renewalToEdit.customerId,
                        contractNo: renewalToEdit.contractNo ?? contractNo,
                        customerName: cName,
                        customerPhone: cPhone,
                        applianceName:
                            aName.isNotEmpty ? aName : 'अप्लायन्स AMC',
                        brandModel: bModel,
                        planName: pName.isNotEmpty ? pName : 'वार्षिक AMC',
                        planPrice: price,
                        nextDueDate: selectedDueDate,
                        status: selectedStatus,
                        address: finalAddr,
                        equipmentList: (renewalToEdit.equipmentList != null && renewalToEdit.equipmentList!.isNotEmpty)
                            ? renewalToEdit.equipmentList
                            : eqList,
                        checklist: (renewalToEdit.checklist != null && renewalToEdit.checklist!.isNotEmpty)
                            ? renewalToEdit.checklist
                            : checkList,
                      );
                      appState.updateRenewal(updated);
                    } else {
                      final newRenewal = AmcRenewal(
                        id: 'amc_${DateTime.now().millisecondsSinceEpoch}',
                        customerId: matchedUser?.id,
                        contractNo: contractNo,
                        customerName: cName,
                        customerPhone: cPhone,
                        applianceName: aName,
                        brandModel: bModel,
                        lastServiceDate: DateTime.now(),
                        nextDueDate: selectedDueDate,
                        planName: pName.isNotEmpty
                            ? pName
                            : (aName.isNotEmpty ? '$aName AMC' : 'AMC Plan'),
                        planPrice: price,
                        status: selectedStatus,
                        address: finalAddr,
                        equipmentList: eqList,
                        checklist: checkList,
                      );
                      appState.addRenewal(newRenewal);
                    }

                    Navigator.pop(dCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.success,
                        content: Text(
                          isEditing
                              ? (tr('AMC प्लॅन अपडेट झाला!', 'AMC plan updated!'))
                              : (tr('नवीन AMC प्लॅन जोडला गेला!', 'AMC plan added successfully!')),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    isEditing
                        ? (tr('अपडेट करा', 'Update'))
                        : (tr('जोडा', 'Add')),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ========================================================
  // TAB 5: ANALYTICS & REVENUE OVERVIEW
  // ========================================================
  Widget _buildAnalyticsTab(AppState appState, bool isMr) {
    final totalBookings = appState.bookings.length;
    final completedBookings = appState.bookings
        .where((b) => b.status == BookingStatus.completed)
        .length;
    final totalRevenue = appState.bookings
        .where((b) => b.isPaid)
        .fold(0.0, (sum, b) => sum + b.totalAmount);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('व्यवसाय डॅशबोर्ड व महसूल', 'Business Operations & Revenue KPIs'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: tr('एकूण बुकिंग्ज', 'Total Bookings'),
                  value: '$totalBookings',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  onTap: () => _showTotalBookingsSheet(context, appState, isMr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: tr('पूर्ण झालेली कामे', 'Completed Jobs'),
                  value: '$completedBookings',
                  icon: Icons.task_alt_rounded,
                  color: AppColors.success,
                  onTap: () => _showCompletedJobsSheet(context, appState, isMr),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: tr('सक्रिय कामगार', 'Active Technicians'),
                  value: '${appState.technicians.length}',
                  icon: Icons.engineering_rounded,
                  color: AppColors.warning,
                  onTap: () => _showTechniciansSheet(context, appState, isMr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: tr('रिन्युअल्स ट्रॅक', 'AMC Tracked'),
                  value: '${appState.renewals.length}',
                  icon: Icons.autorenew_rounded,
                  color: const Color(0xFF7C3AED),
                  onTap: () => _showAmcRenewalsSheet(context, appState, isMr),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Total Revenue Card (Clickable to view detailed breakdown)
          AppCard(
            padding: EdgeInsets.zero,
            child: InkWell(
              onTap: () => _showRevenueBreakdownSheet(context, appState, isMr),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.adminGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppColors.coloredShadow(
                    AppColors.adminDark,
                    opacity: 0.3,
                    blur: 14,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr('गोळा झालेला एकूण महसूल', 'Total Revenue Collected'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tr('तपशील पहा', 'View Details'),
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.greenAccent,
                                size: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppHelpers.formatCurrency(totalRevenue),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: Colors.greenAccent,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tr('रिअल-टाइम रोख आणि UPI डिजिटल ताळमेळ सक्रिय', 'Real-time cash & UPI digital reconciliation active'),
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================
  // REUSABLE BOTTOM SHEET HELPER
  // ========================================================
  void _showModalSheet({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget Function(BuildContext sheetCtx, ScrollController scrollController)
        contentBuilder,
    Widget? actionButton,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (sheetCtx, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 42,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Sheet Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 12, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: iconColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  // Scrollable Content
                  Expanded(
                    child: contentBuilder(sheetCtx, scrollController),
                  ),
                  // Bottom Action Button
                  if (actionButton != null) ...[
                    const Divider(height: 1, color: AppColors.border),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      child: SafeArea(
                        top: false,
                        child: actionButton,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ========================================================
  // 1. TOTAL BOOKINGS DETAILS SHEET
  // ========================================================
  void _showTotalBookingsSheet(
    BuildContext context,
    AppState appState,
    bool isMr,
  ) {
    String selectedFilter = 'all';

    _showModalSheet(
      context: context,
      title: tr('एकूण बुकिंग्ज (${appState.bookings.length})', 'Total Bookings (${appState.bookings.length})'),
      subtitle: tr('सर्व चालू, प्रलंबित व पूर्ण झालेली कामे', 'All live, pending & finished bookings'),
      icon: Icons.receipt_long_rounded,
      iconColor: AppColors.primary,
      actionButton: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.adminDark,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.alt_route_rounded, size: 18),
        label: Text(
          tr('डिस्पेच टॅबवर जा', 'Open in Dispatch Tab'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.pop(context);
          _tabController.animateTo(0);
        },
      ),
      contentBuilder: (sheetCtx, scrollController) {
        return StatefulBuilder(
          builder: (stCtx, setSheetState) {
            final allBookings = appState.bookings;
            final filteredBookings = allBookings.where((b) {
              if (selectedFilter == 'pending') {
                return b.status == BookingStatus.pending;
              }
              if (selectedFilter == 'active') {
                return b.status == BookingStatus.assigned ||
                    b.status == BookingStatus.onTheWay ||
                    b.status == BookingStatus.inProgress;
              }
              if (selectedFilter == 'completed') {
                return b.status == BookingStatus.completed;
              }
              if (selectedFilter == 'cancelled') {
                return b.status == BookingStatus.cancelled;
              }
              return true;
            }).toList();

            return Column(
              children: [
                // Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      _buildSheetFilterChip(
                        label: tr('सर्व (${allBookings.length})', 'All (${allBookings.length})'),
                        selected: selectedFilter == 'all',
                        onTap: () => setSheetState(() => selectedFilter = 'all'),
                      ),
                      const SizedBox(width: 6),
                      _buildSheetFilterChip(
                        label: tr('प्रलंबित', 'Pending'),
                        selected: selectedFilter == 'pending',
                        onTap: () =>
                            setSheetState(() => selectedFilter = 'pending'),
                      ),
                      const SizedBox(width: 6),
                      _buildSheetFilterChip(
                        label: tr('सक्रिय कामे', 'Active'),
                        selected: selectedFilter == 'active',
                        onTap: () =>
                            setSheetState(() => selectedFilter = 'active'),
                      ),
                      const SizedBox(width: 6),
                      _buildSheetFilterChip(
                        label: tr('पूर्ण झालेली', 'Completed'),
                        selected: selectedFilter == 'completed',
                        onTap: () =>
                            setSheetState(() => selectedFilter = 'completed'),
                      ),
                      const SizedBox(width: 6),
                      _buildSheetFilterChip(
                        label: tr('रद्द', 'Cancelled'),
                        selected: selectedFilter == 'cancelled',
                        onTap: () =>
                            setSheetState(() => selectedFilter = 'cancelled'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                // Bookings List
                Expanded(
                  child: filteredBookings.isEmpty
                      ? _buildEmptyState(
                          icon: Icons.receipt_long_rounded,
                          title: tr('कोणतीही बुकिंग्ज उपलब्ध नाहीत', 'No bookings in this filter'),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredBookings.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (ctx, i) {
                            final b = filteredBookings[i];
                            return _buildBookingDetailCard(context, b, isMr);
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ========================================================
  // 2. COMPLETED JOBS SHEET
  // ========================================================
  void _showCompletedJobsSheet(
    BuildContext context,
    AppState appState,
    bool isMr,
  ) {
    final completedList = appState.bookings
        .where((b) => b.status == BookingStatus.completed)
        .toList();
    final completedRevenue =
        completedList.fold(0.0, (s, b) => s + b.totalAmount);

    _showModalSheet(
      context: context,
      title: tr('पूर्ण झालेली कामे (${completedList.length})', 'Completed Jobs (${completedList.length})'),
      subtitle: tr('यशस्वीरीत्या पूर्ण झालेल्या सर्व सर्व्हिसेस', 'All successfully completed service orders'),
      icon: Icons.task_alt_rounded,
      iconColor: AppColors.success,
      actionButton: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.adminDark,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.alt_route_rounded, size: 18),
        label: Text(
          tr('डिस्पेच टॅबवर जा', 'Open in Dispatch Tab'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.pop(context);
          _tabController.animateTo(0);
        },
      ),
      contentBuilder: (sheetCtx, scrollController) {
        if (completedList.isEmpty) {
          return _buildEmptyState(
            icon: Icons.task_alt_rounded,
            title: tr('सध्या कोणतेही पूर्ण झालेले काम नाही', 'No completed jobs yet'),
          );
        }

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Revenue Summary Banner
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('पूर्ण कामांचे एकूण मूल्य', 'Completed Jobs Revenue'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF166534),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppHelpers.formatCurrency(completedRevenue),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${completedList.length} ${tr("ऑर्डर्स", "Orders")}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...completedList.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBookingDetailCard(context, b, isMr),
              ),
            ),
          ],
        );
      },
    );
  }

  // ========================================================
  // 3. ACTIVE TECHNICIANS SHEET
  // ========================================================
  void _showTechniciansSheet(
    BuildContext context,
    AppState appState,
    bool isMr,
  ) {
    final technicians = appState.technicians;
    final onlineCount = technicians.where((t) => t.isOnline).length;

    _showModalSheet(
      context: context,
      title: tr('सक्रिय कामगार / पार्टनर्स (${technicians.length})', 'Active Technicians (${technicians.length})'),
      subtitle: tr('सांगली, मिरज, कराड परिसरातील पार्टनर्स', 'Registered field service partners'),
      icon: Icons.engineering_rounded,
      iconColor: AppColors.warning,
      actionButton: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.adminDark,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.people_alt_rounded, size: 18),
        label: Text(
          tr('पार्टनर्स व्यवस्थापनावर जा', 'Open in Partners Tab'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.pop(context);
          _tabController.animateTo(2);
        },
      ),
      contentBuilder: (sheetCtx, scrollController) {
        if (technicians.isEmpty) {
          return _buildEmptyState(
            icon: Icons.engineering_rounded,
            title: tr('कोणतेही कामगार नोंदणीकृत नाहीत', 'No technicians registered'),
          );
        }

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Status bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${tr("ऑनलाईन", "Online")}: $onlineCount',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 16,
                    color: const Color(0xFFCBD5E1),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${tr("ऑफलाईन", "Offline")}: ${technicians.length - onlineCount}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ...technicians.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTechnicianSheetCard(context, t, isMr),
              ),
            ),
          ],
        );
      },
    );
  }

  // ========================================================
  // 4. AMC RENEWALS SHEET
  // ========================================================
  void _showAmcRenewalsSheet(
    BuildContext context,
    AppState appState,
    bool isMr,
  ) {
    final renewals = appState.renewals;

    _showModalSheet(
      context: context,
      title: tr('AMC रिन्युअल्स ट्रॅक (${renewals.length})', 'AMC Tracked (${renewals.length})'),
      subtitle: tr('वार्षिक देखभाल करार (AMC) चे ट्रॅकिंग', 'Annual maintenance contract renewals'),
      icon: Icons.autorenew_rounded,
      iconColor: const Color(0xFF7C3AED),
      actionButton: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.adminDark,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.autorenew_rounded, size: 18),
        label: Text(
          tr('रिन्युअल्स व्यवस्थापनावर जा', 'Open in Renewals Tab'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.pop(context);
          _tabController.animateTo(3);
        },
      ),
      contentBuilder: (sheetCtx, scrollController) {
        if (renewals.isEmpty) {
          return _buildEmptyState(
            icon: Icons.autorenew_rounded,
            title: tr('सध्या कोणतेही प्रलंबित रिन्युअल नाही', 'No AMC renewals tracked right now'),
            subtitle: tr('नवीन ग्राहकांचे AMC करार जोडल्यावर ते इथे दिसतील.', 'Contracts added for customers will be tracked here.'),
          );
        }

        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: renewals.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final r = renewals[i];
            return _buildAmcSheetCard(context, r, isMr);
          },
        );
      },
    );
  }

  // ========================================================
  // 5. REVENUE BREAKDOWN SHEET
  // ========================================================
  void _showRevenueBreakdownSheet(
    BuildContext context,
    AppState appState,
    bool isMr,
  ) {
    final paidBookings = appState.bookings.where((b) => b.isPaid).toList();
    final totalRevenue =
        paidBookings.fold(0.0, (s, b) => s + b.totalAmount);
    final upiBookings = paidBookings
        .where((b) => b.paymentMethod == PaymentMethod.upiOnline)
        .toList();
    final codBookings = paidBookings
        .where((b) => b.paymentMethod == PaymentMethod.cashOnDelivery)
        .toList();
    final upiTotal = upiBookings.fold(0.0, (s, b) => s + b.totalAmount);
    final codTotal = codBookings.fold(0.0, (s, b) => s + b.totalAmount);

    _showModalSheet(
      context: context,
      title: tr('गोळा झालेला महसूल तपशील', 'Revenue Collection Breakdown'),
      subtitle: tr('डिजिटल UPI व कॅश कलेक्शनचा संपूर्ण ताळमेळ', 'Complete cash & online reconciliation'),
      icon: Icons.currency_rupee_rounded,
      iconColor: Colors.green,
      actionButton: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.adminDark,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.receipt_long_rounded, size: 18),
        label: Text(
          tr('डिस्पेच टॅबवर जा', 'Open in Dispatch Tab'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.pop(context);
          _tabController.animateTo(0);
        },
      ),
      contentBuilder: (sheetCtx, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Big Revenue Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.adminGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.coloredShadow(
                  AppColors.adminDark,
                  opacity: 0.25,
                  blur: 10,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('एकूण जमा रक्कम', 'Total Revenue Collected'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppHelpers.formatCurrency(totalRevenue),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // UPI Pill
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 14,
                                    color: Colors.greenAccent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tr('UPI डिजिटल', 'Online UPI'),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppHelpers.formatCurrency(upiTotal),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              Text(
                                '${upiBookings.length} ${tr("ऑर्डर्स", "orders")}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Cash Pill
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.handshake_outlined,
                                    size: 14,
                                    color: Colors.orangeAccent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tr('कॅश (रोख)', 'Cash / COD'),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppHelpers.formatCurrency(codTotal),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                              Text(
                                '${codBookings.length} ${tr("ऑर्डर्स", "orders")}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('यशस्वी ट्रान्झॅक्शन्स (${paidBookings.length})', 'Paid Transactions (${paidBookings.length})'),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  tr('ताळमेळ पूर्ण', 'Reconciled'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (paidBookings.isEmpty)
              _buildEmptyState(
                icon: Icons.currency_rupee_rounded,
                title: tr('अद्याप कोणतेही पेमेंट प्राप्त नाही', 'No paid transactions yet'),
              )
            else
              ...paidBookings.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildRevenueTransactionCard(context, b, isMr),
                ),
              ),
          ],
        );
      },
    );
  }

  // ========================================================
  // SHEET HELPER WIDGETS
  // ========================================================
  Widget _buildSheetFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.adminDark : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.adminDark : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailCard(
    BuildContext context,
    Booking booking,
    bool isMr,
  ) {
    Color statusColor;
    switch (booking.status) {
      case BookingStatus.pending:
        statusColor = AppColors.warning;
        break;
      case BookingStatus.assigned:
      case BookingStatus.onTheWay:
      case BookingStatus.inProgress:
        statusColor = AppColors.primary;
        break;
      case BookingStatus.completed:
        statusColor = AppColors.success;
        break;
      case BookingStatus.cancelled:
        statusColor = AppColors.error;
        break;
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: ID, Slot, Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${booking.id} • ${booking.scheduledSlot}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tr(booking.status.nameMr, booking.status.nameEn),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Service Title & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tr(booking.service.titleMr, booking.service.titleEn),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                AppHelpers.formatCurrency(booking.totalAmount),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Customer Name & Phone
          Row(
            children: [
              const Icon(
                Icons.person_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                booking.customerName,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (booking.customerPhone.isNotEmpty) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () =>
                      AppHelpers.makePhoneCall(booking.customerPhone, context),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 12,
                          color: Color(0xFF0F766E),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          booking.customerPhone,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Customer Address Box (Clickable for Google Maps)
          InkWell(
            borderRadius: BorderRadius.circular(8),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.address.isNotEmpty
                          ? '${booking.address}${booking.landmark.isNotEmpty ? " (${booking.landmark})" : ""}'
                          : (tr('पत्ता उपलब्ध नाही', 'No address provided')),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.open_in_new_rounded,
                    size: 13,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
          ),

          if (booking.technicianName != null &&
              booking.technicianName!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.engineering_rounded,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${tr("कामगार:", "Technician:")} ${booking.technicianName}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTechnicianSheetCard(
    BuildContext context,
    Technician tech,
    bool isMr,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.warning,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppHelpers.localizedText(tech.name, isMr),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppHelpers.localizedText(tech.locationArea, isMr),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: tech.isOnline
                      ? AppColors.successLight
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: tech.isOnline ? AppColors.success : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tech.isOnline
                          ? (tr('ऑनलाईन', 'Online'))
                          : (tr('ऑफलाईन', 'Offline')),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: tech.isOnline
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Phone & Call
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📞 ${tech.phone}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F766E),
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF059669),
                  side: const BorderSide(color: Color(0xFFA7F3D0)),
                  backgroundColor: const Color(0xFFECFDF5),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: const Icon(Icons.phone_rounded, size: 12),
                label: Text(
                  tr('कॉल करा', 'Call'),
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
                onPressed: () => AppHelpers.makePhoneCall(tech.phone, context),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Skills
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: tech.skills.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  AppHelpers.localizedText(s, isMr),
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Stats: Today's jobs & earnings
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${tr("आजची कामे:", "Today Jobs:")} ${tech.todayCompletedJobs}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${tr("आजची कमाई:", "Today Earnings:")} ${AppHelpers.formatCurrency(tech.todayEarnings)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  '⭐ ${tech.rating.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmcSheetCard(
    BuildContext context,
    AmcRenewal renewal,
    bool isMr,
  ) {
    Color statusColor;
    switch (renewal.status) {
      case RenewalStatus.dueThisWeek:
        statusColor = AppColors.error;
        break;
      case RenewalStatus.dueThisMonth:
        statusColor = AppColors.warning;
        break;
      case RenewalStatus.overdue:
        statusColor = const Color(0xFFB91C1C);
        break;
      case RenewalStatus.renewed:
        statusColor = AppColors.success;
        break;
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  renewal.applianceName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tr(renewal.status.labelMr, renewal.status.labelEn),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${renewal.brandModel} • ${renewal.planName}',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                renewal.customerName,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              Text(
                AppHelpers.formatCurrency(renewal.planPrice),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📞 ${renewal.customerPhone}',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF0F766E),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${tr("मुदत:", "Due:")} ${AppHelpers.formatDate(renewal.nextDueDate)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: renewal.daysRemaining < 0
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),

          if (renewal.address.isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                AppHelpers.openGoogleMaps(
                  address: renewal.address,
                  context: context,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        renewal.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new_rounded,
                      size: 11,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRevenueTransactionCard(
    BuildContext context,
    Booking booking,
    bool isMr,
  ) {
    final isUpi = booking.paymentMethod == PaymentMethod.upiOnline;

    return AppCard(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tr(booking.service.titleMr, booking.service.titleEn),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                AppHelpers.formatCurrency(booking.totalAmount),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${booking.customerName} • #${booking.id}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isUpi
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUpi
                          ? Icons.qr_code_2_rounded
                          : Icons.handshake_outlined,
                      size: 12,
                      color: isUpi
                          ? const Color(0xFF15803D)
                          : const Color(0xFFB45309),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      isUpi
                          ? (tr('UPI प्राप्त', 'UPI Online'))
                          : (tr('कॅश प्राप्त', 'Cash Received')),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isUpi
                          ? const Color(0xFF15803D)
                          : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (booking.technicianName != null &&
                  booking.technicianName!.isNotEmpty)
                Text(
                  '${tr("कामगार:", "Tech:")} ${booking.technicianName}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                const SizedBox(),
              Text(
                AppHelpers.formatDate(booking.scheduledDate),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
