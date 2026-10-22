import 'package:flutter/material.dart';

import '../../models/appliance_service.dart';
import '../../state/app_state.dart';
import '../../utils/colors.dart';
import 'booking_checkout_screen.dart';
import '../../widgets/design_components.dart';

/// High-Fidelity Service Detail & Slot Booking Screen (Matching Stitch Screen 3)
class ServiceDetailScreen extends StatefulWidget {
  final ServicePackage service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  int _selectedTypeIndex = 0;
  int _quantity = 1;
  String _selectedBrand = 'Voltas';
  final TextEditingController _otherBrandController = TextEditingController();
  final FocusNode _otherBrandFocusNode = FocusNode();
  late DateTime _selectedDate;
  DateTime? _customCalendarDate;
  int _selectedSlotIndex = 1; // 11:30 AM (Popular)
  bool _isWishlisted = false;

  final List<String> _acTypes = ['Split AC', 'Window AC', 'Cassette / Tower'];

  List<String> get _brandsForService {
    switch (widget.service.category) {
      case ServiceCategory.roWater:
        return ['Kent', 'Aquaguard', 'Pureit', 'Livpure', 'Eureka Forbes', 'Other'];
      case ServiceCategory.refrigerator:
        return ['Whirlpool', 'LG', 'Samsung', 'Godrej', 'Haier', 'Other'];
      case ServiceCategory.washingMachine:
        return ['LG', 'Samsung', 'IFB', 'Whirlpool', 'Bosch', 'Other'];
      case ServiceCategory.geyser:
        return ['AO Smith', 'Havells', 'Bajaj', 'Crompton', 'Racold', 'Other'];
      case ServiceCategory.chimney:
        return ['Faber', 'Elica', 'Glen', 'Hindware', 'Kaff', 'Other'];
      case ServiceCategory.ac:
      default:
        return ['Voltas', 'Daikin', 'LG', 'Samsung', 'Blue Star', 'Other'];
    }
  }

  @override
  void initState() {
    super.initState();
    final brands = _brandsForService;
    _selectedBrand = brands.first;
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _otherBrandController.dispose();
    _otherBrandFocusNode.dispose();
    super.dispose();
  }

  String get _effectiveBrand {
    if (_selectedBrand == 'Other') {
      final typed = _otherBrandController.text.trim();
      return typed.isNotEmpty ? typed : 'Other';
    }
    return _selectedBrand;
  }

