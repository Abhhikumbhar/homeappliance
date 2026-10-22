import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/appliance_service.dart';
import '../../models/booking.dart';
import '../../state/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import 'service_detail_screen.dart';
import 'customer_bookings_screen.dart';
import 'live_tracking_screen.dart';
import 'customer_renewals_screen.dart';
import 'category_services_screen.dart';
import 'all_categories_screen.dart';
import 'wm_specialization_screen.dart';
import '../auth/login_screen.dart';
import '../../widgets/language_dropdown.dart';
import '../../widgets/design_components.dart';
import '../../widgets/live_appliance_animation.dart';
import '../../models/app_notification.dart';
import '../../widgets/notification_sheet.dart';

class _PromoSlide {
  final String badgeMr;
  final String badgeEn;
  final String titleMr;
  final String titleEn;
  final String subtitleMr;
  final String subtitleEn;
  final List<Color> gradientColors;
  final IconData backgroundIcon;
  final String imageAsset;
  final ServiceCategory category;
  final Color ctaColor;
  final bool isSpecialization;

  const _PromoSlide({
    required this.badgeMr,
    required this.badgeEn,
    required this.titleMr,
    required this.titleEn,
    required this.subtitleMr,
    required this.subtitleEn,
    required this.gradientColors,
    required this.backgroundIcon,
    required this.imageAsset,
    required this.category,
    this.ctaColor = AppColors.accent,
    this.isSpecialization = false,
  });
}

/// Commercial High-Fidelity Customer Home Screen matching Stitch UI Reference
class CustomerHomeScreen extends StatefulWidget {
  final ServiceCategory? initialCategory;
  final bool openWmSpecialization;

  const CustomerHomeScreen({
    super.key,
    this.initialCategory,
    this.openWmSpecialization = false,
  });

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  int _currentBottomIndex = 0;
  ServiceCategory _selectedCategory = ServiceCategory.ac;
  String _searchQuery = '';
  String _activeFilterChip = 'instant';
  String _currentLocation = 'कोथरूड, पुणे (Kothrud, Pune)';

  int _currentBannerIndex = 0;
  late final PageController _bannerController;
  Timer? _bannerTimer;

