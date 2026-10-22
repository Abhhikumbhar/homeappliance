import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../models/appliance_service.dart';
import '../../state/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import '../../widgets/design_components.dart';
import 'live_tracking_screen.dart';

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({super.key});

  @override
  State<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    final allBookings = List<Booking>.from(appState.customerBookings)
      ..sort((a, b) {
        final aIsActive = a.status != BookingStatus.completed &&
            a.status != BookingStatus.cancelled;
        final bIsActive = b.status != BookingStatus.completed &&
            b.status != BookingStatus.cancelled;
        if (aIsActive && !bIsActive) return -1;
        if (!aIsActive && bIsActive) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

    final activeBookings = allBookings.where((b) {
      return b.status != BookingStatus.completed &&
          b.status != BookingStatus.cancelled;
    }).toList();

    final completedBookings = allBookings.where((b) {
      return b.status == BookingStatus.completed ||
          b.status == BookingStatus.cancelled;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          tr('सर्व्हिस विनंती ट्रॅकिंग', 'Track Service Requests'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                tabs: [
                  Tab(text: '${tr("सर्व", "All")} (${allBookings.length})'),
                  Tab(
                    text:
                        '${tr("चालू", "Active")} (${activeBookings.length})',
                  ),
                  Tab(
                    text:
                        '${tr("पूर्ण", "Completed")} (${completedBookings.length})',
                  ),
                ],
              ),
              Container(color: AppColors.border, height: 1),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(allBookings, isMr, context),
          _buildBookingList(activeBookings, isMr, context),
          _buildBookingList(completedBookings, isMr, context),
        ],
      ),
    );
  }

  Widget _buildBookingList(
    List<Booking> bookings,
    bool isMr,
    BuildContext context,
  ) {
    if (bookings.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.receipt_long_outlined,
          title: tr('कोणतीही विनंती सापडली नाही', 'No Service Requests'),
          description: tr('आपण होम स्क्रीनवरून घरातील उपकरणांची सर्व्हिस बुक करू शकता.', 'You have no service requests in this list. Explore our services to book one.'),
          actionLabel: tr('सेवा एक्सप्लोर करा', 'Explore Services'),
          onAction: () => Navigator.pop(context),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _buildTrackingCard(context, bookings[index], isMr);
      },
    );
  }

  Widget _buildTrackingCard(BuildContext context, Booking booking, bool isMr) {
    Color statusColor;
    IconData statusIcon;
    switch (booking.status) {
      case BookingStatus.pending:
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case BookingStatus.assigned:
        statusColor = AppColors.primary;
        statusIcon = Icons.person_pin_rounded;
        break;
      case BookingStatus.onTheWay:
        statusColor = AppColors.info;
        statusIcon = Icons.two_wheeler_rounded;
        break;
      case BookingStatus.inProgress:
        statusColor = const Color(0xFF7C3AED);
        statusIcon = Icons.build_circle_rounded;
        break;
      case BookingStatus.completed:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case BookingStatus.cancelled:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Request ID & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        booking.service.category.icon,
                        size: 17,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'REQ #${booking.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12.5, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        tr(booking.status.nameMr, booking.status.nameEn),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Service Title & Scheduled Slot
            Text(
              tr(booking.service.titleMr, booking.service.titleEn),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (booking.brand != null ||
                booking.machineType != null ||
                booking.problem != null) ...[
              const SizedBox(height: 5),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (booking.brand != null && booking.brand!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Brand: ${booking.brand}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  if (booking.machineType != null && booking.machineType!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        booking.machineType!,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6D28D9),
                        ),
                      ),
                    ),
                  if (booking.problem != null && booking.problem!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        booking.problem!,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.event_available,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${AppHelpers.formatDate(booking.scheduledDate)} • ${booking.scheduledSlot}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${booking.address} (${booking.landmark})',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Milestone Stepper
            _buildMilestoneStepper(booking.status, isMr),
            const SizedBox(height: 12),

            // Pending Approval Note
            if (booking.status == BookingStatus.pending) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warningBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.hourglass_top_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr('बुकिंग ॲडमिनकडे मंजुरीसाठी पाठवले आहे. मंजुरीनंतर कामगार निघेल.', 'Booking is awaiting Admin approval. Technician will be dispatched once approved.'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Start OTP Coupon Box
            if (booking.status != BookingStatus.completed &&
                booking.status != BookingStatus.cancelled) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFDE68A),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_clock_rounded,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('सुरक्षित सर्व्हिस सुरू OTP', 'Start Service OTP'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.startOtp,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tr('कामगाराला द्या', 'Share with Tech'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Assigned Partner Info Card
            if (booking.technicianName != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.partnerTheme,
                      child: Icon(
                        Icons.engineering_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.technicianName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                          Text(
                            tr('प्रमाणित सर्व्हिस पार्टनर', 'Certified Service Partner'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // WhatsApp Button
                    IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_rounded,
                        color: Color(0xFF25D366),
                        size: 22,
                      ),
                      tooltip: 'WhatsApp',
                      onPressed: (booking.technicianPhone != null &&
                              booking.technicianPhone!.isNotEmpty)
                          ? () => AppHelpers.openWhatsApp(
                                phone: booking.technicianPhone!,
                                message:
                                    'Hello, regarding Service Request #${booking.id}',
                                context: context,
                              )
                          : null,
                    ),
                    // Call Button
                    IconButton(
                      icon: const Icon(
                        Icons.phone_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      tooltip: 'Call',
                      onPressed: (booking.technicianPhone != null &&
                              booking.technicianPhone!.isNotEmpty)
                          ? () => AppHelpers.makePhoneCall(
                                booking.technicianPhone!,
                                context,
                              )
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Apple iOS 18 Live GPS & Dynamic Island Tracking Button
            if (booking.status != BookingStatus.completed &&
                booking.status != BookingStatus.cancelled) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LiveTrackingScreen(booking: booking),
                      ),
                    );
                  },
                  icon: const Icon(Icons.navigation_rounded, size: 16),
                  label: Text(
                    tr('थेट GPS ट्रॅकिंग व Dynamic Island उघडा', 'Track Live on Apple Maps & Dynamic Island'),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.iosSystemBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            // Spare parts if added
            if (booking.sparePartsAdded.isNotEmpty) ...[
              Text(
                tr('अतिरिक्त सुटे भाग:', 'Spare Parts Added:'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ...booking.sparePartsAdded.map(
                (part) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '• $part',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),

            // Total & Payment Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${tr("एकूण बिल:", "Total Bill:")} ${AppHelpers.formatCurrency(booking.totalAmount)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: booking.isPaid
                        ? AppColors.successLight
                        : AppColors.warningLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: booking.isPaid
                          ? AppColors.successBorder
                          : AppColors.warningBorder,
                    ),
                  ),
                  child: Text(
                    booking.isPaid
                        ? (tr('✓ पेमेंट पूर्ण', '✓ Paid'))
                        : (tr('पेमेंट बाकी', 'Pay on Delivery')),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: booking.isPaid
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneStepper(BookingStatus status, bool isMr) {
    final int currentStep;
    switch (status) {
      case BookingStatus.pending:
        currentStep = 0;
        break;
      case BookingStatus.assigned:
      case BookingStatus.onTheWay:
        currentStep = 1;
        break;
      case BookingStatus.inProgress:
        currentStep = 2;
        break;
      case BookingStatus.completed:
        currentStep = 3;
        break;
      case BookingStatus.cancelled:
        currentStep = -1;
        break;
    }

    if (currentStep == -1) return const SizedBox.shrink();

    final steps = [
      tr('नोंदवले', 'Placed'),
      tr('सोपवले', 'Assigned'),
      tr('चालू', 'Working'),
      tr('पूर्ण', 'Done'),
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          final isDone = currentStep > stepIndex;
          return Expanded(
            child: Container(
              height: 2.5,
              color: isDone ? AppColors.primary : AppColors.border,
            ),
          );
        } else {
          final stepIndex = index ~/ 2;
          final isReached = currentStep >= stepIndex;
          final isCurrent = currentStep == stepIndex;

          return Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isReached ? AppColors.primary : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isReached ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: isReached
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  color: isCurrent
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
