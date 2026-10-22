import 'package:flutter/material.dart';

import '../../models/booking.dart';
import '../../models/wm_specialization.dart';
import '../../models/technician.dart';
import '../../models/appliance_service.dart';
import '../../state/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import '../../widgets/design_components.dart';

class AdminWmSpecializationView extends StatefulWidget {
  const AdminWmSpecializationView({super.key});

  @override
  State<AdminWmSpecializationView> createState() =>
      _AdminWmSpecializationViewState();
}

class _AdminWmSpecializationViewState extends State<AdminWmSpecializationView>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isMr = appState.isMarathi;
    final config = appState.wmSpecializationConfig;

    return Column(
      children: [
        // Top Master Status Banner
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: config.isServiceAvailable
                          ? AppColors.successLight
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      config.isServiceAvailable
                          ? Icons.check_circle_rounded
                          : Icons.pause_circle_rounded,
                      color: config.isServiceAvailable
                          ? AppColors.success
                          : Colors.red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('वॉशिंग मशीन स्पेशलायझेशन लॅब',
                              'Washing Machine Specialization Control'),
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          config.isServiceAvailable
                              ? tr('ऑनलाइन • बुकिंग स्वीकारणे सुरू आहे',
                                  'Online • Accepting Customer Bookings')
                              : tr('ऑफलाइन • सेवा तात्पुरती थांबवली आहे',
                                  'Offline • Service Paused by Admin'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: config.isServiceAvailable
                                ? AppColors.success
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: config.isServiceAvailable,
                    activeColor: AppColors.success,
                    onChanged: (val) {
                      appState.toggleWmSpecializationAvailability(val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Sub tabs bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _subTabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: [
                    Tab(text: tr('ब्रँड्स व्यवस्थापन', 'Brands (${config.brands.length})')),
                    Tab(text: tr('सेवा व दर', 'Services (${config.services.length})')),
                    Tab(text: tr('पार्ट्स व समस्या', 'Parts & Rules')),
                    Tab(text: tr('बुकिंग्ज', 'WM Bookings')),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Sub Tab View Content
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildBrandsTab(context, appState, config, isMr),
              _buildServicesTab(context, appState, config, isMr),
              _buildPartsTab(context, appState, config, isMr),
              _buildBookingsTab(context, appState, isMr),
            ],
          ),
        ),
      ],
    );
  }

  // ========================================================
  // SUB TAB 1: BRANDS MANAGEMENT (Requirement 6.1)
  // ========================================================
  Widget _buildBrandsTab(
    BuildContext context,
    AppState appState,
    WashingMachineSpecializationConfig config,
    bool isMr,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('सपोर्टेड ब्रँड्स', 'Supported WM Brands'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  tr('ब्रँड सक्रिय / निष्क्रिय करा किंवा नवीन जोडा',
                      'Activate, deactivate or add new brands'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(
                tr('नवीन ब्रँड', 'Add Brand'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showAddOrEditBrandDialog(context, appState, null, isMr),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...config.brands.map((brand) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: brand.isActive ? AppColors.border : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 38,
                  decoration: BoxDecoration(
                    color: brand.isActive
                        ? brand.accentColor
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
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
                            brand.name,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: brand.isActive
                                  ? AppColors.textPrimary
                                  : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: brand.isActive
                                  ? AppColors.successLight
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              brand.isActive
                                  ? tr('सक्रिय', 'Active')
                                  : tr('निष्क्रिय', 'Deactivated'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: brand.isActive
                                    ? AppColors.success
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tr("तपासणी फी:", "Inspection:")} ${AppHelpers.formatCurrency(brand.inspectionFee)} • ${brand.supportedMachineTypes.join(', ')}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: tr('संपादित करा', 'Edit'),
                  onPressed: () =>
                      _showAddOrEditBrandDialog(context, appState, brand, isMr),
                ),
                Switch.adaptive(
                  value: brand.isActive,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    appState.toggleWmBrandStatus(brand.id, val);
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ========================================================
  // SUB TAB 2: SPECIALIZATION SERVICES & PRICING (Requirement 6.2 & 6.3)
  // ========================================================
  Widget _buildServicesTab(
    BuildContext context,
    AppState appState,
    WashingMachineSpecializationConfig config,
    bool isMr,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Coverage and General Settings Strip
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('सेवा कव्हरेज व शहरे', 'Service Coverage Cities'),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.edit_location_alt_rounded, size: 16),
                    label: Text(tr('कव्हरेज बदला', 'Edit Cities')),
                    onPressed: () =>
                        _showCoverageCitiesDialog(context, appState, config, isMr),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: config.serviceCoverageCities.map((city) {
                  return Chip(
                    label: Text(city, style: const TextStyle(fontSize: 11)),
                    backgroundColor: AppColors.primaryLight,
                    side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          tr('स्पेशलायझेशन सेवा व दर (Configurable)',
              'Specialization Services & Rates'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tr('दर, तपासणी फी व वॉरंटी दिवस गरजेनुसार बदला:',
              'Configure service charges, inspection fees & warranty days:'),
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        ...config.services.map((srv) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(srv.icon, size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            srv.titleEn,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            srv.titleMr,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, size: 20, color: AppColors.primary),
                      tooltip: tr('दर बदला', 'Configure Rates'),
                      onPressed: () =>
                          _showEditServicePricingDialog(context, appState, srv, isMr),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  srv.descriptionEn,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${tr("दुरुस्ती दर:", "Base Charge:")} ${AppHelpers.formatCurrency(srv.basePrice)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${tr("तपासणी:", "Inspection:")} ${AppHelpers.formatCurrency(srv.inspectionFee)}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${srv.warrantyDays}D Warranty',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ========================================================
  // SUB TAB 3: PARTS & COMPATIBILITY MANAGEMENT (Requirement 6.2)
  // ========================================================
  Widget _buildPartsTab(
    BuildContext context,
    AppState appState,
    WashingMachineSpecializationConfig config,
    bool isMr,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('पार्ट्स व समस्या यादी', 'Parts & Problem Rules'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  tr('सुसंगत पार्ट्स व अंदाजे किंमत श्रेणी',
                      'Compatible components and pricing ranges'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(
                tr('नवीन पार्ट', 'Add Part'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showAddOrEditPartDialog(context, appState, null, isMr),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...config.parts.map((part) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: part.isActive ? AppColors.border : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: part.isActive
                        ? AppColors.primaryLight
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    part.icon,
                    size: 20,
                    color: part.isActive
                        ? AppColors.primary
                        : Colors.grey.shade400,
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
                              part.nameEn,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: part.isActive
                                    ? AppColors.textPrimary
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ),
                          Text(
                            '${AppHelpers.formatCurrency(part.estimatedMinPrice)} - ${AppHelpers.formatCurrency(part.estimatedMaxPrice)}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        part.nameMr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Types: ${part.applicableMachineTypes.join(', ')}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: tr('संपादित करा', 'Edit'),
                  onPressed: () =>
                      _showAddOrEditPartDialog(context, appState, part, isMr),
                ),
                Switch.adaptive(
                  value: part.isActive,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    appState.toggleWmPartStatus(part.id, val);
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ========================================================
  // SUB TAB 4: WASHING MACHINE BOOKINGS (Requirement 6.5 & 6.6)
  // ========================================================
  Widget _buildBookingsTab(
    BuildContext context,
    AppState appState,
    bool isMr,
  ) {
    final wmBookings = appState.bookings.where((b) {
      return b.isSpecialization ||
          b.service.category == ServiceCategory.washingMachine ||
          (b.brand != null && b.brand!.isNotEmpty);
    }).toList();

    if (wmBookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: EmptyStateWidget(
            icon: Icons.local_laundry_service_outlined,
            title: tr('कोणतेही वॉशिंग मशीन बुकिंग नाही', 'No WM Bookings Yet'),
            description: tr(
              'ग्राहकांनी वॉशिंग मशीन स्पेशलिस्ट सेवा बुक केल्यावर ते येथे दिसतील.',
              'When customers book washing machine services, they will appear here.',
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: wmBookings.length,
      itemBuilder: (context, index) {
        final b = wmBookings[index];
        return _buildBookingAdminCard(context, appState, b, isMr);
      },
    );
  }

  Widget _buildBookingAdminCard(
    BuildContext context,
    AppState appState,
    Booking b,
    bool isMr,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${b.id}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (b.isSpecialization) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB800),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'SPECIALIST',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getStatusColor(b.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  b.status.localizedName(isMr),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(b.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            b.service.localizedTitle(isMr),
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Brand, Machine Type, Problem Chips
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (b.brand != null && b.brand!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Brand: ${b.brand}',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              if (b.machineType != null && b.machineType!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    b.machineType!,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6D28D9),
                    ),
                  ),
                ),
              if (b.problem != null && b.problem!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    b.problem!,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            '${b.customerName} • ${b.customerPhone}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          Text(
            '${b.address} (${b.landmark})',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          Text(
            '${AppHelpers.formatDate(b.scheduledDate)} • ${b.scheduledSlot}',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OTP: ${b.startOtp}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.person_add_outlined, size: 14),
                    label: Text(
                      b.technicianName != null ? b.technicianName! : tr('पार्टनर निवडा', 'Assign'),
                      style: const TextStyle(fontSize: 11),
                    ),
                    onPressed: () =>
                        _showAssignPartnerDialog(context, appState, b, isMr),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () =>
                        _showUpdateStatusDialog(context, appState, b, isMr),
                    child: Text(
                      tr('स्टेटस बदला', 'Status'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFF59E0B);
      case BookingStatus.assigned:
        return const Color(0xFF0284C7);
      case BookingStatus.onTheWay:
        return const Color(0xFF6366F1);
      case BookingStatus.inProgress:
        return const Color(0xFF8B5CF6);
      case BookingStatus.completed:
        return const Color(0xFF10B981);
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  // ========================================================
  // DIALOGS
  // ========================================================
  void _showAddOrEditBrandDialog(
    BuildContext context,
    AppState appState,
    WashingMachineBrand? brand,
    bool isMr,
  ) {
    final nameCtrl = TextEditingController(text: brand?.name ?? '');
    final feeCtrl = TextEditingController(
      text: brand != null ? brand.inspectionFee.toStringAsFixed(0) : '249',
    );
    final selectedTypes = Set<String>.from(
      brand?.supportedMachineTypes ?? MachineTypeConstants.all,
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              title: Text(
                brand == null
                    ? tr('नवीन ब्रँड जोडा', 'Add New WM Brand')
                    : tr('ब्रँड माहिती संपादित करा', 'Edit Brand: ${brand.name}'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: tr('ब्रँडचे नाव', 'Brand Name'),
                        hintText: 'e.g. Bosch, IFB, Samsung',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: feeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: tr('तपासणी फी (₹)', 'Inspection Fee (₹)'),
                        hintText: '249',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      tr('सपोर्टेड मशीन प्रकार:', 'Supported Machine Types:'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...MachineTypeConstants.all.map((type) {
                      final isChecked = selectedTypes.contains(type);
                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(type, style: const TextStyle(fontSize: 12.5)),
                        value: isChecked,
                        onChanged: (val) {
                          setDlgState(() {
                            if (val == true) {
                              selectedTypes.add(type);
                            } else {
                              selectedTypes.remove(type);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                if (brand != null)
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      appState.deleteWmBrand(brand.id);
                      Navigator.pop(ctx);
                    },
                    child: Text(tr('हटवा', 'Delete')),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(tr('रद्द करा', 'Cancel')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final fee = double.tryParse(feeCtrl.text.trim()) ?? 249.0;
                    if (name.isEmpty) return;

                    final newBrand = WashingMachineBrand(
                      id: brand?.id ??
                          'brand_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
                      name: name,
                      isActive: brand?.isActive ?? true,
                      inspectionFee: fee,
                      supportedMachineTypes: selectedTypes.toList(),
                    );

                    appState.updateWmBrand(newBrand);
                    Navigator.pop(ctx);
                  },
                  child: Text(tr('जतन करा', 'Save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditServicePricingDialog(
    BuildContext context,
    AppState appState,
    WashingMachineSpecializationService srv,
    bool isMr,
  ) {
    final basePriceCtrl =
        TextEditingController(text: srv.basePrice.toStringAsFixed(0));
    final feeCtrl =
        TextEditingController(text: srv.inspectionFee.toStringAsFixed(0));
    final warrantyCtrl =
        TextEditingController(text: srv.warrantyDays.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            '${tr("दर निश्चित करा:", "Configure Rates:")} ${srv.titleEn}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: basePriceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: tr('दुरुस्ती बेस चार्ज (₹)', 'Base Repair Charge (₹)'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feeCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: tr('घरी येऊन तपासणी फी (₹)', 'Doorstep Inspection Fee (₹)'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: warrantyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: tr('वॉरंटी कालावधी (दिवस)', 'Warranty Period (Days)'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('रद्द करा', 'Cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final basePrice =
                    double.tryParse(basePriceCtrl.text.trim()) ?? srv.basePrice;
                final fee = double.tryParse(feeCtrl.text.trim()) ?? srv.inspectionFee;
                final warranty =
                    int.tryParse(warrantyCtrl.text.trim()) ?? srv.warrantyDays;

                final updated = srv.copyWith(
                  basePrice: basePrice,
                  inspectionFee: fee,
                  warrantyDays: warranty,
                );

                appState.updateWmService(updated);
                Navigator.pop(ctx);
              },
              child: Text(tr('जतन करा', 'Save Changes')),
            ),
          ],
        );
      },
    );
  }

  void _showAddOrEditPartDialog(
    BuildContext context,
    AppState appState,
    WashingMachinePart? part,
    bool isMr,
  ) {
    final nameEnCtrl = TextEditingController(text: part?.nameEn ?? '');
    final nameMrCtrl = TextEditingController(text: part?.nameMr ?? '');
    final minPriceCtrl = TextEditingController(
      text: part != null ? part.estimatedMinPrice.toStringAsFixed(0) : '400',
    );
    final maxPriceCtrl = TextEditingController(
      text: part != null ? part.estimatedMaxPrice.toStringAsFixed(0) : '2000',
    );
    final selectedTypes = Set<String>.from(
      part?.applicableMachineTypes ?? MachineTypeConstants.all,
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              title: Text(
                part == null
                    ? tr('नवीन पार्ट / समस्या जोडा', 'Add Part / Symptom')
                    : tr('पार्ट माहिती संपादित करा', 'Edit Part: ${part.nameEn}'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameEnCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Part Name (English)',
                        hintText: 'e.g. Drain Pump, Inverter PCB',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameMrCtrl,
                      decoration: const InputDecoration(
                        labelText: 'पार्टचे नाव (मराठी)',
                        hintText: 'उदा. ड्रेन मोटर, इन्व्हर्टर बोर्ड',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minPriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Min Price (₹)'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: maxPriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Max Price (₹)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...MachineTypeConstants.all.map((type) {
                      final isChecked = selectedTypes.contains(type);
                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(type, style: const TextStyle(fontSize: 12)),
                        value: isChecked,
                        onChanged: (val) {
                          setDlgState(() {
                            if (val == true) {
                              selectedTypes.add(type);
                            } else {
                              selectedTypes.remove(type);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(tr('रद्द करा', 'Cancel')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final nameEn = nameEnCtrl.text.trim();
                    final nameMr = nameMrCtrl.text.trim();
                    final minP = double.tryParse(minPriceCtrl.text.trim()) ?? 400.0;
                    final maxP = double.tryParse(maxPriceCtrl.text.trim()) ?? 2000.0;
                    if (nameEn.isEmpty) return;

                    final updated = WashingMachinePart(
                      id: part?.id ??
                          'part_${nameEn.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
                      nameEn: nameEn,
                      nameMr: nameMr.isNotEmpty ? nameMr : nameEn,
                      estimatedMinPrice: minP,
                      estimatedMaxPrice: maxP,
                      applicableServices: part?.applicableServices ??
                          ['wm_spec_pcb', 'wm_spec_inverter', 'wm_spec_frontload'],
                      applicableMachineTypes: selectedTypes.toList(),
                      isActive: part?.isActive ?? true,
                    );

                    appState.updateWmPart(updated);
                    Navigator.pop(ctx);
                  },
                  child: Text(tr('जतन करा', 'Save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCoverageCitiesDialog(
    BuildContext context,
    AppState appState,
    WashingMachineSpecializationConfig config,
    bool isMr,
  ) {
    final cityCtrl = TextEditingController();
    final cities = List<String>.from(config.serviceCoverageCities);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              title: Text(
                tr('सेवा कव्हरेज शहरे व्यवस्थापित करा', 'Manage Coverage Cities'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityCtrl,
                          decoration: InputDecoration(
                            hintText: tr('नवीन शहर जोडा...', 'Add new city...'),
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_rounded,
                            color: AppColors.primary),
                        onPressed: () {
                          final c = cityCtrl.text.trim();
                          if (c.isNotEmpty && !cities.contains(c)) {
                            setDlgState(() {
                              cities.add(c);
                              cityCtrl.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: cities.map((city) {
                      return Chip(
                        label: Text(city, style: const TextStyle(fontSize: 11)),
                        onDeleted: () {
                          setDlgState(() {
                            cities.remove(city);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(tr('रद्द करा', 'Cancel')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    appState.updateWmCoverageCities(cities);
                    Navigator.pop(ctx);
                  },
                  child: Text(tr('जतन करा', 'Save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAssignPartnerDialog(
    BuildContext context,
    AppState appState,
    Booking booking,
    bool isMr,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            tr('तंत्रज्ञ / पार्टनर नियुक्त करा', 'Assign Technician to #${booking.id}'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: appState.technicians.length,
              itemBuilder: (context, idx) {
                final tech = appState.technicians[idx];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      tech.name.isNotEmpty ? tech.name[0] : 'T',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  title: Text(tech.name, style: const TextStyle(fontSize: 13.5)),
                  subtitle: Text(
                    '${tech.phone} • Rating ${tech.rating}⭐',
                    style: const TextStyle(fontSize: 11),
                  ),
                  onTap: () {
                    appState.assignBookingManually(
                      bookingId: booking.id,
                      technicianId: tech.id,
                    );
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('बंद करा', 'Close')),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateStatusDialog(
    BuildContext context,
    AppState appState,
    Booking booking,
    bool isMr,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(
            tr('बुकिंग स्टेटस बदला', 'Update Status for #${booking.id}'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          children: BookingStatus.values.map((status) {
            final isCurrent = booking.status == status;
            return SimpleDialogOption(
              onPressed: () {
                appState.updateBookingStatus(booking.id, status);
                Navigator.pop(ctx);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isCurrent
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isCurrent ? AppColors.primary : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      status.localizedName(isMr),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
