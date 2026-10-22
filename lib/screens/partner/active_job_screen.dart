import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/booking.dart';
import '../../state/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import '../../widgets/design_components.dart';

class ActiveJobScreen extends StatefulWidget {
  final String bookingId;

  const ActiveJobScreen({super.key, required this.bookingId});

  @override
  State<ActiveJobScreen> createState() => _ActiveJobScreenState();
}

class _ActiveJobScreenState extends State<ActiveJobScreen> {
  final _otpController = TextEditingController();
  final _partNameController = TextEditingController();
  final _partCostController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    _partNameController.dispose();
    _partCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isMr = appState.isMarathi;

    // Find current booking
    final booking = appState.bookings
        .where((b) => b.id == widget.bookingId)
        .firstOrNull;

    if (booking == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            tr('कामाचा तपशील', 'Job Action'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.partnerDark,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: EmptyStateWidget(
            icon: Icons.search_off_rounded,
            title: tr('बुकिंग सापडले नाही', 'Job Not Found'),
            description: tr('हे काम उपलब्ध नाही किंवा रद्द करण्यात आले आहे.', 'This job is no longer available or has been cancelled.'),
            actionLabel: tr('मागे जा', 'Go Back'),
            onAction: () => Navigator.pop(context),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${tr("कामाचा तपशील", "Job Action")} - ${booking.id}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.partnerDark,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Customer & Location Card (Google Maps, WhatsApp & Call Actions)
            _buildCustomerCard(context, appState, booking, isMr),
            const SizedBox(height: 16),

            // 2. Job Progress Tracker
            _buildStatusTracker(booking, isMr),
            const SizedBox(height: 16),

            // 3. OTP Verification Gate (To start job)
            if (booking.status == BookingStatus.assigned ||
                booking.status == BookingStatus.onTheWay)
              _buildOtpStartBox(context, appState, booking, isMr),

            // 4. In Progress Controls (Add Spare Parts & Complete)
            if (booking.status == BookingStatus.inProgress) ...[
              _buildSparePartsBox(context, appState, booking, isMr),
              const SizedBox(height: 16),
              _buildCompleteJobBox(context, appState, booking, isMr),
            ],

            // 5. If Completed: Summary & Payment Receipt
            if (booking.status == BookingStatus.completed)
              _buildCompletedReceiptBox(booking, isMr),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(
    BuildContext context,
    AppState appState,
    Booking booking,
    bool isMr,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Customer Name & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking.customerName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.successBorder),
                ),
                child: Text(
                  tr('सोपवलेले काम', 'Assigned Job'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2. Customer Phone & Quick Call Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: Color(0xFF0F766E),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${tr("ग्राहकाचा फोन:", "Phone:")} ${booking.customerPhone}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => AppHelpers.makePhoneCall(booking.customerPhone, context),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.call, size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          tr('कॉल', 'Call'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Address Section (With Clean Spacing, Full Multi-line & Landmark)
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
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tr('ग्राहकाचा पत्ता (Address)', 'Customer Service Address'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 14,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    booking.address.isNotEmpty
                        ? booking.address
                        : (tr('पत्ता उपलब्ध नाही', 'No address provided')),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (booking.landmark.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flag_rounded, size: 13, color: AppColors.accent),
                          const SizedBox(width: 5),
                          Text(
                            '${tr("जवळची खूण:", "Landmark:")} ${booking.landmark}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 4. Service & Issue Notes (Well Spaced Box)
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
                      Icons.build_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tr(booking.service.titleMr, booking.service.titleEn),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (booking.brand != null ||
                    booking.machineType != null ||
                    booking.problem != null) ...[
                  const SizedBox(height: 6),
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
                if (booking.notes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${tr("तक्रार / समस्या:", "Issue:")} ${booking.notes}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.35,
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

          // 5. Scheduled Slot & Total Bill Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          booking.scheduledSlot,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.successBorder),
                ),
                child: Text(
                  AppHelpers.formatCurrency(booking.totalAmount),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),

          // If partner is assigned, allow marking "On The Way"
          if (booking.status == BookingStatus.assigned) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.two_wheeler_rounded, size: 18),
                label: Text(
                  tr('मी निघत आहे', 'Start Travel'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  appState.partnerOnTheWay(booking.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        tr('ग्राहकाला तुम्ही निघाल्याचा अलर्ट पाठवला!', 'Status updated to On The Way!'),
                      ),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // 6. Quick Action Buttons Row (Maps, WhatsApp, Call)
          Row(
            children: [
              // Google Maps Navigation
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E40AF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.navigation_rounded, size: 17),
                  label: Text(
                    tr('गुगल मॅप्स रस्ता', 'Open Maps'),
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
                      directNavigation: true,
                      context: context,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Direct WhatsApp Concierge
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                label: const Text(
                  'WhatsApp',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  AppHelpers.openWhatsApp(
                    phone: booking.customerPhone,
                    message: tr('नमस्कार! मी आपल्या घरी होम अप्लायन्स दुरुस्तीसाठी येत आहे (बुकिंग #${booking.id}).', 'Hello! I am on the way to your address for service booking #${booking.id}.'),
                    context: context,
                  );
                },
              ),
              const SizedBox(width: 8),

              // Direct Phone Call
              Container(
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.successBorder),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.phone_rounded,
                    color: AppColors.success,
                    size: 21,
                  ),
                  onPressed: () =>
                      AppHelpers.makePhoneCall(booking.customerPhone, context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 7. Full Job Assignment Message Preview / Share Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: Color(0xFFBFDBFE)),
              backgroundColor: const Color(0xFFEFF6FF),
              minimumSize: const Size(double.infinity, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.receipt_long_rounded, size: 16),
            label: Text(
              tr('कामाचा संपूर्ण मेसेज पहा / शेअर करा', 'View / Share Full Job Assignment Message'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => _showJobMessageModal(context, booking, isMr),
          ),
        ],
      ),
    );
  }

  void _showJobMessageModal(BuildContext context, Booking booking, bool isMr) {
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

  Widget _buildStatusTracker(Booking booking, bool isMr) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('कामाची सद्यस्थिती', 'Job Progress Tracker'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatusDot(tr('स्वीकारले', 'Assigned'), true),
              _buildStatusLine(booking.status != BookingStatus.assigned),
              _buildStatusDot(
                tr('निघाले', 'On The Way'),
                booking.status == BookingStatus.onTheWay ||
                    booking.status == BookingStatus.inProgress ||
                    booking.status == BookingStatus.completed,
              ),
              _buildStatusLine(
                booking.status == BookingStatus.inProgress ||
                    booking.status == BookingStatus.completed,
              ),
              _buildStatusDot(
                tr('कामावर', 'Working'),
                booking.status == BookingStatus.inProgress ||
                    booking.status == BookingStatus.completed,
              ),
              _buildStatusLine(booking.status == BookingStatus.completed),
              _buildStatusDot(
                tr('पूर्ण', 'Done'),
                booking.status == BookingStatus.completed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(String label, bool isDone) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isDone
              ? AppColors.partnerTheme
              : Colors.grey.shade300,
          child: Icon(
            isDone ? Icons.check_rounded : Icons.circle,
            color: Colors.white,
            size: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
            color: isDone ? AppColors.partnerTheme : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2.5,
        color: isDone ? AppColors.partnerTheme : Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 16),
      ),
    );
  }

  Widget _buildOtpStartBox(
    BuildContext context,
    AppState appState,
    Booking booking,
    bool isMr,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warningBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security_rounded, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tr('काम सुरू करण्यासाठी OTP टाका', 'Enter Customer OTP to Start'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tr('ग्राहकाच्या मोबाईलवर आलेला ४-अंकी OTP येथे भरा.', 'Ask customer for the 4-digit OTP sent to their mobile.'),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF78350F),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  style: const TextStyle(
                    fontSize: 20,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '----',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.partnerDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: Text(
                  tr('सुरू करा', 'Start'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
                  final entered = _otpController.text.trim();
                  final success = appState.startJobWithOtp(booking.id, entered);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tr('काम अधिकृतरीत्या सुरू झाले!', 'Job started successfully!'),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.error,
                        content: Text(
                          tr('चुकीचा OTP! कृपया पुन्हा तपासा.', 'Invalid OTP!'),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSparePartsBox(
    BuildContext context,
    AppState appState,
    Booking booking,
    bool isMr,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tr('सुटे भाग ऍड करा', 'Extra Spare Parts Added'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle_rounded,
                  color: AppColors.partnerDark,
                  size: 26,
                ),
                tooltip: 'Add Part',
                onPressed: () =>
                    _showAddPartDialog(context, appState, booking.id, isMr),
              ),
            ],
          ),
          if (booking.sparePartsAdded.isEmpty)
            Text(
              tr('अजून कोणतेही सुटे भाग जोडलेले नाहीत. नवीन भाग लागल्यास (+) वर क्लिक करा.', 'No extra parts added yet. Tap (+) to add hardware/parts to bill.'),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            )
          else ...[
            ...booking.sparePartsAdded.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    const Icon(
                      Icons.hardware_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        p,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${tr("सुटे भागांचे बिल:", "Spare Parts Total:")} ${AppHelpers.formatCurrency(booking.sparePartsCost)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompleteJobBox(
    BuildContext context,
    AppState appState,
    Booking booking,
    bool isMr,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('काम पूर्ण व बिल गोळा करा', 'Complete Job & Settle Payment'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${tr("एकूण बिल रक्कम:", "Total Bill Amount:")} ${AppHelpers.formatCurrency(booking.totalAmount)}',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.payments_rounded, size: 18),
                  label: Text(
                    tr('रोख जमा', 'Cash Collected'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    appState.completeJob(
                      bookingId: booking.id,
                      isPaidOnline: false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tr('काम पूर्ण व रोख रक्कम जमा झाली!', 'Job Completed! Cash recorded.'),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                  label: Text(
                    tr('ऑनलाइन पेमेंट', 'Customer Paid UPI'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    appState.completeJob(
                      bookingId: booking.id,
                      isPaidOnline: true,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tr('काम पूर्ण व UPI पेमेंट यशस्वी!', 'Job Completed! UPI Paid.'),
                        ),
                        backgroundColor: const Color(0xFF2563EB),
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

  Widget _buildCompletedReceiptBox(Booking booking, bool isMr) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr('काम यशस्वीरीत्या पूर्ण झाले!', 'Job Completed Successfully!'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'एकूण गोळा केलेली रक्कम: ${AppHelpers.formatCurrency(booking.totalAmount)} (${booking.paymentMethod == PaymentMethod.upiOnline ? "ऑनलाइन UPI" : "रोख कॅश"})',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            tr('ही रक्कम तुमच्या आजच्या एकूण कमाईत जोडली गेली आहे.', 'This amount has been credited to your daily earnings.'),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPartDialog(
    BuildContext context,
    AppState appState,
    String bookingId,
    bool isMr,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(tr('सुटे भाग जोडा', 'Add Spare Part')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _partNameController,
                decoration: InputDecoration(
                  labelText: tr('भागाचे नाव (उदा. नळ वॉशर / पाईप)', 'Part Name'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _partCostController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: tr('किंमत (रुपये)', 'Cost in ₹'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('रद्द', 'Cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.partnerDark,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final name = _partNameController.text.trim();
                final cost =
                    double.tryParse(_partCostController.text.trim()) ?? 0.0;
                if (name.isNotEmpty && cost > 0) {
                  appState.addSparePartToBooking(bookingId, name, cost);
                  _partNameController.clear();
                  _partCostController.clear();
                  Navigator.pop(ctx);
                }
              },
              child: Text(tr('जोडा', 'Add')),
            ),
          ],
        );
      },
    );
  }
}
