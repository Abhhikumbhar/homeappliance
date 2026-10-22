import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/appliance_service.dart';
import '../../models/booking.dart';
import '../../state/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import 'customer_bookings_screen.dart';
import '../../widgets/design_components.dart';

class BookingCheckoutScreen extends StatefulWidget {
  final ServicePackage service;
  final String? selectedBrand;
  final String? machineType;
  final String? problem;
  final String? selectedPart;
  final bool isSpecialization;
  final DateTime? preselectedDate;
  final String? preselectedSlot;

  const BookingCheckoutScreen({
    super.key,
    required this.service,
    this.selectedBrand,
    this.machineType,
    this.problem,
    this.selectedPart,
    this.isSpecialization = false,
    this.preselectedDate,
    this.preselectedSlot,
  });

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _notesController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final appState = AppStateScope.of(context);
      final user = appState.currentUser;
      _nameController = TextEditingController(
        text: user != null
            ? AppHelpers.localizedText(user.name, appState.isMarathi)
            : '',
      );
      _phoneController = TextEditingController(text: user?.phone ?? '');
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  late DateTime _bookingDate;
  String _selectedSlot = 'Today, 04:00 PM - 06:00 PM';
  PaymentMethod _selectedPayment = PaymentMethod.cashOnDelivery;
  double _lat = 16.8530;
  double _lng = 74.5820;

  final List<String> _slots = [
    'Today, 04:00 PM - 06:00 PM',
    'Tomorrow, 10:00 AM - 12:00 PM',
    'Tomorrow, 02:00 PM - 04:00 PM',
    'Day After Tomorrow, 11:00 AM - 01:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _bookingDate = widget.preselectedDate ?? DateTime.now();
    if (widget.preselectedSlot != null && widget.preselectedSlot!.trim().isNotEmpty) {
      _selectedSlot = widget.preselectedSlot!.trim();
      if (!_slots.contains(_selectedSlot)) {
        _slots.insert(0, _selectedSlot);
      }
    }
  }