  static const List<String> _enMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const List<String> _mrMonths = [
    'जाने', 'फेब्रु', 'मार्च', 'एप्रि', 'मे', 'जून', 'जुलै', 'ऑगस्ट', 'सप्टें', 'ऑक्टो', 'नोव्हें', 'डिसे'
  ];
  static const List<String> _enDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> _mrDays = ['सोम', 'मंगळ', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'];
  static const List<String> _mrDaysFull = [
    'सोमवार', 'मंगळवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'
  ];
  static const List<String> _enDaysFull = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatSelectedDateShort(bool isMr) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_isSameDay(_selectedDate, today)) {
      return isMr ? 'आज' : 'Today';
    } else if (_isSameDay(_selectedDate, today.add(const Duration(days: 1)))) {
      return isMr ? 'उद्या' : 'Tomorrow';
    }
    final monthStr = isMr
        ? _mrMonths[_selectedDate.month - 1]
        : _enMonths[_selectedDate.month - 1];
    return '${_selectedDate.day} $monthStr';
  }

  String _formatSelectedDateFull(bool isMr) {
    final weekdayStr = isMr
        ? _mrDaysFull[_selectedDate.weekday - 1]
        : _enDaysFull[_selectedDate.weekday - 1];
    final monthStr = isMr
        ? _mrMonths[_selectedDate.month - 1]
        : _enMonths[_selectedDate.month - 1];
    return '$weekdayStr, ${_selectedDate.day} $monthStr ${_selectedDate.year}';
  }

  List<_BookingDateOption> _getBookingDates(bool isMr) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final list = <_BookingDateOption>[];

    // 4 dynamic days starting from today onwards
    for (int i = 0; i < 4; i++) {
      final d = today.add(Duration(days: i));
      String label;
      String status;
      if (i == 0) {
        label = isMr ? 'आज' : 'Today';
        status = isMr ? 'जलद' : 'Fastest';
      } else if (i == 1) {
        label = isMr ? 'उद्या' : 'Tomorrow';
        status = isMr ? 'उपलब्ध' : 'Available';
      } else if (i == 2) {
        label = isMr ? 'परवा' : _enDays[d.weekday - 1];
        status = isMr ? 'उपलब्ध' : 'Available';
      } else {
        label = isMr ? _mrDays[d.weekday - 1] : _enDays[d.weekday - 1];
        status = isMr ? 'उपलब्ध' : 'Available';
      }
      final monthStr = isMr ? _mrMonths[d.month - 1] : _enMonths[d.month - 1];
      final dateStr = '${d.day} $monthStr';
      list.add(_BookingDateOption(
        date: d,
        label: label,
        formattedDate: dateStr,
        status: status,
      ));
    }

    // If custom date was picked and it's not within the first 4 days, display it
    if (_customCalendarDate != null) {
      final d = _customCalendarDate!;
      final alreadyInList = list.any((item) => _isSameDay(item.date, d));
      if (!alreadyInList) {
        final monthStr = isMr ? _mrMonths[d.month - 1] : _enMonths[d.month - 1];
        list.add(_BookingDateOption(
          date: d,
          label: isMr ? 'कॅलेंडर' : 'Custom',
          formattedDate: '${d.day} $monthStr',
          status: isMr ? 'निवडले' : 'Selected',
          isCustom: true,
        ));
      }
    }

    return list;
  }

  Future<void> _pickDateFromCalendar(BuildContext context, bool isMr) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = _selectedDate.isBefore(today) ? today : _selectedDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
      helpText: isMr ? 'सर्व्हिस तारीख निवडा' : 'Select Service Arrival Date',
      confirmText: isMr ? 'निश्चित करा' : 'Confirm',
      cancelText: isMr ? 'रद्द करा' : 'Cancel',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        final diff = _selectedDate.difference(today).inDays;
        if (diff >= 4) {
          _customCalendarDate = _selectedDate;
        } else {
          _customCalendarDate = null;
        }
      });
    }
  }

  final List<Map<String, dynamic>> _slots = [
    {'time': '09:00 AM', 'tag': null},
    {'time': '11:30 AM', 'tag': 'Popular'},
    {'time': '02:00 PM', 'tag': null},
    {'time': '04:30 PM', 'tag': 'Fastest'},
    {'time': '07:00 PM', 'tag': null},
  ];

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isMr = appState.isMarathi;
    final service = widget.service;

    final unitPrice = service.basePrice;
    final originalUnitPrice = service.originalPrice;
    final totalPrice = unitPrice * _quantity;
    final totalOriginalPrice = originalUnitPrice * _quantity;

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
            Text(
              tr(service.titleMr, service.titleEn),
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              tr('ServeEase प्रो केअर • ९० दिवस वॉरंटी', 'ServeEase Pro Care • 90-Day Warranty'),
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
            icon: Icon(
              _isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isWishlisted ? AppColors.accent : AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () {
              setState(() => _isWishlisted = !_isWishlisted);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isWishlisted
                        ? (tr('विशलिस्टमध्ये सेव्ह केले!', 'Saved to Wishlist!'))
                        : (tr('विशलिस्टमधून काढले', 'Removed from Wishlist')),
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    tr('सर्व्हिस लिंक कॉपी केली!', 'Service link copied to clipboard!'),
                  ),
                  duration: const Duration(seconds: 1),
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
      bottomNavigationBar: StickyBottomCheckoutBar(
        currentPrice: totalPrice,
        originalPrice: totalOriginalPrice > totalPrice ? totalOriginalPrice : null,
        ctaLabel: tr('स्लॉट बुक करा', 'Select Time & Book'),
        subtitle: tr('सर्व्हिसनंतर पेमेंट करा', 'Pay After Service Done'),
        onCtaPressed: () {
          final chosenSlotTime = _slots[_selectedSlotIndex]['time'];
          final dateSummary = _formatSelectedDateShort(isMr);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingCheckoutScreen(
                service: service,
                selectedBrand: _effectiveBrand,
                preselectedDate: _selectedDate,
                preselectedSlot: '$dateSummary, $chosenSlotTime',
              ),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO VISUAL & SERVICE OVERVIEW CARD
            _buildHeroOverviewCard(service, isMr),

            const SizedBox(height: 14),

            // 2. APPLIANCE TYPE SELECTOR
            _buildApplianceTypeSelector(isMr),

            const SizedBox(height: 14),

            // 3. QUANTITY & LIVE MULTI-UNIT SAVINGS STEPPER
            _buildQuantityStepperCard(unitPrice, isMr),

            const SizedBox(height: 14),

            // 4. APPLIANCE BRAND SELECTOR CHIPS
            _buildBrandSelectorChips(isMr),

            const SizedBox(height: 14),

            // 5. "WHAT'S INCLUDED" 5-STEP DETAILED CHECKLIST
            _buildWhatsIncludedChecklist(service, isMr),

            const SizedBox(height: 14),

            // 6. DATE & TIME ARRIVAL SLOT PICKER (MATCHING STITCH SCREEN 3)
            _buildSlotPickerSection(isMr),

            const SizedBox(height: 14),

            // 7. TRANSPARENT RATE CARD & GENUINE OEM SPARES GUARANTEE
            _buildRateCardAndTrustBanner(isMr),

            const SizedBox(height: 14),

            // 8. CUSTOMER REVIEWS & RATINGS SNAPSHOT
            _buildCustomerReviewsSnapshot(service, isMr),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // 1. HERO VISUAL & SERVICE OVERVIEW CARD
  // ========================================================
  Widget _buildHeroOverviewCard(ServicePackage service, bool isMr) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Hero Banner with High Pressure Jet Wash Graphic
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF003B99), Color(0xFF0052CC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Stack(
              children: [
                // Background subtle circular patterns
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Icon(
                            service.category.icon,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tr('🔥 समर बेस्टसेलर • २५% सूट', '🔥 Summer Bestseller • Flat 25% Off'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              tr(service.titleMr, service.titleEn),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Overview Details & Specs
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(service.descriptionMr, service.descriptionEn),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPillSpec(
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      text: '${service.rating} (${service.reviewsCount})',
                      bgColor: const Color(0xFFFFFBEB),
                      borderColor: const Color(0xFFFDE68A),
                    ),
                    const SizedBox(width: 8),
                    _buildPillSpec(
                      icon: Icons.schedule_rounded,
                      iconColor: AppColors.primary,
                      text: '${service.durationMinutes} mins',
                      bgColor: AppColors.primaryLight,
                      borderColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 8),
                    _buildPillSpec(
                      icon: Icons.shield_rounded,
                      iconColor: AppColors.success,
                      text: tr('९० दिवस वॉरंटी', '90-Day Cover'),
                      bgColor: AppColors.successLight,
                      borderColor: AppColors.successBorder,
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

  Widget _buildPillSpec({
    required IconData icon,
    required Color iconColor,
    required String text,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 2. APPLIANCE TYPE SELECTOR
  // ========================================================
  Widget _buildApplianceTypeSelector(bool isMr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('१. उपकरणाचा प्रकार निवडा', '1. Select Appliance Type'),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_acTypes.length, (index) {
              final isSelected = _selectedTypeIndex == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < _acTypes.length - 1 ? 8 : 0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedTypeIndex = index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _acTypes[index],
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 3. QUANTITY & LIVE MULTI-UNIT SAVINGS STEPPER
  // ========================================================
  Widget _buildQuantityStepperCard(num unitPrice, bool isMr) {
    final priceStr = unitPrice == unitPrice.roundToDouble()
        ? unitPrice.toInt().toString()
        : unitPrice.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('२. उपकरणांची संख्या', '2. Number of Appliance Units'),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                tr('₹$priceStr प्रति युनिट', '₹$priceStr per unit with warranty'),
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove_rounded, size: 18),
                  color: AppColors.textPrimary,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _quantity < 10 ? () => setState(() => _quantity++) : null,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  color: AppColors.primary,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 4. APPLIANCE BRAND SELECTOR CHIPS
  // ========================================================
  Widget _buildBrandSelectorChips(bool isMr) {
    final brands = _brandsForService;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('३. ब्रँड निवडा (Brand / Make)', '3. Select Brand / Make'),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: brands.map((brand) {
              final isSelected = _selectedBrand == brand;
              return InkWell(
                onTap: () {
                  setState(() => _selectedBrand = brand);
                  if (brand == 'Other') {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _otherBrandFocusNode.requestFocus();
                    });
                  } else {
                    _otherBrandFocusNode.unfocus();
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    brand == 'Other' ? tr('इतर (Other)', 'Other') : brand,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedBrand == 'Other') ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _otherBrandController,
                focusNode: _otherBrandFocusNode,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  hintText: tr('कंपनी / ब्रँडचे नाव टाईप करा (उदा. व्हर्लपूल, पॅनासोनिक...)', 'Enter company / brand name (e.g. Whirlpool, Panasonic...)'),
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: const Icon(
                    Icons.business_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  suffixIcon: _otherBrandController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () {
                            _otherBrandController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                tr('तुमच्या उपकरणाची कोणतीही कंपनी येथे थेट टाईप करू शकता', 'Type any brand or company of your appliance here'),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ========================================================
  // 5. "WHAT'S INCLUDED" 5-STEP DETAILED CHECKLIST
  // ========================================================
  Widget _buildWhatsIncludedChecklist(ServicePackage service, bool isMr) {
    final checklist = [
      {
        'title': tr('हाय-प्रेशर जेट कॉइल वॉश', 'Indoor Cooling Coil Jet Wash'),
        'desc': tr('२.५ बार प्रेशर पंप आणि वॉटरप्रूफ कव्हरसह संपूर्ण कॉइल वॉश.', '2.5 bar pressure pump wash with protective shroud.'),
      },
      {
        'title': tr('अँटी-फंगल फोम व सॅनिटायझेशन', 'Anti-Fungal Foam Disinfection'),
        'desc': tr('जंतू आणि दुर्गंधी नष्ट करण्यासाठी जर्मन क्लिनर स्प्रे.', 'Bio-safe anti-microbial foam wash for hygienic fresh air.'),
      },
      {
        'title': tr('आऊटडोअर युनिट हाय-प्रेशर फ्लश', 'Outdoor Condenser Unit Flush'),
        'desc': tr('कंडेन्सरमधील धूळ काढून कूलिंग कार्यक्षमता ३०% वाढवणे.', 'Clears hardened dirt, reduces load and power consumption.'),
      },
      {
        'title': tr('गॅस प्रेशर व तापमान तपासणी', 'Gas Pressure & Laser Temp Audit'),
        'desc': tr('डिजिटल लेझर थर्मामीटरने ग्रिलचे अचूक तापमान मोजणे.', 'Pre and post service temperature verification test.'),
      },
      {
        'title': tr('९० दिवस वॉरंटी व फ्री रिव्हिजिट', '90-Day Free Revisit Guarantee'),
        'desc': tr('अ‍ॅपमध्ये डिजिटल वॉरंटी कार्ड लगेच जनरेट होते.', 'Instant digital warranty stamp with zero-cost re-service.'),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.verified_rounded, color: AppColors.success, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                tr('४. या सेवेत काय समाविष्ट आहे?', "4. What's Included (10-Step Standard)"),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: checklist.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['desc']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 6. DATE & TIME ARRIVAL SLOT PICKER
  // ========================================================
  Widget _buildSlotPickerSection(bool isMr) {
    final bookingDates = _getBookingDates(isMr);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('५. तारीख व वेळ निवडा', '5. Select Arrival Date & Slot'),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () => _pickDateFromCalendar(context, isMr),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tr('कॅलेंडर', 'Calendar'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date Horizontal Cards with Calendar Option
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                ...bookingDates.map((item) {
                  final isSelected = _isSameDay(_selectedDate, item.date);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedDate = item.date),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 70),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.formattedDate,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Dedicated "Open Calendar" Card
                InkWell(
                  onTap: () => _pickDateFromCalendar(context, isMr),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 72),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.edit_calendar_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr('+ इतर तारीख', '+ More'),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Selected Date Confirmation Banner
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isMr
                        ? 'निवडलेली तारीख: ${_formatSelectedDateFull(isMr)}'
                        : 'Arrival: ${_formatSelectedDateFull(isMr)}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _pickDateFromCalendar(context, isMr),
                  child: Text(
                    tr('बदला', 'Change'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Time Slots Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_slots.length, (idx) {
              final isSelected = _selectedSlotIndex == idx;
              final s = _slots[idx];
              return InkWell(
                onTap: () => setState(() => _selectedSlotIndex = idx),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryLight : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s['time'],
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      if (s['tag'] != null) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            s['tag'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 7. TRANSPARENT RATE CARD & GENUINE OEM SPARES GUARANTEE
  // ========================================================
  Widget _buildRateCardAndTrustBanner(bool isMr) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security_rounded, color: Color(0xFF059669), size: 18),
              const SizedBox(width: 8),
              Text(
                tr('ServeEase पारदर्शक दर हमी', 'ServeEase Fair Rate & Spares Shield'),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF065F46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tr('• कोणतेही छुपे शुल्क नाही • १००% ओरिजिनल OEM स्पेअर पार्ट्स • अधिकृत दरपत्रकानुसारच बिलिंग.', '• Zero hidden charges • Standard rate card for spares • 100% Genuine OEM parts with barcode verification.'),
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF047857),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 8. CUSTOMER REVIEWS & RATINGS SNAPSHOT
  // ========================================================
  Widget _buildCustomerReviewsSnapshot(ServicePackage service, bool isMr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('ग्राहकांचे अभिप्राय', 'Verified Customer Reviews'),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 3),
                  Text(
                    '${service.rating} / 5',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primaryLight,
                      child: const Text(
                        'R',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('सत्यापित ग्राहक', 'Verified Customer'),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            tr(service.titleMr, service.titleEn),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                        Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                        Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                        Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                        Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tr('"तंत्रज्ञ वेळेत आले आणि काम अत्यंत प्रामाणिकपणे व दर्जेदार पद्धतीने पूर्ण केले. १००% समाधान!"', '"Technician was punctual, polite, and resolved the issue efficiently with genuine tools and parts. Highly satisfied!"'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.35,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingDateOption {
  final DateTime date;
  final String label;
  final String formattedDate;
  final String status;
  final bool isCustom;

  const _BookingDateOption({
    required this.date,
    required this.label,
    required this.formattedDate,
    required this.status,
    this.isCustom = false,
  });
}