  static const List<_PromoSlide> _promoSlides = [
    _PromoSlide(
      badgeMr: '🔥 मर्यादित समर स्पेशल • २५% सूट',
      badgeEn: '🔥 Limited Summer Special • Flat 25% Off',
      titleMr: 'समर एसी जेट वॉश ऑफर',
      titleEn: 'Summer AC Jet Wash Offer',
      subtitleMr: 'फ्लॅट २५% सूट + ९० दिवसांची सर्व्हिस वॉरंटी',
      subtitleEn: 'Flat 25% Off + 90 Days Comprehensive Warranty',
      gradientColors: [Color(0xFF003B99), Color(0xFF0052CC)],
      backgroundIcon: Icons.ac_unit_rounded,
      imageAsset: 'assets/images/ac_banner.jpg',
      category: ServiceCategory.ac,
      ctaColor: AppColors.accent,
    ),
    _PromoSlide(
      badgeMr: '⚡ पीसीबी, इन्व्हर्टर व फ्रंट लोड • मोफत तपासणी',
      badgeEn: '⚡ PCB, Inverter & Front Load Specialists',
      titleMr: 'वॉशिंग मशीन स्पेशालिस्ट्स',
      titleEn: 'Washing Machine Specialists',
      subtitleMr: 'तज्ज्ञ पीसीबी बोर्ड, इन्व्हर्टर आणि फ्रंट लोड दुरुस्ती सेवा',
      subtitleEn: 'Expert PCB Board, Inverter & Front Load Repair Services',
      gradientColors: [Color(0xFF0F766E), Color(0xFF0D9488)],
      backgroundIcon: Icons.local_laundry_service_rounded,
      imageAsset: 'assets/images/wm_banner.jpg',
      category: ServiceCategory.washingMachine,
      ctaColor: Color(0xFFFF6A00),
      isSpecialization: true,
    ),
    _PromoSlide(
      badgeMr: '💡 जलद ३० मिनिटांत सेवा • सुपर सेव्हर',
      badgeEn: '💡 Express 30 Mins • Super Saver',
      titleMr: 'सिलिंग फॅन व वायरिंग दुरुस्ती',
      titleEn: 'Ceiling Fan & Electrical Care',
      subtitleMr: 'कॉईल बदलणे, बेअरिंग व नवीन फिटिंग सेवा',
      subtitleEn: 'Coil rewinding, bearing change & new fitting',
      gradientColors: [Color(0xFFC2410C), Color(0xFFEA580C)],
      backgroundIcon: Icons.wind_power_rounded,
      imageAsset: 'assets/images/fan_banner.jpg',
      category: ServiceCategory.ac,
      ctaColor: Color(0xFF0F172A),
    ),
    _PromoSlide(
      badgeMr: '💧 १००% शुद्ध पाणी • नवीन फिल्टर किट',
      badgeEn: '💧 100% Pure Water • Filter Upgrade',
      titleMr: 'आरओ फिल्टर व टीडीएस बॅलन्स',
      titleEn: 'RO Purifier Deep Service',
      subtitleMr: 'सर्व ब्रँड्सचे ओरिजिनल फिल्टर्स व फ्री टीडीएस टेस्ट',
      subtitleEn: 'Original multi-brand filters + free TDS test',
      gradientColors: [Color(0xFF4338CA), Color(0xFF6366F1)],
      backgroundIcon: Icons.water_drop_rounded,
      imageAsset: 'assets/images/ro_banner.jpg',
      category: ServiceCategory.roWater,
      ctaColor: AppColors.accent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    if (widget.openWmSpecialization) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const WashingMachineSpecializationScreen(),
            ),
          );
        }
      });
    }
    _bannerController = PageController();
    _bannerTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted || !_bannerController.hasClients) return;
      final nextPage = (_currentBannerIndex + 1) % _promoSlides.length;
      _bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isMr = appState.isMarathi;

    final services = appState.services;
    final availableCategories = ServiceCategory.values;

    if (availableCategories.isNotEmpty &&
        !availableCategories.contains(_selectedCategory)) {
      _selectedCategory = availableCategories.first;
    }

    final filteredServices = services.where((s) {
      final matchesCat = s.category == _selectedCategory;
      if (_searchQuery.isEmpty) return matchesCat;
      final q = _searchQuery.toLowerCase();
      return (s.titleEn.toLowerCase().contains(q) ||
              s.titleMr.toLowerCase().contains(q) ||
              s.category.nameEn.toLowerCase().contains(q) ||
              s.category.nameMr.toLowerCase().contains(q) ||
              (s.customCategoryName?.toLowerCase().contains(q) ?? false)) &&
          matchesCat;
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F8FC),
      drawer: _buildAppDrawer(context, appState, isMr),
      bottomNavigationBar: _buildStitchBottomNav(context, isMr),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 0. Apple iOS 18 Dynamic Island Live Activity Banner
            SliverToBoxAdapter(
              child: _buildDynamicIslandPill(context, appState, isMr),
            ),

            // 1. Top Location, Brand & Profile Header Bar
            SliverToBoxAdapter(
              child: _buildTopBrandAndLocationBar(context, appState, isMr),
            ),

            // 2. Greeting Header with WhatsApp Assistant Action
            SliverToBoxAdapter(
              child: _buildGreetingAndHelpHeader(context, appState, isMr),
            ),

            // 3. Modern Search Bar
            SliverToBoxAdapter(child: _buildModernSearchBar(isMr)),

            // 4. Quick Category Filter Pills
            SliverToBoxAdapter(child: _buildQuickFilterChips(context, isMr)),

            // 5. Active Live Tracking Card (Matching Stitch UI)
            SliverToBoxAdapter(
              child: _buildActiveOngoingBookingCard(context, appState, isMr),
            ),

            // 6. Promotional Hero Banner (AC Master Service Offer)
            SliverToBoxAdapter(
              child: _buildPromotionalHeroBanner(context, isMr),
            ),

            // 6.5 Washing Machine Specialists Section (Requirement 1)
            SliverToBoxAdapter(
              child: _buildWashingMachineSpecialistsSection(context, appState, isMr),
            ),

            // 7. Select Appliance Section Header
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                title: tr('घरगुती उपकरणे', 'Select Appliance'),
                trailingText: tr('सर्व पहा ›', 'View All ›'),
                onTrailingTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllCategoriesScreen(),
                    ),
                  );
                },
              ),
            ),

            // 8. 2-Column Appliance Grid (Matching Stitch UI)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildApplianceTwoColumnGrid(isMr),
            ),

            // 9. Selected Category Header & Warranty Shield
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tr(_selectedCategory.nameMr, _selectedCategory.nameEn),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.successBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_rounded,
                            size: 13,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tr('३० दिवस वॉरंटी', '30-Day Shield'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 10. Service Packages List
            if (filteredServices.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: tr('कोणतीही सेवा सापडली नाही', 'No Services Found'),
                    description: tr('या श्रेणीत तुमच्या शोधाशी जुळणारी सेवा नाही. कृपया इतर शब्द शोधा किंवा शोध साफ करा.', 'No services match your search query in this category.'),
                    actionLabel: _searchQuery.isNotEmpty
                        ? (tr('शोध साफ करा', 'Clear Search'))
                        : null,
                    onAction: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _buildServicePackageCard(
                      context,
                      filteredServices[index],
                      isMr,
                    );
                  }, childCount: filteredServices.length),
                ),
              ),

            // 11. Annual AMC Maintenance Protection Card (Stitch UI)
            SliverToBoxAdapter(child: _buildAmcProtectionCard(context, isMr)),

            // 12. "आम्हीच का?" (Why Choose Us Trust Indicators)
            SliverToBoxAdapter(child: _buildWhyChooseUsCards(isMr)),

            // 13. 24x7 Customer Help Strip
            SliverToBoxAdapter(child: _buildCustomerHelpStrip(context, isMr)),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // 0. DYNAMIC ISLAND PILL
  // ========================================================
  Widget _buildDynamicIslandPill(
    BuildContext context,
    AppState appState,
    bool isMr,
  ) {
    final activeBooking = appState.customerBookings
        .where(
          (b) =>
              b.status == BookingStatus.assigned ||
              b.status == BookingStatus.onTheWay ||
              b.status == BookingStatus.inProgress,
        )
        .firstOrNull;

    if (activeBooking == null) {
      return const SizedBox.shrink();
    }

    final rawTech = activeBooking.technicianName ??
        (tr('तंत्रज्ञ नियुक्त', 'Technician Assigned'));
    final techName = AppHelpers.localizedText(rawTech, isMr);

    return IOSDynamicIslandBanner(
      title: tr('तंत्रज्ञ येत आहे • $techName', 'Technician En Route • $techName'),
      subtitle: tr('${activeBooking.service.titleMr} • सांगली हब', '${activeBooking.service.titleEn} • Sangli Hub'),
      etaText: activeBooking.status == BookingStatus.inProgress
          ? (tr('चालू', 'Live'))
          : '18 min',
      leadingIcon: Icons.two_wheeler_rounded,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LiveTrackingScreen(booking: activeBooking),
          ),
        );
      },
    );
  }

  // ========================================================
  // 1. TOP BRAND & LOCATION BAR
  // ========================================================
  Widget _buildTopBrandAndLocationBar(
    BuildContext context,
    AppState appState,
    bool isMr,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & App Name
          InkWell(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            borderRadius: BorderRadius.circular(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/young_master_logo.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.home_repair_service_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tr('होम अप्लायन्स', 'Home Appliance'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      tr('केअर सांगली', 'Care Sangli'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions: Language Toggle + Bell + Profile Avatar
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LanguageDropdown(compact: true),
              const SizedBox(width: 6),

              // Notification Bell
              Stack(
                children: [
                  InkWell(
                    onTap: () {
                      NotificationSheet.show(
                        context,
                        role: NotificationRecipientRole.customer,
                        onOpenBooking: (bookingId) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CustomerBookingsScreen(),
                            ),
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(6.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  if (appState.customerUnreadNotificationsCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 6.5,
                        height: 6.5,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 6),

              // Profile Avatar Icon
              InkWell(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 18,
                    color: AppColors.primary,
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
  // 2. GREETING & ASSISTANT HEADER
  // ========================================================
  Widget _buildGreetingAndHelpHeader(
    BuildContext context,
    AppState appState,
    bool isMr,
  ) {
    final rawName = appState.currentUser?.name;
    final localizedName = rawName != null
        ? AppHelpers.localizedText(rawName, isMr)
        : null;
    final userName =
        localizedName?.split(' ').first ?? (tr('ग्राहक', 'Customer'));

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('नमस्कार, $userName! 👋', 'Hello, $userName! 👋'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tr('विश्वसनीय घरगुती उपकरण सेवा', 'Trusted Home Appliance Services'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // WhatsApp Assistant Pill
          InkWell(
            onTap: () {
              AppHelpers.openWhatsApp(
                phone: '9822000000',
                message: tr('नमस्कार! मला होम अप्लायन्स सर्व्हिसिंगबद्दल माहिती हवी आहे.', 'Hello! I need information regarding home appliance servicing.'),
                context: context,
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5.5),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF25D366).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.chat_bubble_rounded,
                    color: Color(0xFF25D366),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tr('व्हॉट्सॲप साहाय्यक', 'WhatsApp Help'),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E8E44),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 3. MODERN SEARCH BAR
  // ========================================================
  Widget _buildModernSearchBar(bool isMr) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          decoration: InputDecoration(
            icon: const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      size: 17,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  )
                : const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.mic_none_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
            hintText: tr('उपकरण किंवा सेवा शोधा...', 'Search repair, cleaning, AMC...'),
            hintStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 9,
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================
  // 4. QUICK FILTER CHIPS
  // ========================================================
  Widget _buildQuickFilterChips(BuildContext context, bool isMr) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildChip(
              id: 'instant',
              icon: Icons.bolt_rounded,
              iconColor: const Color(0xFFF59E0B),
              label: tr('झटपट बुकिंग', 'Instant Booking'),
              onTap: () {
                setState(() => _activeFilterChip = 'instant');
              },
            ),
            const SizedBox(width: 7),
            _buildChip(
              id: 'tracking',
              icon: Icons.location_on_rounded,
              iconColor: AppColors.primary,
              label: tr('थेट ट्रॅकिंग', 'Live Track'),
              onTap: () {
                setState(() => _activeFilterChip = 'tracking');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LiveTrackingScreen()),
                );
              },
            ),
            const SizedBox(width: 7),
            _buildChip(
              id: 'amc',
              icon: Icons.shield_rounded,
              iconColor: const Color(0xFF0F766E),
              label: tr('माझे एएमसी', 'My AMC Plans'),
              onTap: () {
                setState(() => _activeFilterChip = 'amc');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerRenewalsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 7),
            _buildChip(
              id: 'top_rated',
              icon: Icons.star_rounded,
              iconColor: const Color(0xFFF59E0B),
              label: tr('टॉप रेटेड', 'Top Rated'),
              onTap: () {
                setState(() => _activeFilterChip = 'top_rated');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String id,
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = _activeFilterChip == id;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.3 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13.5,
              color: isSelected ? AppColors.primary : iconColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // 5. ACTIVE ONGOING BOOKING CARD (MATCHING STITCH UI)
  // ========================================================
  Widget _buildActiveOngoingBookingCard(
    BuildContext context,
    AppState appState,
    bool isMr,
  ) {
    final activeBooking = appState.customerBookings
        .where(
          (b) =>
              b.status == BookingStatus.assigned ||
              b.status == BookingStatus.onTheWay ||
              b.status == BookingStatus.inProgress,
        )
        .firstOrNull;

    if (activeBooking == null) {
      return const SizedBox.shrink();
    }

    final rawTechName = activeBooking.technicianName ??
        (tr('तंत्रज्ञ नियुक्त', 'Technician Assigned'));
    final techName = AppHelpers.localizedText(rawTechName, isMr);
    final serviceName = tr(activeBooking.service.titleMr, activeBooking.service.titleEn);
    final bookingId = activeBooking.id;
    final customerPhone = activeBooking.customerPhone;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Status Bar: 🟢 Active Service in Progress • ETA 12 mins • #HAC-8299
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tr('थेट सेवा चालू आहे • अंदाजे १२ मिनिटांत आगमन', 'Active Service in Progress • ETA 12 mins'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF065F46),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '#$bookingId',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),

          // Main Card Content: Technician, Service & Track CTA
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    // Technician Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          techName.isNotEmpty ? techName.substring(0, 1) : 'R',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tech details & service name
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 11,
                                      color: Color(0xFFD97706),
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      '4.9',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr('$serviceName साठी तंत्रज्ञ येत आहेत', 'Technician on the way for $serviceName'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Deep Royal Blue Track Live Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 1,
                      ),
                      icon: const Icon(Icons.navigation_rounded, size: 14),
                      label: Text(
                        tr('Track Live', 'Track Live'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LiveTrackingScreen(booking: activeBooking),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),

                // Bottom strip: 🛵 विश्रामबाग चौकातून निघत आहेत (५ मिनिटे) + Phone call button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.two_wheeler_rounded,
                            size: 16,
                            color: Color(0xFF0F766E),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              tr('विश्रामबाग चौकातून निघत आहेत (५ मिनिटे)', 'Departing from Vishrambag (5 mins away)'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          AppHelpers.makePhoneCall(customerPhone, context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Icon(
                          Icons.phone_rounded,
                          size: 15,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 6. PROMOTIONAL HERO BANNER (MATCHING STITCH UI CAROUSEL)
  // ========================================================
  Widget _buildPromotionalHeroBanner(BuildContext context, bool isMr) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      height: 178,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: _promoSlides.length,
            onPageChanged: (index) {
              setState(() => _currentBannerIndex = index);
            },
            itemBuilder: (context, index) {
              final slide = _promoSlides[index];
              return Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: slide.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: slide.gradientColors.first.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Text & Action Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Promo Tag Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              tr(slide.badgeMr, slide.badgeEn),
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 7),
                          // Offer Title
                          Text(
                            tr(slide.titleMr, slide.titleEn),
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          // Offer Subtitle
                          Text(
                            tr(slide.subtitleMr, slide.subtitleEn),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          // Book Now Action CTA Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: slide.ctaColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 2,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              if (slide.isSpecialization) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const WashingMachineSpecializationScreen(),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _selectedCategory = slide.category;
                                });
                              }
                            },
                            icon: const Icon(Icons.flash_on_rounded, size: 14),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tr('आता बुक करा', 'Book Now'),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.arrow_forward_rounded, size: 13),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right Appliance Photo Card with Live Animation
                    LiveApplianceAnimationCard(
                      imageAsset: slide.imageAsset,
                      category: slide.category,
                      fallbackIcon: slide.backgroundIcon,
                      width: 94,
                      height: 94,
                      borderRadius: 18,
                    ),
                  ],
                ),
              );
            },
          ),
          // iOS Style Page Indicator Dots (Bottom Left)
          Positioned(
            left: 18,
            bottom: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_promoSlides.length, (i) {
                final isSelected = i == _currentBannerIndex;
                return GestureDetector(
                  onTap: () {
                    _bannerController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    height: 5,
                    width: isSelected ? 18 : 5,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.38),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 6.5 WASHING MACHINE SPECIALISTS SECTION (Requirement 1)
  // ========================================================
  Widget _buildWashingMachineSpecialistsSection(
    BuildContext context,
    AppState appState,
    bool isMr,
  ) {
    final config = appState.wmSpecializationConfig;
    if (!config.isServiceAvailable) return const SizedBox.shrink();

    final services = config.activeServices;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Top Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.precision_manufacturing_rounded,
                    color: Color(0xFF7C3AED),
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
                          const Flexible(
                            child: Text(
                              'Washing Machine Specialists',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB800),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PRO LAB',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Expert PCB Board, Inverter & Front Load Repair Services',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const WashingMachineSpecializationScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tr('सर्व पहा ›', 'View All ›'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // Professional Service Box Grid (2-Column Box Type Layout)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  services.length.isOdd ? services.length + 1 : services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.86,
              ),
              itemBuilder: (context, index) {
                if (index < services.length) {
                  return _buildSpecialistBoxCard(
                    context,
                    services[index],
                    isMr,
                  );
                }
                return _buildAllIssuesBoxCard(
                  context,
                  isMr,
                  services.isNotEmpty ? services.first.inspectionFee : 249.0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialistBoxCard(
    BuildContext context,
    WashingMachineSpecializationService service,
    bool isMr,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WashingMachineSpecializationScreen(
                initialServiceId: service.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Icon + Warranty Shield Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      service.icon,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${service.warrantyDays}D Shield',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Title & Subtitle Description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(service.titleMr, service.titleEn),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tr(service.descriptionMr, service.descriptionEn),
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Bottom Row: Diagnostic Fee & Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tr('तपासणी', 'Doorstep'),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          AppHelpers.formatCurrency(service.inspectionFee),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tr('बुक', 'Book'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllIssuesBoxCard(
    BuildContext context,
    bool isMr,
    double defaultFee,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WashingMachineSpecializationScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Icon + Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.troubleshoot_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tr('सर्व ब्रँड्स', 'All Brands'),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Title & Subtitle Description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('इतर समस्या व भाग', 'Error Codes & Other Issues'),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tr(
                      'ड्रेन, ड्रम, लॉक, वॉल्व्ह',
                      'Drain, lock, drum, valve...',
                    ),
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Bottom Row: Diagnostic Fee & Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tr('तपासणी', 'Doorstep'),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          AppHelpers.formatCurrency(defaultFee),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tr('सर्व पहा', 'View'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================
  // 7. SECTION HEADER
  // ========================================================
  Widget _buildSectionTitle({
    required String title,
    required String trailingText,
    required VoidCallback onTrailingTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          InkWell(
            onTap: onTrailingTap,
            child: Text(
              trailingText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 8. 2-COLUMN APPLIANCE GRID (MATCHING STITCH UI)
  // ========================================================
  SliverGrid _buildApplianceTwoColumnGrid(bool isMr) {
    final appliances = [
      _ApplianceItem(
        category: ServiceCategory.ac,
        nameMr: 'एसी सर्व्हिस व दुरुस्ती',
        nameEn: 'Air Conditioner',
        startingPrice: tr('₹४९ पासून सुरू', 'Starts @ ₹49'),
        icon: Icons.ac_unit_rounded,
        color: const Color(0xFF0284C7),
      ),
      _ApplianceItem(
        category: ServiceCategory.refrigerator,
        nameMr: 'फ्रिज दुरुस्ती',
        nameEn: 'Refrigerator',
        startingPrice: tr('₹४९ पासून सुरू', 'Starts @ ₹49'),
        icon: Icons.kitchen_rounded,
        color: const Color(0xFF6366F1),
      ),
      _ApplianceItem(
        category: ServiceCategory.washingMachine,
        nameMr: 'वॉशिंग मशीन',
        nameEn: 'Washing Machine',
        startingPrice: tr('₹४९ पासून सुरू', 'Starts @ ₹49'),
        icon: Icons.local_laundry_service_rounded,
        color: const Color(0xFF8B5CF6),
      ),
      _ApplianceItem(
        category: ServiceCategory.electrical,
        nameMr: 'इलेक्ट्रिशियन व वायरिंग',
        nameEn: 'Electrical & Wiring',
        startingPrice: tr('₹४९ पासून सुरू', 'Starts @ ₹49'),
        icon: Icons.tv_rounded,
        color: const Color(0xFFD97706),
      ),
      _ApplianceItem(
        category: ServiceCategory.roWater,
        nameMr: 'वॉटर प्युरिफायर',
        nameEn: 'Water Purifier (RO)',
        startingPrice: tr('₹४९ पासून सुरू', 'Starts @ ₹49'),
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF06B6D4),
      ),
      _ApplianceItem(
        category: ServiceCategory.geyser,
        nameMr: 'गिझर सर्व्हिसिंग',
        nameEn: 'Geyser & Water Heater',
        startingPrice: tr('₹४९ पासून सुरू', 'Starts @ ₹49'),
        icon: Icons.waves_rounded,
        color: const Color(0xFFEA580C),
      ),
      _ApplianceItem(
        category: ServiceCategory.plumbing,
        nameMr: 'प्लंबिंग व फिटिंग',
        nameEn: 'Plumbing & Fitting',
        startingPrice: tr('₹४९ पासून सुरू', 'Starts @ ₹49'),
        icon: Icons.plumbing_rounded,
        color: const Color(0xFF0D9488),
      ),
      _ApplianceItem(
        category: ServiceCategory.chimney,
        nameMr: 'किचन चिमणी व इतर',
        nameEn: 'Kitchen Chimney & More',
        startingPrice: tr('अंदाजे दर', 'Custom Quote'),
        icon: Icons.soup_kitchen_rounded,
        color: const Color(0xFFE11D48),
      ),
      _ApplianceItem(
        category: ServiceCategory.other,
        nameMr: 'इतर सेवा',
        nameEn: 'Other Services',
        startingPrice: tr('अंदाजे दर', 'Custom Quote'),
        icon: Icons.miscellaneous_services_rounded,
        color: const Color(0xFF64748B),
      ),
    ];

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.55,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = appliances[index];
        final isSelected = item.category == _selectedCategory;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedCategory = item.category;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CategoryServicesScreen(category: item.category),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? AppColors.coloredShadow(
                      AppColors.primary,
                      opacity: 0.12,
                      blur: 8,
                    )
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, size: 18, color: item.color),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tr('निवडले', 'Active'),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(item.nameMr, item.nameEn),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.startingPrice,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }, childCount: appliances.length),
    );
  }

  // ========================================================
  // 9. SERVICE PACKAGE CARD
  // ========================================================
  Widget _buildServicePackageCard(
    BuildContext context,
    ServicePackage service,
    bool isMr,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceDetailScreen(service: service),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(service.titleMr, service.titleEn),
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${service.rating} (${service.reviewsCount})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '•',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${service.durationMinutes} min',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tr(service.descriptionMr, service.descriptionEn),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Price & Booking Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppHelpers.formatCurrency(service.basePrice),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (service.originalPrice > service.basePrice) ...[
                          const SizedBox(width: 6),
                          Text(
                            AppHelpers.formatCurrency(service.originalPrice),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceDetailScreen(service: service),
                      ),
                    );
                  },
                  child: Text(
                    tr('बुक करा', 'BOOK'),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
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

  // ========================================================
  // 10. ANNUAL AMC MAINTENANCE CARD (MATCHING STITCH UI)
  // ========================================================
  Widget _buildAmcProtectionCard(BuildContext context, bool isMr) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCCFBF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF0F766E),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            tr('वार्षिक देखभाल करार', 'Annual Maintenance (AMC)'),
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF134E4A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tr('₹१,२०० बचत', 'Save ₹1,200'),
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr('तुमच्या संपूर्ण घराची मोफत काळजी', 'Complete home appliance safety coverage'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF115E59),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3 Feature boxes
          Row(
            children: [
              _buildAmcFeaturePill(
                icon: Icons.checklist_rounded,
                text: tr('४ मोफत सर्व्हिस', '4 Free Services'),
              ),
              const SizedBox(width: 6),
              _buildAmcFeaturePill(
                icon: Icons.money_off_rounded,
                text: tr('० व्हिजिट फी', '0 Visit Fee'),
              ),
              const SizedBox(width: 6),
              _buildAmcFeaturePill(
                icon: Icons.speed_rounded,
                text: tr('२ तासांत मदत', '2-hr Priority'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerRenewalsScreen(),
                  ),
                );
              },
              child: Text(
                tr('AMC प्लॅन्स तपशील तपासा ›', 'Check AMC Plans & Details ›'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmcFeaturePill({required IconData icon, required String text}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCCFBF1)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF0F766E)),
            const SizedBox(height: 2),
            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF134E4A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // 11. "आम्हीच का?" TRUST INDICATORS (MATCHING STITCH UI)
  // ========================================================
  Widget _buildWhyChooseUsCards(bool isMr) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('आम्हीच का?', 'Why Choose Us?'),
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTrustPill(
                title: tr('३० दिवस गॅरंटी', '30-Day Guarantee'),
                subtitle: tr('कामावर पूर्ण वॉरंटी', 'Full warranty'),
                icon: Icons.shield_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _buildTrustPill(
                title: tr('प्रमाणित तज्ज्ञ', 'Verified Pros'),
                subtitle: tr('स्थानिक कामगार', 'Police verified'),
                icon: Icons.verified_rounded,
                color: const Color(0xFF0F766E),
              ),
              const SizedBox(width: 8),
              _buildTrustPill(
                title: tr('पक्के बिल व GST', 'Transparent Bill'),
                subtitle: tr('कोणतीही छुपी फी नाही', 'No hidden fee'),
                icon: Icons.receipt_rounded,
                color: const Color(0xFFD97706),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustPill({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // 12. 24x7 CUSTOMER HELP STRIP
  // ========================================================
  Widget _buildCustomerHelpStrip(BuildContext context, bool isMr) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.support_agent_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('मदत हवी आहे? ग्राहक सेवा सांगली', 'Need Help? Customer Care'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  tr('सांगली २४x७ सपोर्ट उपलब्ध', 'Sangli 24x7 Support On Duty'),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () => AppHelpers.makePhoneCall('9822000000', context),
            child: Text(
              tr('📞 कॉल करा', '📞 Call'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 13. BOTTOM NAVIGATION BAR (MATCHING STITCH UI)
  // ========================================================
  Widget _buildStitchBottomNav(BuildContext context, bool isMr) {
    final appState = AppStateScope.of(context);
    final activeBookingsCount = appState.customerBookings.where((b) {
      return b.status == BookingStatus.pending ||
          b.status == BookingStatus.assigned ||
          b.status == BookingStatus.onTheWay ||
          b.status == BookingStatus.inProgress;
    }).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentBottomIndex,
        onTap: (index) {
          if (index == 0) {
            setState(() => _currentBottomIndex = 0);
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerBookingsScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerRenewalsScreen()),
            );
          } else if (index == 3) {
            _scaffoldKey.currentState?.openDrawer();
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: appState.tr('मुख्य', 'Home', hi: 'होम', kn: 'ಹೋಮ್', gu: 'હોમ'),
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: activeBookingsCount > 0,
              label: Text('$activeBookingsCount'),
              child: const Icon(Icons.receipt_long_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: activeBookingsCount > 0,
              label: Text('$activeBookingsCount'),
              child: const Icon(Icons.receipt_long_rounded),
            ),
            label: appState.tr('बुकिंग्ज', 'Bookings', hi: 'बुकिंग्स', kn: 'ಬುಕಿಂಗ್‌ಗಳು', gu: 'બુકિંગ્સ'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.verified_outlined),
            activeIcon: const Icon(Icons.verified_rounded),
            label: appState.tr('एएमसी', 'AMC', hi: 'AMC', kn: 'AMC', gu: 'AMC'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            activeIcon: const Icon(Icons.person_rounded),
            label: appState.tr('प्रोफाईल', 'Profile', hi: 'प्रोफ़ाइल', kn: 'ಪ್ರೊಫೈಲ್', gu: 'પ્રોફાઇલ'),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 14. APP DRAWER
  // ========================================================
  Widget _buildAppDrawer(BuildContext context, AppState appState, bool isMr) {
    final user = appState.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/young_master_logo.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ??
                                  (tr('ग्राहक', 'Guest Customer')),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user?.email ??
                                  (tr('लॉगिन केलेले नाही', 'Not logged in')),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.accent,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tr('सत्यापित ग्राहक खाते', 'Verified Customer Account'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // 1. Home Overview
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.home_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          tr('मुख्य पृष्ठ', 'Home Overview'),
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  // 1.5 All Appliance Categories
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.grid_view_rounded,
                            color: Color(0xFF8B5CF6),
                            size: 22,
                          ),
                        ),
                        title: Text(
                          tr('सर्व उपकरणे व कॅटेगरीज', 'All Appliance Categories'),
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AllCategoriesScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // 2. My Bookings
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Color(0xFF0284C7),
                            size: 22,
                          ),
                        ),
                        title: Text(
                          tr('माझी कामे', 'My Bookings'),
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        subtitle: Text(
                          tr('लाईव्ह ट्रॅकिंग व हिस्ट्री', 'Track live requests'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CustomerBookingsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // 3. AMC & Protection Plans
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF7C3AED),
                            size: 22,
                          ),
                        ),
                        title: Text(
                          tr('एएमसी प्लॅन्स', 'AMC & Protection Plans'),
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        subtitle: Text(
                          tr('वार्षिक देखभाल करार', 'Annual Maintenance (AMC)'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CustomerRenewalsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
                  ),

                  // 4. WhatsApp Support
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_rounded,
                            color: Color(0xFF16A34A),
                            size: 22,
                          ),
                        ),
                        title: Text(
                          tr('व्हॉट्सॲप सपोर्ट', 'WhatsApp Support'),
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        subtitle: const Text(
                          '+91 98220 00000',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                        onTap: () {
                          Navigator.pop(context);
                          AppHelpers.openWhatsApp(
                            phone: '9822000000',
                            message: tr('नमस्कार, मला सपोर्ट हवा आहे.', 'Hello, I need support.'),
                            context: context,
                          );
                        },
                      ),
                    ),
                  ),

                  // 5. Switch Language
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.translate_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          appState.tr(
                            'भाषा बदला',
                            'Switch Language',
                            hi: 'भाषा बदलें',
                            kn: 'ಭಾಷೆ ಬದಲಾಯಿಸಿ',
                            gu: 'ભાષા બદલો',
                          ),
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        subtitle: Text(
                          '${appState.currentLanguage.flag} ${appState.currentLanguage.nativeName}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: const LanguageDropdown(compact: true),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (ctx) {
                              return SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                        child: Text(
                                          appState.tr(
                                            'भाषा निवडा',
                                            'Select Language',
                                            hi: 'भाषा चुनें',
                                            kn: 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ',
                                            gu: 'ભાષા પસંદ કરો',
                                          ),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const Divider(),
                                      ...AppLanguage.values.map((lang) {
                                        final isSelected = lang == appState.currentLanguage;
                                        return ListTile(
                                          leading: Container(
                                            width: 34,
                                            height: 34,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primaryLight
                                                  : AppColors.surfaceMuted,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(lang.flag, style: const TextStyle(fontSize: 16)),
                                          ),
                                          title: Text(
                                            lang.nativeName,
                                            style: TextStyle(
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                            ),
                                          ),
                                          subtitle: Text(lang.englishName),
                                          trailing: isSelected
                                              ? const Icon(Icons.check_circle_rounded, color: AppColors.success)
                                              : null,
                                          onTap: () {
                                            appState.setAppLanguage(lang);
                                            Navigator.pop(ctx);
                                          },
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
                  ),

                  // 6. Sign Out Button (Prominent, Bold, Beautiful Red Card)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFECACA),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDC2626).withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEE2E2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.logout_rounded,
                                        color: Color(0xFFDC2626),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      tr('साइन आउट', 'Sign Out'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  tr('तुम्हाला खरोखर खात्यातून बाहेर पडायचे आहे का?', 'Are you sure you want to log out of your account?'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                    child: Text(
                                      tr('रद्द करा', 'Cancel'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFDC2626),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(dCtx); // Close dialog
                                      Navigator.pop(context); // Close drawer
                                      appState.logout();
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                                        (route) => false,
                                      );
                                    },
                                    child: Text(
                                      tr('होय, साइन आउट', 'Yes, Sign Out'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFDC2626).withValues(alpha: 0.28),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        tr('साइन आउट', 'Sign Out'),
                                        style: const TextStyle(
                                          color: Color(0xFFDC2626),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      Text(
                                        tr('खात्यातून बाहेर पडा', 'Exit your account'),
                                        style: TextStyle(
                                          color: const Color(0xFFDC2626).withValues(alpha: 0.75),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFFDC2626),
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/young_master_logo.png',
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Young Master • Home Appliance Care v2.0',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(BuildContext context, bool isMr) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('तुमचा परिसर निवडा', 'Select Your Area'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildLocationTile(
                ctx,
                tr('कोथरूड, पुणे', 'Kothrud, Pune'),
                'कोथरूड, पुणे (Kothrud, Pune)',
              ),
              _buildLocationTile(
                ctx,
                tr('विश्रामबाग, सांगली', 'Vishrambag, Sangli'),
                'विश्रामबाग, सांगली (Vishrambag, Sangli)',
              ),
              _buildLocationTile(
                ctx,
                tr('कुपवाड रोड, सांगली', 'Kupwad Road, Sangli'),
                'कुपवाड रोड, सांगली (Kupwad Road, Sangli)',
              ),
              _buildLocationTile(
                ctx,
                tr('मिरज, सांगली', 'Miraj, Sangli'),
                'मिरज, सांगली (Miraj, Sangli)',
              ),
              _buildLocationTile(
                ctx,
                tr('मलकापूर, कराड', 'Malkapur, Karad'),
                'मलकापूर, कराड (Malkapur, Karad)',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationTile(BuildContext ctx, String label, String value) {
    return ListTile(
      leading: const Icon(Icons.location_on_rounded, color: AppColors.primary),
      title: Text(
        label,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
      onTap: () {
        setState(() => _currentLocation = value);
        Navigator.pop(ctx);
      },
    );
  }
}

class _ApplianceItem {
  final ServiceCategory category;
  final String nameMr;
  final String nameEn;
  final String startingPrice;
  final IconData icon;
  final Color color;

  const _ApplianceItem({
    required this.category,
    required this.nameMr,
    required this.nameEn,
    required this.startingPrice,
    required this.icon,
    required this.color,
  });
}
