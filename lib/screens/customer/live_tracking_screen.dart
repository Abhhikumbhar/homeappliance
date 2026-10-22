import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/booking.dart';
import '../../state/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import '../../widgets/design_components.dart';

/// Ultra-Clean Mobile Live Technician Tracking Screen (Matching Stitch Screen 2)
class LiveTrackingScreen extends StatefulWidget {
  final Booking? booking;

  const LiveTrackingScreen({super.key, this.booking});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isMapExpanded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isMr = appState.isMarathi;

    final activeBooking = widget.booking ??
        appState.customerBookings
            .where(
              (b) =>
                  b.status == BookingStatus.assigned ||
                  b.status == BookingStatus.onTheWay ||
                  b.status == BookingStatus.inProgress,
            )
            .firstOrNull;

    if (activeBooking == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            tr('थेट ट्रॅकिंग', 'Live Tracking'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Center(
          child: EmptyStateWidget(
            icon: Icons.location_off_rounded,
            title: tr('कोणतीही सक्रिय सेवा चालू नाही', 'No Active Service in Progress'),
            description: tr('आपण नवीन सेवा बुक केल्यानंतर येथे तंत्रज्ञाचे लाईव्ह लोकेशन व स्थिती दिसेल.', 'You have no service currently in progress. Book a service to track technician live.'),
            actionLabel: tr('सेवा एक्सप्लोर करा', 'Explore Services'),
            onAction: () => Navigator.pop(context),
          ),
        ),
      );
    }

