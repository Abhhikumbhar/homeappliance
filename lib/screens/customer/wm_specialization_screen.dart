import 'package:flutter/material.dart';

import '../../models/appliance_service.dart';
import '../../state/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import '../../widgets/design_components.dart';
import 'booking_checkout_screen.dart';

class WashingMachineSpecializationScreen extends StatefulWidget {
  final String? initialServiceId;
  final String? initialBrandId;

  const WashingMachineSpecializationScreen({
    super.key,
    this.initialServiceId,
    this.initialBrandId,
  });

  @override
  State<WashingMachineSpecializationScreen> createState() =>
      _WashingMachineSpecializationScreenState();
}

class _WashingMachineSpecializationScreenState
    extends State<WashingMachineSpecializationScreen> {
  int _currentStep = 0; // 0: Service, 1: Brand, 2: Machine Type, 3: Problem/Part

  String _selectedServiceId = 'wm_spec_pcb';
  String? _selectedBrandId;
  String? _selectedMachineType;
  String? _selectedPartId;
  final TextEditingController _errorDetailsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialServiceId != null &&
        widget.initialServiceId!.isNotEmpty) {
      _selectedServiceId = widget.initialServiceId!;
    }
    if (widget.initialBrandId != null && widget.initialBrandId!.isNotEmpty) {
      _selectedBrandId = widget.initialBrandId;
    }
  }

  @override
  void dispose() {
    _errorDetailsController.dispose();
    super.dispose();
  }

  WashingMachineSpecializationService _getCurrentService(
      WashingMachineSpecializationConfig config) {
    return config.services.firstWhere(
      (s) => s.id == _selectedServiceId,
      orElse: () => config.services.first,
    );
  }

  WashingMachineBrand? _getCurrentBrand(
      WashingMachineSpecializationConfig config) {
    if (_selectedBrandId == null) return null;
    return config.brands.where((b) => b.id == _selectedBrandId).firstOrNull;
  }

  WashingMachinePart? _getCurrentPart(
      WashingMachineSpecializationConfig config) {
    if (_selectedPartId == null) return null;
    return config.parts.where((p) => p.id == _selectedPartId).firstOrNull;
  }

  /// Automatically adjusts machine type if current selection is invalid for new service
  void _onServiceSelected(String serviceId, WashingMachineSpecializationConfig config) {
    setState(() {
      _selectedServiceId = serviceId;
      final srv = config.services.firstWhere((s) => s.id == serviceId);
      if (_selectedMachineType != null &&
          !srv.compatibleMachineTypes.contains(_selectedMachineType)) {
        _selectedMachineType = srv.compatibleMachineTypes.firstOrNull;
      }
      _selectedPartId = null;
    });
  }

  void _onMachineTypeSelected(String type) {
    setState(() {
      _selectedMachineType = type;
      _selectedPartId = null;
    });
  }

  List<WashingMachinePart> _getFilteredParts(
      WashingMachineSpecializationConfig config) {
    final srv = _getCurrentService(config);
    final mType = _selectedMachineType ?? MachineTypeConstants.frontLoad;

    return config.activeParts.where((part) {
      // 1. Must match service compatibility
      final matchesService = part.applicableServices.contains(srv.id);
      // 2. Must match machine type compatibility
      final matchesType = part.applicableMachineTypes.contains(mType);
      return matchesService && matchesType;
    }).toList();
  }

  void _goToNextStep(WashingMachineSpecializationConfig config, bool isMr) {
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_selectedBrandId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isMr
                  ? 'कृपया वॉशिंग मशीनचा ब्रँड निवडा.'
                  : 'Please select your washing machine brand.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      // Auto-set machine type if service is front-load only
      final srv = _getCurrentService(config);
      if (srv.compatibleMachineTypes.length == 1) {
        _selectedMachineType = srv.compatibleMachineTypes.first;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_selectedMachineType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isMr
                  ? 'कृपया मशीनचा प्रकार निवडा (Front / Top Load).'
                  : 'Please select machine type (Front / Top Load).',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      if (_selectedPartId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isMr
                  ? 'कृपया समस्या किंवा पार्ट निवडा.'
                  : 'Please select the issue or required part.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      _proceedToBookingCheckout(config);
    }
  }

  void _proceedToBookingCheckout(WashingMachineSpecializationConfig config) {
    final appState = AppStateScope.of(context);
    final isMr = appState.isMarathi;
    final srv = _getCurrentService(config);
    final brand = _getCurrentBrand(config);
    final part = _getCurrentPart(config);

    // Look for matching existing ServicePackage or build a high-fidelity specialization package
    ServicePackage targetService = appState.services.firstWhere(
      (s) => s.id == srv.id,
      orElse: () => ServicePackage(
        id: srv.id,
        category: ServiceCategory.washingMachine,
        titleEn: srv.titleEn,
        titleMr: srv.titleMr,
        descriptionEn: srv.descriptionEn,
        descriptionMr: srv.descriptionMr,
        basePrice: srv.basePrice,
        originalPrice: srv.basePrice + 400,
        durationMinutes: 60,
        warrantyDays: srv.warrantyDays,
        inclusions: [
          'Certified doorstep technician inspection',
          'Component level diagnostics with calibrated equipment',
          '${srv.warrantyDays}-Day specialization guarantee shield',
        ],
        exclusions: ['Spare parts cost beyond diagnostic scope'],
      ),
    );

    final errorText = _errorDetailsController.text.trim();
    final problemName = part?.localizedName(isMr) ??
        tr('तपासणी आवश्यक', 'Diagnostic Required');
    final problemDetail = errorText.isNotEmpty
        ? '$problemName ($errorText)'
        : problemName;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingCheckoutScreen(
          service: targetService,
          selectedBrand: brand?.name ?? 'Samsung',
          machineType: _selectedMachineType ?? MachineTypeConstants.frontLoad,
          problem: problemDetail,
          selectedPart: part?.nameEn,
          isSpecialization: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isMr = appState.isMarathi;
    final config = appState.wmSpecializationConfig;

    if (!config.isServiceAvailable) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            tr('वॉशिंग मशीन स्पेशालिस्ट्स', 'Washing Machine Specialists'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: EmptyStateWidget(
              icon: Icons.pause_circle_outline_rounded,
              title: tr('सेवा तात्पुरती अनुपलब्ध', 'Service Temporarily Paused'),
              description: tr(
                'वॉशिंग मशीन स्पेशलिस्ट सेवा सध्या अपडेट होत आहे. कृपया थोड्या वेळाने प्रयत्न करा किंवा सामान्य सर्व्हिस बुक करा.',
                'Washing machine specialization is temporarily paused by operations. Please try again soon.',
              ),
              actionLabel: tr('होम स्क्रीनवर जा', 'Return to Home'),
              onAction: () => Navigator.pop(context),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr('वॉशिंग मशीन स्पेशालिस्ट्स', 'Washing Machine Specialists'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              tr(
                'तज्ज्ञ पीसीबी, इन्व्हर्टर व फ्रंट लोड केअर',
                'Expert PCB, Inverter & Front Load Repair',
              ),
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB800),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded,
                      size: 13, color: Colors.black87),
                  const SizedBox(width: 4),
                  Text(
                    tr('९० दिवस वॉरंटी', '90D Shield'),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper indicator
            _buildStepIndicator(isMr),

            // Content area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == 0) ...[
                      _buildStep1SelectService(config, isMr),
                    ] else if (_currentStep == 1) ...[
                      _buildStep2SelectBrand(config, isMr),
                    ] else if (_currentStep == 2) ...[
                      _buildStep3SelectMachineType(config, isMr),
                    ] else if (_currentStep == 3) ...[
                      _buildStep4SelectProblem(config, isMr),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Navigation action bar
            _buildBottomActionBar(config, isMr),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // STEP INDICATOR HEADER
  // ========================================================
  Widget _buildStepIndicator(bool isMr) {
    final steps = [
      tr('सेवा निवडा', 'Service'),
      tr('ब्रँड', 'Brand'),
      tr('मशीन प्रकार', 'Type'),
      tr('समस्या / पार्ट', 'Problem'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (index) {
              final isPassed = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: isPassed
                                      ? AppColors.success
                                      : (isCurrent
                                          ? AppColors.primary
                                          : Colors.grey.shade300),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: isPassed
                                      ? const Icon(Icons.check,
                                          size: 13, color: Colors.white)
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isCurrent
                                                ? Colors.white
                                                : Colors.black54,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            steps[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCurrent
                                  ? AppColors.primary
                                  : (isPassed
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < steps.length - 1)
                      Container(
                        width: 14,
                        height: 2,
                        color: isPassed ? AppColors.success : Colors.grey.shade300,
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
  // STEP 1: SELECT SPECIALIZATION SERVICE
  // ========================================================
  Widget _buildStep1SelectService(
      WashingMachineSpecializationConfig config, bool isMr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00358E), Color(0xFF0047BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.precision_manufacturing_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('१००% लॅब टेस्टेड पीसीबी व इन्व्हर्टर दुरुस्ती',
                          '100% Lab Tested PCB & Inverter Care'),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tr(
                        'ओरिजिनल पार्ट्स • मायक्रो कंपोनंट सोल्डरिंग • ९० दिवस गॅरंटी',
                        'Original Spares • Micro Soldering • 90-Day Guarantee',
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          tr('स्पेशलायझेशन सेवा निवडा', 'Select Specialization Service'),
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tr(
            'तुमच्या वॉशिंग मशीनच्या गरजेनुसार तज्ज्ञ सेवा निवडा:',
            'Select the dedicated specialization for your machine:',
          ),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        ...config.activeServices.map((service) {
          final isSelected = service.id == _selectedServiceId;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _onServiceSelected(service.id, config),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            service.icon,
                            color: isSelected
                                ? AppColors.primary
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
                                  Expanded(
                                    child: Text(
                                      service.localizedTitle(isMr),
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                  Radio<String>(
                                    value: service.id,
                                    groupValue: _selectedServiceId,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) {
                                      if (val != null) {
                                        _onServiceSelected(val, config);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  service.localizedBadge(isMr),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6D28D9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      service.localizedDescription(isMr),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined,
                                size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              '${service.warrantyDays} ${tr("दिवस गॅरंटी", "Days Warranty")}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${tr("तपासणी फी:", "Inspection:")} ${AppHelpers.formatCurrency(service.inspectionFee)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ========================================================
  // STEP 2: SELECT WASHING MACHINE BRAND
  // ========================================================
  Widget _buildStep2SelectBrand(
      WashingMachineSpecializationConfig config, bool isMr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('वॉशिंग मशीनचा ब्रँड निवडा', 'Select Washing Machine Brand'),
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tr(
            'आम्ही सर्व प्रमुख ब्रँड्सचे ऑथराइज्ड दर्जाचे स्पेअर पार्ट्स वापरतो:',
            'We support original components and testing for all major makes:',
          ),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Brand Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
          ),
          itemCount: config.activeBrands.length,
          itemBuilder: (context, index) {
            final brand = config.activeBrands[index];
            final isSelected = brand.id == _selectedBrandId;

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() => _selectedBrandId = brand.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: brand.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            brand.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${tr("तपासणी फी", "Inspection Fee")} ${AppHelpers.formatCurrency(brand.inspectionFee)}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tr(
                    'सर्व ओरिजिनल पीसीबी सर्किट्सवर ९० दिवसांची लिखित गॅरंटी दिली जाते.',
                    'All genuine PCB repairs carry a 90-day written warranty shield.',
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========================================================
  // STEP 3: SELECT MACHINE TYPE
  // ========================================================
  Widget _buildStep3SelectMachineType(
      WashingMachineSpecializationConfig config, bool isMr) {
    final srv = _getCurrentService(config);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('मशीनचा प्रकार निवडा', 'Select Machine Type'),
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tr(
            'निवडलेल्या सेवेनुसार सुसंगत मशीन प्रकार खालीलप्रमाणे आहेत:',
            'Compatible machine types based on selected specialization:',
          ),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        ...MachineTypeConstants.all.map((type) {
          final isCompatible = srv.compatibleMachineTypes.contains(type);
          final isSelected = _selectedMachineType == type;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isCompatible ? Colors.white : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isCompatible ? AppColors.border : Colors.grey.shade300),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isCompatible
                  ? [
                      BoxShadow(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isCompatible ? () => _onMachineTypeSelected(type) : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCompatible
                            ? (isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.grey.shade100)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        MachineTypeConstants.getIcon(type),
                        color: isCompatible
                            ? (isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary)
                            : Colors.grey.shade400,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                MachineTypeConstants.localizedName(type, isMr),
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: isCompatible
                                      ? (isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary)
                                      : Colors.grey.shade500,
                                ),
                              ),
                              if (type == MachineTypeConstants.frontLoad) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tr('सर्वात लोकप्रिय', 'Popular'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isCompatible
                                ? (type == MachineTypeConstants.frontLoad
                                    ? tr('समोरासमोर ड्रम असलेला स्वयंचलित प्रकार',
                                        'Automatic front door tumbler drum')
                                    : (type == MachineTypeConstants.topLoad
                                        ? tr('वरच्या बाजूने कपडे भरण्याचा प्रकार',
                                            'Top loading automated impeller drum')
                                        : tr('दोन टब असलेले मॅन्युअल/टायमर मॉडेल',
                                            'Twin tub dual timer spinner model')))
                                : (srv.id == 'wm_spec_frontload'
                                    ? tr('ही सेवा केवळ फ्रंट लोडसाठी उपलब्ध आहे',
                                        'Only front load models supported for this service')
                                    : tr('इन्व्हर्टर मोटर सेमी-ऑटोमॅटिकमध्ये नसते',
                                        'Inverter direct drive unavailable in semi-automatic')),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isCompatible
                                  ? AppColors.textSecondary
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCompatible)
                      Radio<String>(
                        value: type,
                        groupValue: _selectedMachineType,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          if (val != null) _onMachineTypeSelected(val);
                        },
                      )
                    else
                      const Icon(Icons.block_rounded,
                          size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ========================================================
  // STEP 4: SELECT PROBLEM / PARTS
  // ========================================================
  Widget _buildStep4SelectProblem(
      WashingMachineSpecializationConfig config, bool isMr) {
    final filteredParts = _getFilteredParts(config);
    final srv = _getCurrentService(config);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('समस्या किंवा आवश्यक पार्ट निवडा', 'Select Problem or Required Part'),
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tr(
            'तुमच्या वॉशिंग मशीनमध्ये नेमकी काय अडचण येत आहे?',
            'What specific issue are you experiencing with your machine?',
          ),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),

        if (filteredParts.isEmpty)
          EmptyStateWidget(
            icon: Icons.search_off_rounded,
            title: tr('कोणतेही पार्ट उपलब्ध नाहीत', 'No Specific Parts Listed'),
            description: tr(
              'कृपया एरर कोड किंवा समस्या खालील बॉक्समध्ये लिहा.',
              'Please describe your machine problem in the notes field below.',
            ),
          )
        else
          ...filteredParts.map((part) {
            final isSelected = part.id == _selectedPartId;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  setState(() => _selectedPartId = part.id);
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          part.icon,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              part.localizedName(isMr),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (part.localizedDescription(isMr).isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                part.localizedDescription(isMr),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              '${tr("अंदाजे पार्ट खर्च:", "Est. Part Range:")} ${AppHelpers.formatCurrency(part.estimatedMinPrice)} - ${AppHelpers.formatCurrency(part.estimatedMaxPrice)}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Radio<String>(
                        value: part.id,
                        groupValue: _selectedPartId,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedPartId = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

        const SizedBox(height: 16),
        Text(
          tr('एरर कोड किंवा इतर लक्षणे (ऐच्छिक)',
              'Error Code or Specific Symptoms (Optional)'),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _errorDetailsController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: tr(
              'उदा. 4E / dE एरर कोड येतोय, स्पिन करताना मोठा आवाज होतोय...',
              'e.g. 4E error code, loud vibration in spin mode, water leakage...',
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),

        const SizedBox(height: 16),
        // Diagnostic pricing clarity card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('घरी येऊन तपासणी फी (Doorstep Diagnostic):',
                        'Doorstep Inspection Fee:'),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    AppHelpers.formatCurrency(srv.inspectionFee),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('स्पेशालिस्ट दुरुस्ती गॅरंटी:', 'Specialist Warranty:'),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    '${srv.warrantyDays} ${tr("दिवस", "Days")}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========================================================
  // BOTTOM ACTION BAR
  // ========================================================
  Widget _buildBottomActionBar(
      WashingMachineSpecializationConfig config, bool isMr) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppColors.border),
              ),
              onPressed: () {
                setState(() => _currentStep--);
              },
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.textPrimary, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: Icon(
                _currentStep == 3
                    ? Icons.calendar_today_rounded
                    : Icons.arrow_forward_rounded,
                size: 18,
              ),
              label: Text(
                _currentStep == 3
                    ? tr('तारीख व पत्ता निवडा ›', 'Proceed to Schedule & Address ›')
                    : tr('पुढील पायरी ›', 'Continue Next Step ›'),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => _goToNextStep(config, isMr),
            ),
          ),
        ],
      ),
    );
  }
}
