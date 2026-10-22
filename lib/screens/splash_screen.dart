import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/appliance_service.dart';
import '../models/user_account.dart';
import '../state/app_state.dart';
import '../utils/colors.dart';
import '../widgets/language_dropdown.dart';
import '../widgets/live_appliance_animation.dart';
import 'admin/admin_dashboard_screen.dart';
import 'auth/login_screen.dart';
import 'customer/customer_home_screen.dart';
import 'partner/partner_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashSlide {
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

  const _SplashSlide({
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
    required this.ctaColor,
    this.isSpecialization = false,
  });
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  Timer? _slideTimer;
  Timer? _autoNavigateTimer;
  int _currentPage = 0;
  bool _hasNavigated = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const List<_SplashSlide> _slides = [
    _SplashSlide(
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
    _SplashSlide(
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
    _SplashSlide(
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
    _SplashSlide(
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _pageController = PageController();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // 2-second slide animation timer as requested
    _slideTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });

    // Auto-navigate after showing all slides (~8 seconds = 4 slides * 2 sec)
    _autoNavigateTimer = Timer(const Duration(seconds: 9), () {
      if (mounted && !_hasNavigated) {
        _navigateToDestination();
      }
    });
  }

  void _navigateToDestination({
    ServiceCategory? selectedCategory,
    bool openSpecialization = false,
  }) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _slideTimer?.cancel();
    _autoNavigateTimer?.cancel();

    final appState = AppStateScope.of(context);
    Widget destination;
    if (appState.isLoggedIn && appState.currentUser != null) {
      final user = appState.currentUser!;
      if (user.role == UserRole.admin) {
        destination = const AdminDashboardScreen();
      } else if (user.role == UserRole.partner) {
        destination = const PartnerDashboardScreen();
      } else {
        destination = CustomerHomeScreen(
          initialCategory: selectedCategory,
          openWmSpecialization: openSpecialization,
        );
      }
    } else {
      destination = const LoginScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _autoNavigateTimer?.cancel();
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Top Bar: Brand, Language Dropdown & Skip Action
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                child: Row(
                  children: [
                    // Brand Icon
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
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.home_repair_service_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Brand Titles with proper formatting & single-line guarantee
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              tr('होम अप्लायन्स', 'Home Appliance'),
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr('ऑन-डिमांड घरगुती सेवा', 'On-Demand Services'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Language Switcher
                    const LanguageDropdown(compact: true),
                    const SizedBox(width: 6),
                    // Skip Action
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        visualDensity: VisualDensity.compact,
                        foregroundColor: AppColors.primary,
                      ),
                      onPressed: () => _navigateToDestination(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tr('पुढे जा', 'Skip'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Title Headline
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tr('आमच्या विशेष ऑफर्स व सेवा', 'Special Offers & Services'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Main Animated Slide Card (Matching User's Screenshot)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: slide.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: slide.gradientColors.first.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Background Decorative Watermark Icon
                            Positioned(
                              right: -20,
                              bottom: -20,
                              child: Opacity(
                                opacity: 0.08,
                                child: Icon(
                                  slide.backgroundIcon,
                                  size: 220,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            // Main Slide Content
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                22,
                                20,
                                20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Promo Pill Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.22,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      tr(slide.badgeMr, slide.badgeEn),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  const Spacer(),

                                  // Row: Left Text & Action + Right Appliance Photo Card
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Left Text & CTA Button
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              tr(slide.titleMr, slide.titleEn),
                                              style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                height: 1.2,
                                                letterSpacing: -0.4,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              tr(slide.subtitleMr, slide.subtitleEn),
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                color: Colors.white70,
                                                height: 1.35,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 16),

                                            // CTA Button (Matching Screenshot)
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: slide.ctaColor,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 11,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                elevation: 4,
                                              ),
                                              onPressed: () {
                                                _navigateToDestination(
                                                  selectedCategory:
                                                      slide.category,
                                                  openSpecialization:
                                                      slide.isSpecialization,
                                                );
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.flash_on_rounded,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    tr('आता बुक करा', 'Book Now'),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.2,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  const Icon(
                                                    Icons.arrow_forward_rounded,
                                                    size: 15,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 14),

                                      // Right Appliance Image Card with Live Animations
                                      LiveApplianceAnimationCard(
                                        imageAsset: slide.imageAsset,
                                        category: slide.category,
                                        fallbackIcon: slide.backgroundIcon,
                                        width: 136,
                                        height: 136,
                                        borderRadius: 22,
                                      ),
                                    ],
                                  ),

                                  const Spacer(),

                                  // Pagination Dots (Bottom Left - Matching Screenshot)
                                  Row(
                                    children: List.generate(
                                      _slides.length,
                                      (dotIdx) => AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: const EdgeInsets.only(right: 6),
                                        width:
                                            _currentPage == dotIdx ? 24 : 6.5,
                                        height: 6.5,
                                        decoration: BoxDecoration(
                                          color: _currentPage == dotIdx
                                              ? Colors.white
                                              : Colors.white.withValues(
                                                  alpha: 0.4,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Trust Badges Pill Strip
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeaturePill(
                      icon: Icons.timer_outlined,
                      label: tr('३० मिनिटांत सेवा', '30 Min Express'),
                    ),
                    Container(
                      width: 1,
                      height: 18,
                      color: const Color(0xFFE2E8F0),
                    ),
                    _buildFeaturePill(
                      icon: Icons.shield_outlined,
                      label: tr('९० दिवस वॉरंटी', '90-Day Warranty'),
                    ),
                    Container(
                      width: 1,
                      height: 18,
                      color: const Color(0xFFE2E8F0),
                    ),
                    _buildFeaturePill(
                      icon: Icons.verified_user_outlined,
                      label: tr('प्रशिक्षित तज्ज्ञ', 'Verified Pros'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Bottom Primary Action CTA Button: "सुरू करा / Get Started"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _navigateToDestination(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tr('ॲप सुरू करा', 'Get Started'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 19),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}