    final rawTechName = activeBooking.technicianName ?? (tr('तंत्रज्ञ नियुक्त', 'Technician Assigned'));
    final techName = AppHelpers.localizedText(rawTechName, isMr);
    final techPhone = activeBooking.technicianPhone ?? '';
    final serviceTitle = tr(activeBooking.service.titleMr, activeBooking.service.titleEn);
    final otpDigits = (activeBooking.startOtp.length == 4)
        ? activeBooking.startOtp.split('')
        : ['-', '-', '-', '-'];
    final bookingId = activeBooking.id;

    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = _isMapExpanded ? screenHeight * 0.75 : screenHeight * 0.36;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  tr('थेट ट्रॅकिंग', 'Live Tracking'),
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tr('सक्रिय', 'Live'),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              'Order #${activeBooking.id} • $serviceTitle',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_rounded, color: AppColors.primary, size: 21),
            tooltip: 'Call Support',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    tr('सपोर्ट हेल्पलाईन: २४x७ सहाय्य उपलब्ध आहे.', 'ServeEase 24x7 Priority Support Helpline Active.'),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Stack(
        children: [
          // 1. TOP INTERACTIVE MAP SECTION
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: mapHeight,
            child: Stack(
              children: [
                // Vector Map Canvas Simulation
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _AppleMapsSangliPainter(
                          pulseProgress: _pulseAnimation.value,
                        ),
                      );
                    },
                  ),
                ),

                // Floating ETA & Traffic Status Pill
                Positioned(
                  top: 14,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                          tr('११ मिनिटांत पोहोचत आहेत (२.४ किमी)', 'Arriving in 11 mins • 2.4 km away'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Map Control Buttons (Recenter & Expand)
                Positioned(
                  top: 14,
                  right: 16,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isMapExpanded = !_isMapExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isMapExpanded ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. BOTTOM DRAGGABLE & SCROLLABLE DETAIL SHEET
          Positioned(
            top: mapHeight - 18,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // iOS Drag Capsule Handle
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 2.1 DOORSTEP VERIFICATION OTP CARD (MATCHING STITCH SCREEN 2)
                      _buildDoorstepOtpCard(otpDigits, isMr),

                      const SizedBox(height: 14),

                      // 2.2 VERIFIED TECHNICIAN PROFILE CARD (RAJESH S. PATIL)
                      _buildTechnicianProfileCard(techName, techPhone, bookingId, isMr),

                      const SizedBox(height: 14),

                      // 2.3 REAL-TIME 5-STEP SERVICE PROGRESS TIMELINE
                      _buildFiveStepTimeline(isMr),

                      const SizedBox(height: 14),

                      // 2.4 BOOKING SUMMARY CARD
                      _buildBookingSummaryCard(serviceTitle, isMr),

                      const SizedBox(height: 14),

                      // 2.5 SERVEEASE 90-DAY PROTECTION SHIELD
                      _buildSafetyGuaranteeCard(isMr),

                      const SizedBox(height: 14),

                      // 2.6 RESCHEDULE & EMERGENCY HOTLINE ACTIONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    tr('स्लॉट बदलण्याची विनंती नोंदवली गेली.', 'Reschedule request initiated.'),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.calendar_today_rounded, size: 15),
                            label: Text(
                              tr('वेळ बदला', 'Need to Reschedule?'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              AppHelpers.makePhoneCall('1800123456', context);
                            },
                            icon: const Icon(Icons.phone_in_talk_rounded, size: 15, color: AppColors.accent),
                            label: Text(
                              tr('इमर्जन्सी मदत', 'Emergency Hotline'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
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
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 2.1 DOORSTEP VERIFICATION OTP CARD
  // ========================================================
  Widget _buildDoorstepOtpCard(List<String> otpDigits, bool isMr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tr('डोअरस्टेप पडताळणी कोड', 'Doorstep Verification OTP'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: Text(
                  tr('४-अंकी कोड', '4-Digit Code'),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4-Digit OTP Boxes with Copy Action
          OtpDigitBoxes(
            digits: otpDigits,
            onCopy: () {
              Clipboard.setData(ClipboardData(text: otpDigits.join()));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    tr('OTP ${otpDigits.join()} कॉपी केला!', 'OTP ${otpDigits.join()} copied to clipboard!'),
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF0284C7)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tr('तंत्रज्ञ घरी आल्यावरच हा OTP सांगा. फोनवर किंवा आधी कोणालाही सांगू नका.', 'Share this OTP with technician only upon doorstep arrival. Do not share over call.'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF0369A1),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 2.2 VERIFIED TECHNICIAN PROFILE CARD
  // ========================================================
  Widget _buildTechnicianProfileCard(
    String techName,
    String techPhone,
    String bookingId,
    bool isMr,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar with Online Green Dot
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: Text(
                        techName.isNotEmpty ? techName.substring(0, 1) : 'R',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
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
                            techName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr('मास्टर एसी स्पेशालिस्ट • ७+ वर्षे अनुभव', 'Master AC Specialist • 7+ Yrs Exp.'),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 2),
                        const Text(
                          '4.9 (840+ jobs)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.verified_rounded, size: 13, color: AppColors.success),
                        const SizedBox(width: 3),
                        Text(
                          tr('पोलिस पडताळणी', 'Police Verified'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.two_wheeler_rounded, size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  tr('हिरो स्प्लेंडर • MH 12 QP 5842 • जेट किट सज्ज', 'Hero Splendor • MH 12 QP 5842 • Jet Kit Ready'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Two Primary Action Triggers
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => AppHelpers.makePhoneCall(techPhone, context),
                  icon: const Icon(Icons.phone_rounded, size: 16),
                  label: Text(
                    tr('कॉल करा', 'Call Technician'),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: techPhone.isNotEmpty
                      ? () => AppHelpers.openWhatsApp(
                            phone: techPhone,
                            message: tr('नमस्कार, मी माझ्या सर्व्हिस बुकिंग #$bookingId बद्दल विचारत आहे.', 'Hello, checking in regarding my service booking #$bookingId.'),
                            context: context,
                          )
                      : null,
                  icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Color(0xFF25D366)),
                  label: Text(
                    tr('व्हॉट्सॲप', 'WhatsApp Chat'),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 2.3 REAL-TIME 5-STEP SERVICE PROGRESS TIMELINE
  // ========================================================
  Widget _buildFiveStepTimeline(bool isMr) {
    final steps = [
      {
        'title': tr('बुकिंग नोंदवली गेली', 'Booking Confirmed'),
        'time': '02:15 PM',
        'desc': tr('सर्व्हिस स्लॉट यशस्वीरित्या बुक झाला', 'Slot #3 confirmed in system'),
        'state': 'done',
      },
      {
        'title': tr('तंत्रज्ञ निघाले', 'Technician Dispatched'),
        'time': '03:45 PM',
        'desc': tr('हाय-प्रेशर जेट पंप व टूल्स लोड केले', 'Jet pump & toolset loaded on bike'),
        'state': 'done',
      },
      {
        'title': tr('रस्त्यात आहेत', 'On The Way'),
        'time': '04:18 PM',
        'desc': tr('पौड रोड फ्लायओव्हरजवळ • वेग २८ किमी/तास', 'Near Paud Road Flyover • Moving 28 km/h'),
        'state': 'active',
      },
      {
        'title': tr('जेट वॉश व तपासणी', 'Jet Wash & Inspection'),
        'time': '~04:30 PM',
        'desc': tr('इनडोअर व आऊटडोअर कॉइल डीप क्लिनिंग', 'Deep coil cleaning with waterproof shroud'),
        'state': 'upcoming',
      },
      {
        'title': tr('अंतिम चाचणी व वॉरंटी', 'Final Testing & Warranty'),
        'time': '~05:15 PM',
        'desc': tr('डिजिटल रिपोर्ट आणि ९० दिवसांची वॉरंटी कार्ड', 'Digital diagnostic stamp issued'),
        'state': 'upcoming',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('थेट कामाची प्रगती', 'Live Service Progress'),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tr('रिअल-टाईम सिंक', 'Real-time Sync'),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Column(
            children: List.generate(steps.length, (idx) {
              final s = steps[idx];
              final isDone = s['state'] == 'done';
              final isActive = s['state'] == 'active';
              final isLast = idx == steps.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Node + Connecting Line
                    Column(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isDone
                                ? AppColors.success
                                : (isActive ? AppColors.primary : Colors.white),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDone
                                  ? AppColors.success
                                  : (isActive ? AppColors.primary : AppColors.borderDark),
                              width: 2,
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                                : (isActive
                                    ? Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : Text(
                                        '${idx + 1}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textMuted,
                                        ),
                                      )),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: isDone ? AppColors.success : AppColors.border,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  s['title']!,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
                                    color: isActive
                                        ? AppColors.primary
                                        : (isDone ? AppColors.textPrimary : AppColors.textSecondary),
                                  ),
                                ),
                                Text(
                                  s['time']!,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: isActive ? AppColors.primary : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s['desc']!,
                              style: TextStyle(
                                fontSize: 11,
                                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 2.4 BOOKING SUMMARY CARD
  // ========================================================
  Widget _buildBookingSummaryCard(String serviceTitle, bool isMr) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.ac_unit_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tr('आज दुपारी ०४:३० • ४५ मिनिटे • १ युनिट', 'Today 04:30 PM • 45 mins • 1 Unit'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '₹599',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                tr('कामानंतर भरा', 'Pay After'),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 2.5 SERVEEASE 90-DAY PROTECTION SHIELD
  // ========================================================
  Widget _buildSafetyGuaranteeCard(bool isMr) {
    return const TrustGuaranteeShield(
      title: 'ServeEase Shield Protection',
      description:
          'Covered by 90-Day free re-service guarantee and up to ₹10,000 accidental damage protection cover.',
      icon: Icons.shield_rounded,
    );
  }
}

/// High-Fidelity Apple Maps Vector Painter
class _AppleMapsSangliPainter extends CustomPainter {
  final double pulseProgress;

  _AppleMapsSangliPainter({required this.pulseProgress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Map Base
    final bgPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Subtle Waterbody
    final riverPaint = Paint()
      ..color = const Color(0xFFE0E7FF).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final riverPath = Path();
    riverPath.moveTo(0, size.height * 0.38);
    riverPath.cubicTo(
      size.width * 0.3,
      size.height * 0.36,
      size.width * 0.6,
      size.height * 0.42,
      size.width,
      size.height * 0.39,
    );
    riverPath.lineTo(size.width, size.height * 0.45);
    riverPath.cubicTo(
      size.width * 0.6,
      size.height * 0.48,
      size.width * 0.3,
      size.height * 0.42,
      0,
      size.height * 0.44,
    );
    riverPath.close();
    canvas.drawPath(riverPath, riverPaint);

    // 3. Grid Streets
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roadBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final hwyPath = Path();
    hwyPath.moveTo(-20, size.height * 0.28);
    hwyPath.lineTo(size.width * 0.7, size.height * 0.12);
    hwyPath.lineTo(size.width + 20, size.height * 0.08);

    final stnPath = Path();
    stnPath.moveTo(size.width * 0.2, -10);
    stnPath.lineTo(size.width * 0.28, size.height * 0.25);
    stnPath.lineTo(size.width * 0.85, size.height * 0.65);

    final crossPath = Path();
    crossPath.moveTo(size.width * 0.1, size.height * 0.42);
    crossPath.lineTo(size.width * 0.9, size.height * 0.30);

    canvas.drawPath(hwyPath, roadBorder);
    canvas.drawPath(hwyPath, roadPaint);
    canvas.drawPath(stnPath, roadBorder);
    canvas.drawPath(stnPath, roadPaint);
    canvas.drawPath(crossPath, roadBorder);
    canvas.drawPath(crossPath, roadPaint);

    // 4. Glowing Royal Blue Navigation Trajectory
    final startPt = Offset(size.width * 0.22, size.height * 0.12);
    final midPt = Offset(size.width * 0.42, size.height * 0.30);
    final endPt = Offset(size.width * 0.78, size.height * 0.48);

    final trajectoryPath = Path();
    trajectoryPath.moveTo(startPt.dx, startPt.dy);
    trajectoryPath.quadraticBezierTo(
      midPt.dx - 20,
      midPt.dy + 10,
      midPt.dx,
      midPt.dy,
    );
    trajectoryPath.quadraticBezierTo(
      midPt.dx + 40,
      midPt.dy + 30,
      endPt.dx,
      endPt.dy,
    );

    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(trajectoryPath, glowPaint);

    final blueRoutePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(trajectoryPath, blueRoutePaint);

    // 5. Destination Pin
    final destPinPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(endPt.dx, endPt.dy), 13, destPinPaint);
    canvas.drawCircle(
      Offset(endPt.dx, endPt.dy),
      5,
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );

    // 6. Live Technician Motorcycle Beacon
    final currentTechPt = midPt;

    final radarPaint = Paint()
      ..color = AppColors.success.withValues(alpha: (1.0 - pulseProgress) * 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(currentTechPt, 16 + (pulseProgress * 20), radarPaint);

    final beaconCircle = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.fill;
    canvas.drawCircle(currentTechPt, 14, beaconCircle);

    final innerWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(currentTechPt, 6, innerWhite);
  }

  @override
  bool shouldRepaint(covariant _AppleMapsSangliPainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress;
  }
}