  Future<void> _pickBookingDate(BuildContext context, bool isMr) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _bookingDate.isBefore(now) ? now : _bookingDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
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
        _bookingDate = picked;
      });
    }
  }

  final List<Map<String, dynamic>> _quickLocations = [
    {
      'title': 'Sangli - Vishrambag',
      'address': 'Flat 302, Shreya Heights, Vishrambag, Sangli',
      'landmark': 'Near Sayaji Hotel / Shivar Mall',
      'lat': 16.8530,
      'lng': 74.5820,
    },
    {
      'title': 'Sangli - Kupwad',
      'address': 'Bunglow 12, Ganesh Nagar, Kupwad, Sangli',
      'landmark': 'Near Kupwad Railway Gate',
      'lat': 16.8390,
      'lng': 74.6300,
    },
    {
      'title': 'Karad - Malkapur',
      'address': 'Plot 45, Somwar Peth, Malkapur, Karad',
      'landmark': 'Opposite Karad Urban Bank',
      'lat': 17.2845,
      'lng': 74.1840,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isMr = appState.isMarathi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          tr('बुकिंग व पत्ता निश्चित करा', 'Confirm Service Details'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('देय रक्कम', 'Payable Amount'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    AppHelpers.formatCurrency(widget.service.basePrice),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                  ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      tr('बुकिंग कन्फर्म करा', 'CONFIRM ORDER'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  onPressed: () => _submitBooking(context, appState, isMr),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Service Mini Summary Card
              _buildMiniSummary(isMr),
              const SizedBox(height: 16),

              // 2. Address & Google Map Pin Section
              _buildAddressSection(isMr),
              const SizedBox(height: 16),

              // 3. Time Slot Section
              _buildSlotSelection(isMr),
              const SizedBox(height: 16),

              // 4. Payment Selection
              _buildPaymentSelection(isMr),
              const SizedBox(height: 16),

              // 5. Special Instructions
              _buildNotesBox(isMr),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniSummary(bool isMr) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.service.category.icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(widget.service.titleMr, widget.service.titleEn),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.service.durationMinutes} mins • 30 Days Shield',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (widget.selectedBrand != null &&
                        widget.selectedBrand!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${tr("ब्रँड:", "Brand:")} ${widget.selectedBrand}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    if (widget.machineType != null &&
                        widget.machineType!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.machineType!,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6D28D9),
                          ),
                        ),
                      ),
                    if (widget.problem != null &&
                        widget.problem!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.problem!,
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
            ),
          ),
          Text(
            AppHelpers.formatCurrency(widget.service.basePrice),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(bool isMr) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                tr('सर्व्हिस पत्ता', 'Service Address & Location'),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Quick Presets
          Text(
            tr('झटपट पत्ता निवडा:', 'Quick Select City Area:'),
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _quickLocations.map((loc) {
                final isCur = _addressController.text == loc['address'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(loc['title']),
                    selected: isCur,
                    selectedColor: AppColors.primaryLight,
                    checkmarkColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isCur ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isCur ? FontWeight.bold : FontWeight.w500,
                      color: isCur ? AppColors.primary : AppColors.textPrimary,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _addressController.text = loc['address'];
                        _landmarkController.text = loc['landmark'];
                        _lat = loc['lat'];
                        _lng = loc['lng'];
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: tr('पूर्ण नाव', 'Full Name'),
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 19),
            ),
            validator: (v) => v == null || v.isEmpty ? 'कृपया नाव टाका' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              labelText: tr('मोबाईल नंबर', 'Contact Number'),
              counterText: '',
              prefixIcon: const Icon(Icons.phone_outlined, size: 19),
            ),
            validator: (v) {
              final trimmed = v?.trim() ?? '';
              if (trimmed.isEmpty) {
                return tr('कृपया नंबर टाका', 'Please enter phone number');
              }
              if (trimmed.length != 10) {
                return tr('कृपया १० अंकी वैध मोबाईल नंबर टाका', 'Please enter a valid 10-digit phone number');
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: tr('घरचा पूर्ण पत्ता', 'Complete Address'),
              prefixIcon: const Icon(Icons.home_outlined, size: 19),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'कृपया पत्ता टाका' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _landmarkController,
            decoration: InputDecoration(
              labelText: tr('जवळची खूण', 'Landmark (Nearby building / road)'),
              prefixIcon: const Icon(Icons.flag_outlined, size: 19),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotSelection(bool isMr) {
    final dateDisplay = AppHelpers.formatDate(_bookingDate);
    final isToday = DateUtils.isSameDay(_bookingDate, DateTime.now());
    final isTomorrow = DateUtils.isSameDay(
      _bookingDate,
      DateTime.now().add(const Duration(days: 1)),
    );
    final dayLabel = isToday
        ? tr('आज', 'Today')
        : isTomorrow
            ? tr('उद्या', 'Tomorrow')
            : '';

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tr('तारीख व वेळ निवडा', 'Select Date & Slot'),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _pickBookingDate(context, isMr),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_calendar_rounded, size: 15, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        tr('कॅलेंडर', 'Calendar'),
                        style: const TextStyle(
                          fontSize: 12,
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

          // Date Card
          InkWell(
            onTap: () => _pickBookingDate(context, isMr),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('सर्व्हिस भेटीची तारीख', 'Service Arrival Date'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dayLabel.isNotEmpty
                              ? '$dateDisplay ($dayLabel)'
                              : dateDisplay,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
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
          ),

          const SizedBox(height: 12),
          Text(
            tr('वेळेचा स्लॉट निवडा', 'Select Time Slot'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ..._slots.map((slot) {
            final isSelected = slot == _selectedSlot;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSlot = slot;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryLight
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      slot,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentSelection(bool isMr) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payment_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                tr('पेमेंट पर्याय', 'Payment Options'),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPaymentCard(
            method: PaymentMethod.cashOnDelivery,
            title: tr('काम झाल्यावर रोख पेमेंट', 'Pay After Service (Cash / UPI)'),
            subtitle: tr('कामगाराने काम पूर्ण केल्यावर थेट द्या', 'Pay technician directly once job is done'),
            icon: Icons.handshake_outlined,
          ),
          const SizedBox(height: 8),
          _buildPaymentCard(
            method: PaymentMethod.upiOnline,
            title: tr('ऑनलाइन पेमेंट', 'Pay Online Now (Razorpay / UPI)'),
            subtitle: tr('Google Pay, PhonePe, Paytm किंवा कार्ड', '100% Secure Gateway with Instant Guarantee'),
            icon: Icons.qr_code_2_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPayment == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPayment = method;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesBox(bool isMr) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('अतिरिक्त माहिती (पर्यायी)', 'Additional Notes (Optional)'),
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: tr('उदा. नळ जास्त गळत आहे / कुलिंग होत नाही...', 'e.g. Tap leaking heavily / no cooling...'),
            ),
          ),
        ],
      ),
    );
  }

  void _submitBooking(BuildContext context, AppState appState, bool isMr) {
    final brandPrefix = widget.selectedBrand != null &&
            widget.selectedBrand!.trim().isNotEmpty
        ? 'Brand: ${widget.selectedBrand!.trim()}'
        : '';
    final typePrefix = widget.machineType != null &&
            widget.machineType!.trim().isNotEmpty
        ? 'Type: ${widget.machineType!.trim()}'
        : '';
    final problemPrefix = widget.problem != null &&
            widget.problem!.trim().isNotEmpty
        ? 'Issue: ${widget.problem!.trim()}'
        : '';
    final userNotes = _notesController.text.trim();
    final combinedNotes = [brandPrefix, typePrefix, problemPrefix, userNotes]
        .where((s) => s.isNotEmpty)
        .join(' | ');

    final newBooking = appState.createBooking(
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      landmark: _landmarkController.text.trim(),
      latitude: _lat,
      longitude: _lng,
      service: widget.service,
      scheduledDate: _bookingDate,
      scheduledSlot: _selectedSlot,
      paymentMethod: _selectedPayment,
      notes: combinedNotes,
      brand: widget.selectedBrand,
      machineType: widget.machineType,
      problem: widget.problem,
      selectedPart: widget.selectedPart,
      isSpecialization: widget.isSpecialization,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 26,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr('बुकिंग यशस्वी झाले!', 'Service Request Placed!'),
                  style: const TextStyle(
                    fontSize: 16.5,
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
                tr('आपले बुकिंग नोंदवले गेले आहे आणि ॲडमिन मंजुरीसाठी पाठवले आहे.', 'Your request has been placed and sent for Admin approval.'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'बुकिंग आयडी: ${newBooking.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr('सुरक्षित OTP:', 'Secure OTP:'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.accent,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            newBooking.startOtp,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                              fontSize: 16,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.hourglass_top_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tr('स्थिती: ॲडमिन मंजुरी प्रलंबित', 'Status: Pending Admin Approval'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
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
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerBookingsScreen(),
                  ),
                );
              },
              child: Text(tr('ट्रॅकिंग बघा', 'TRACK REQUEST')),
            ),
          ],
        );
      },
    );
  }
}
