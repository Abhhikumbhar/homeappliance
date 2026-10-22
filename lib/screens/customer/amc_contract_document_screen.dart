import 'package:flutter/material.dart';
import '../../models/amc_renewal.dart';
import '../../state/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';

class AmcContractDocumentScreen extends StatefulWidget {
  final AmcRenewal? renewal;

  const AmcContractDocumentScreen({
    super.key,
    this.renewal,
  });

  @override
  State<AmcContractDocumentScreen> createState() =>
      _AmcContractDocumentScreenState();
}

class _AmcContractDocumentScreenState extends State<AmcContractDocumentScreen> {
  int _selectedPageIndex = 0; // 0: Page 1, 1: Page 2, 2: Continuous (Both)
  bool _isMarathi = true;
  bool _isLanguageInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLanguageInitialized) {
      final appState = AppStateScope.of(context);
      _isMarathi = appState.isMarathi;
      _isLanguageInitialized = true;
    }
  }

  // Helper to extract language-specific text from bilingual formats like "मराठी (English)"
  String _cleanText(String text) {
    if (text.isEmpty) return text;
    final trimmed = text.trim();
    final match = RegExp(r'^([^\(\)]+)\s*\((.+)\)$').firstMatch(trimmed);
    if (match != null) {
      final part1 = match.group(1)!.trim();
      final part2 = match.group(2)!.trim();
      final part1HasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(part1);
      final part2HasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(part2);
      if (part1HasDevanagari && !part2HasDevanagari) {
        return _isMarathi ? part1 : part2;
      } else if (!part1HasDevanagari && part2HasDevanagari) {
        return _isMarathi ? part2 : part1;
      }
    }
    return trimmed;
  }

  String _translateAppliance(String name) {
    final clean = _cleanText(name);
    final lower = clean.toLowerCase();
    if (_isMarathi) {
      if (lower.contains('split ac') || lower.contains('ac')) return 'स्प्लिट एसी';
      if (lower.contains('purifier') || lower.contains('ro')) return 'वॉटर प्युरिफायर (RO)';
      if (lower.contains('washing')) return 'वॉशिंग मशीन';
      if (lower.contains('fridge') || lower.contains('refrigerator')) return 'रेफ्रिजरेटर';
      if (lower.contains('microwave') || lower.contains('oven')) return 'मायक्रोव्हेव्ह ओव्हन';
      if (lower.contains('chimney')) return 'किचन चिमणी';
      if (lower.contains('geyser')) return 'गिझर';
      return clean;
    } else {
      if (clean.contains('स्प्लिट एसी') || clean.contains('एसी')) return 'Split AC';
      if (clean.contains('वॉटर प्युरिफायर') || clean.contains('प्युरिफायर')) return 'Water Purifier (RO)';
      if (clean.contains('वॉशिंग मशीन')) return 'Washing Machine';
      if (clean.contains('रेफ्रिजरेटर') || clean.contains('फ्रिज')) return 'Refrigerator';
      if (clean.contains('मायक्रोव्हेव्ह')) return 'Microwave Oven';
      if (clean.contains('चिमणी')) return 'Kitchen Chimney';
      if (clean.contains('गिझर')) return 'Geyser';
      return clean;
    }
  }

  String _translateLocation(String loc) {
    final clean = _cleanText(loc);
    final lower = clean.toLowerCase();
    if (_isMarathi) {
      if (lower.contains('bed') || lower.contains('master')) return 'मास्टर बेडरूम';
      if (lower.contains('kitchen')) return 'किचन';
      if (lower.contains('utility') || lower.contains('balcony')) return 'युटिलिटी एरिया';
      if (lower.contains('hall') || lower.contains('living')) return 'हॉल / दिवाणखाना';
      return clean;
    } else {
      if (clean.contains('मास्टर') || clean.contains('बेड')) return 'Master Bedroom';
      if (clean.contains('किचन')) return 'Kitchen';
      if (clean.contains('युटिलिटी') || clean.contains('बाल्कनी')) return 'Utility Area';
      if (clean.contains('हॉल') || clean.contains('दिवाणखाना')) return 'Living Room';
      return clean;
    }
  }

  String _formatDate(DateTime d) {
    if (!_isMarathi) {
      return AppHelpers.formatDate(d);
    }
    const monthsMr = [
      'जानेवारी', 'फेब्रुवारी', 'मार्च', 'एप्रिल', 'मे', 'जून',
      'जुलै', 'ऑगस्ट', 'सप्टेंबर', 'ऑक्टोबर', 'नोव्हेंबर', 'डिसेंबर'
    ];
    final day = d.day.toString().padLeft(2, '0');
    final month = monthsMr[d.month - 1];
    final year = d.year.toString();
    return '$day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final user = appState.currentUser;

    final contractNo = widget.renewal?.contractNo?.isNotEmpty == true
        ? widget.renewal!.contractNo!
        : (widget.renewal != null
            ? 'AMC-YM-${widget.renewal!.id.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0')}'
            : 'AMC-YM-2026-0842');

    final rawCustName = widget.renewal?.customerName ??
        (user != null && user.name.isNotEmpty
            ? user.name
            : (_isMarathi ? 'सचिन पाटील' : 'Sachin Patil'));
    final custName = _cleanText(rawCustName);

    final custPhone = widget.renewal?.customerPhone ??
        (user != null && user.phone.isNotEmpty
            ? user.phone
            : '+91 98221 45678');

    final rawAddress = widget.renewal?.address.trim() ?? '';
    final String custAddress;
    if (rawAddress.isEmpty ||
        rawAddress.contains('साई रेसिडेन्सी') ||
        rawAddress.contains('Sai Residency')) {
      custAddress = _isMarathi
          ? 'फ्लॅट क्र. ३०२, साई रेसिडेन्सी, विश्रामबाग, सांगली - ४१६४१५'
          : 'Flat #302, Sai Residency, Vishrambag, Sangli - 416415';
    } else {
      custAddress = rawAddress;
    }

    final rawPlanName = widget.renewal?.planName ?? '';
    final planName = rawPlanName.isNotEmpty
        ? _cleanText(rawPlanName)
        : (_isMarathi ? 'कम्प्रिहेन्सिव्ह शिल्ड प्लॅन' : 'Comprehensive Shield Plan');

    final planPrice = widget.renewal?.planPrice ?? 4498.0;
    final gstPrice = (planPrice * 0.18).roundToDouble();
    final totalPrice = planPrice + gstPrice;

    final startDate = widget.renewal?.lastServiceDate ?? DateTime.now();
    final endDate = widget.renewal?.nextDueDate ??
        DateTime.now().add(const Duration(days: 365));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          _isMarathi ? 'वार्षिक करार (AMC)' : 'AMC Agreement',
          style: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          // Segmented Language Switcher (Clear Visual Indicator)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageChip(
                  label: 'मराठी',
                  isActive: _isMarathi,
                  onTap: () {
                    if (!_isMarathi) {
                      setState(() => _isMarathi = true);
                      appState.setLanguage(true);
                    }
                  },
                ),
                _buildLanguageChip(
                  label: 'English',
                  isActive: !_isMarathi,
                  onTap: () {
                    if (_isMarathi) {
                      setState(() => _isMarathi = false);
                      appState.setLanguage(false);
                    }
                  },
                ),
              ],
            ),
          ),
          // Share Button
          IconButton(
            icon: const Icon(Icons.share_rounded, size: 20),
            color: const Color(0xFF003B99),
            tooltip: _isMarathi ? 'शेअर करा' : 'Share Contract',
            onPressed: () => _shareContract(context, contractNo),
          ),
          // Download / Print Button
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 21),
            color: const Color(0xFF003B99),
            tooltip: _isMarathi ? 'PDF डाऊनलोड' : 'Download PDF',
            onPressed: () => _downloadContract(context, contractNo),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildTabButton(
                    0,
                    _isMarathi ? '📄 पृष्ठ १' : '📄 Page 1',
                  ),
                  _buildTabButton(
                    1,
                    _isMarathi ? '📄 पृष्ठ २' : '📄 Page 2',
                  ),
                  _buildTabButton(
                    2,
                    _isMarathi ? '📑 संपूर्ण करार' : '📑 All Pages',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              children: [
                if (_selectedPageIndex == 0 || _selectedPageIndex == 2) ...[
                  _buildPaperPage(
                    child: _buildPage1Content(
                      contractNo: contractNo,
                      custName: custName,
                      custPhone: custPhone,
                      custAddress: custAddress,
                      startDate: startDate,
                      endDate: endDate,
                      planName: planName,
                    ),
                  ),
                ],
                if (_selectedPageIndex == 2) const SizedBox(height: 24),
                if (_selectedPageIndex == 1 || _selectedPageIndex == 2) ...[
                  _buildPaperPage(
                    child: _buildPage2Content(
                      contractNo: contractNo,
                      custName: custName,
                      startDate: startDate,
                      planPrice: planPrice,
                      gstPrice: gstPrice,
                      totalPrice: totalPrice,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _buildActionFloatingBar(context, contractNo),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF003B99) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF003B99).withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _selectedPageIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPageIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF003B99) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF003B99).withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaperPage({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: child,
    );
  }

  // ==========================================
  // PAGE 1 CONTENT
  // ==========================================
  Widget _buildPage1Content({
    required String contractNo,
    required String custName,
    required String custPhone,
    required String custAddress,
    required DateTime startDate,
    required DateTime endDate,
    required String planName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Header with Young Master Logo & Company Details
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF003B99), width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF003B99).withValues(alpha: 0.15),
                    blurRadius: 6,
                  )
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/young_master_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF003B99),
                    child: const Icon(
                      Icons.home_repair_service_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUNG MASTER',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF003B99),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    _isMarathi
                        ? 'होम अप्लायन्सेस केअर & सर्व्हिसेस'
                        : 'HOME APPLIANCE CARE & SERVICES',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE65100),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _isMarathi
                        ? '📞 +91 98220 00000 | ✉ support@youngmaster.in | सांगली - मिरज - कुपवाड, महाराष्ट्र'
                        : '📞 +91 98220 00000 | ✉ support@youngmaster.in | Sangli - Miraj - Kupwad, MH',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Container(
          height: 2.5,
          color: const Color(0xFF003B99),
        ),
        const SizedBox(height: 10),

        // Title Bar
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF003B99),
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                _isMarathi
                    ? 'वार्षिक देखभाल करार (AMC)'
                    : 'ANNUAL MAINTENANCE CONTRACT (AMC) AGREEMENT',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                _isMarathi
                    ? 'घरगुती उपकरणांच्या सर्वसमावेशक सेवेसाठी आणि देखभालीसाठी'
                    : 'Comprehensive Protection for Home Appliances & Essential Electronics',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Metadata Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildMetaField(
                label: _isMarathi ? 'करार क्र.:' : 'Contract No:',
                value: contractNo,
                isHighlight: true,
              ),
              _buildMetaField(
                label: _isMarathi ? 'करार तारीख:' : 'Date:',
                value: _formatDate(startDate),
              ),
              _buildMetaField(
                label: _isMarathi ? 'वैधता:' : 'Validity:',
                value: _isMarathi ? '१ वर्ष वैध' : '1 Year Valid',
              ),
              _buildMetaField(
                label: _isMarathi ? 'मुदत समाप्ती:' : 'Valid Till:',
                value: _formatDate(endDate),
                isHighlight: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Section 1: Party Details
        _buildSectionHeader(
          numberMr: '१',
          numberEn: '1',
          titleMr: 'करारातील पक्षकार तपशील',
          titleEn: 'PARTY DETAILS',
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Provider
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF003B99).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _isMarathi ? 'सेवा प्रदाता' : 'SERVICE PROVIDER',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003B99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isMarathi
                          ? 'यंग मास्टर होम अप्लायन्स केअर'
                          : 'Young Master Home Appliance Care',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isMarathi
                          ? 'पत्ता: शॉप क्र. १२, मार्केट यार्ड रोड, सांगली - ४१६४१६\nमोबाईल: +91 98220 00000 | +91 91580 00000\nजीएसटी: 27AABCY8842M1Z5'
                          : 'Address: Shop #12, Market Yard Rd, Sangli - 416416\nPhone: +91 98220 00000 | +91 91580 00000\nGSTIN: 27AABCY8842M1Z5',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Customer Details
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _isMarathi ? 'ग्राहक तपशील' : 'CUSTOMER / CLIENT',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      custName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_isMarathi ? "पत्ता:" : "Address:"} $custAddress\n${_isMarathi ? "मोबाईल:" : "Contact:"} $custPhone\n${_isMarathi ? "ग्राहक आयडी:" : "Client ID:"} YM-CUST-8842',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Section 2: Equipment / Appliance Details
        _buildSectionHeader(
          numberMr: '२',
          numberEn: '2',
          titleMr: 'नोंदणीकृत उपकरणांचा तपशील',
          titleEn: 'EQUIPMENT & APPLIANCE DETAILS',
        ),
        const SizedBox(height: 8),
        _buildApplianceTable(),

        const SizedBox(height: 14),

        // Section 3: Scope of AMC
        _buildSectionHeader(
          numberMr: '३',
          numberEn: '3',
          titleMr: 'कराराची व्याप्ती व मोफत सेवा',
          titleEn: 'SCOPE OF AMC & SERVICES',
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Column(
            children: [
              _buildScopePoint(
                _isMarathi
                    ? 'वर्षातून ३ ते ४ मोफत नियमित प्रतिबंधात्मक सर्व्हिस भेटी'
                    : '3 to 4 scheduled preventive maintenance service visits per year',
              ),
              _buildScopePoint(
                _isMarathi
                    ? 'एअर कंडिशनरसाठी मोफत केमिकल जेट फोम वॉश व डीप कॉइल क्लिनिंग'
                    : 'Free chemical jet foam cleaning and deep coil washing for Air Conditioners',
              ),
              _buildScopePoint(
                _isMarathi
                    ? 'आरओ वॉटर प्युरिफायर फिल्टर, सेडिमेंट व मेम्ब्रेन नियमित मोफत तपासणी'
                    : 'Regular sediment and RO membrane diagnostic inspection',
              ),
              _buildScopePoint(
                _isMarathi
                    ? 'कोणतीही तक्रार नोंदवल्यानंतर २ ते ४ तासांत प्राधान्याने तंत्रज्ञ भेट'
                    : 'Priority 2 to 4 hours emergency breakdown response time',
              ),
              _buildScopePoint(
                _isMarathi
                    ? 'नियमित सर्व्हिस व ब्रेकडाउन व्हिजिटसाठी कोणतेही लेबर चार्जेस नाहीत (मोफत)'
                    : 'Zero labor and visit charges for all routine maintenance and emergency repairs',
              ),
              _buildScopePoint(
                _isMarathi
                    ? 'बदलण्यात येणाऱ्या अस्सल OEM स्पेअर पार्ट्सवर १०% ते १५% विशेष सूट'
                    : 'Exclusive 10% to 15% discount on 100% genuine OEM spare parts',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        _buildPageFooter(pageNumber: 1, totalPages: 2),
      ],
    );
  }

  // ==========================================
  // PAGE 2 CONTENT
  // ==========================================
  Widget _buildPage2Content({
    required String contractNo,
    required String custName,
    required DateTime startDate,
    required double planPrice,
    required double gstPrice,
    required double totalPrice,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mini Page 2 Header
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/young_master_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.home_repair_service_rounded,
                    color: Color(0xFF003B99),
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _isMarathi
                  ? 'यंग मास्टर - एएमसी करारपत्र ($contractNo)'
                  : 'YOUNG MASTER - AMC CONTRACT ($contractNo)',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF003B99),
              ),
            ),
            const Spacer(),
            Text(
              _isMarathi ? 'पृष्ठ २ / २' : 'Page 2 of 2',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(height: 1.5, color: const Color(0xFFCBD5E1)),
        const SizedBox(height: 12),

        // Section 4: AMC Plan & Cost Details
        _buildSectionHeader(
          numberMr: '४',
          numberEn: '4',
          titleMr: 'एएमसी प्लॅन व शुल्क तपशील',
          titleEn: 'AMC PLAN & COST DETAILS',
        ),
        const SizedBox(height: 8),
        _buildPlanCostTable(planPrice, gstPrice, totalPrice),

        const SizedBox(height: 14),

        // Section 5: Terms and Conditions
        _buildSectionHeader(
          numberMr: '५',
          numberEn: '5',
          titleMr: 'नियम व अटी',
          titleEn: 'TERMS AND CONDITIONS',
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTermPoint(
                _isMarathi ? '१' : '1',
                _isMarathi
                    ? 'हा करार ग्राहकाने संपूर्ण रक्कम भरल्यानंतर स्वाक्षरीच्या तारखेपासून १ वर्षासाठी वैध राहील.'
                    : 'This contract is valid for 1 year from the date of agreement upon full payment of the plan fee.',
              ),
              _buildTermPoint(
                _isMarathi ? '२' : '2',
                _isMarathi
                    ? 'नियमित सर्व्हिसिंगचे वेळापत्रक कंपनीकडून आगाऊ कळवले जाईल किंवा ग्राहक ॲपवरून शेड्यूल करू शकतात.'
                    : 'Preventive maintenance visits are scheduled in advance by the company or booked via the mobile app.',
              ),
              _buildTermPoint(
                _isMarathi ? '३' : '3',
                _isMarathi
                    ? 'नैसर्गिक आपत्ती, आग, शॉर्ट सर्किट, अति व्होल्टेज किंवा बाह्य आघातामुळे झालेले नुकसान या करारात समाविष्ट नाही.'
                    : 'Damage due to natural disasters, electrical surges, fire, water accidents, or external physical impact is excluded.',
              ),
              _buildTermPoint(
                _isMarathi ? '४' : '4',
                _isMarathi
                    ? 'बदलण्यात येणारे स्पेअर पार्ट्स हे १००% अस्सल OEM असतील व ग्राहकाच्या मान्यतेने बसवले जातील.'
                    : 'Replacement components will be 100% genuine OEM parts, billed at special discounted AMC rates.',
              ),
              _buildTermPoint(
                _isMarathi ? '५' : '5',
                _isMarathi
                    ? 'इमर्जन्सी ब्रेकडाऊन कॉल सकाळी ९ ते रात्री ८ या वेळेत स्वीकारले जातील आणि २४ तासांच्या आत सोडवले जातील.'
                    : 'Emergency repair breakdown calls are entertained between 9:00 AM to 8:00 PM and resolved within 24 hours.',
              ),
              _buildTermPoint(
                _isMarathi ? '६' : '6',
                _isMarathi
                    ? 'कराराची मुदत संपण्यापूर्वी १५ दिवस अगोदर नूतनीकरणाची सूचना ॲप व एसएमएसद्वारे पाठवली जाईल.'
                    : 'Renewal reminders will be transmitted 15 days prior to expiry via SMS and Mobile App notifications.',
              ),
              _buildTermPoint(
                _isMarathi ? '७' : '7',
                _isMarathi
                    ? 'या करारासंबंधीचे सर्व कायदेशीर वाद सांगली न्यायालयाच्या कार्यक्षेत्राच्या कक्षेत राहतील.'
                    : 'All legal disputes are exclusively subject to Sangli (Maharashtra) judicial jurisdiction.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Section 6: Maintenance Checklist
        _buildSectionHeader(
          numberMr: '६',
          numberEn: '6',
          titleMr: 'तांत्रिक गुणवत्ता तपासणी चेकलिस्ट',
          titleEn: 'TECHNICAL QUALITY CHECKLIST',
        ),
        const SizedBox(height: 8),
        _buildChecklistTable(),

        const SizedBox(height: 16),

        // Section 7: Signatures & Seal
        _buildSectionHeader(
          numberMr: '७',
          numberEn: '7',
          titleMr: 'स्वाक्षरी व अधिकृत शिक्का',
          titleEn: 'SIGNATURES & AUTHORIZATION',
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Customer Signature
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isMarathi ? 'ग्राहकाची स्वाक्षरी' : 'Customer Signature',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Container(
                      height: 1,
                      color: const Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      custName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${_isMarathi ? "तारीख:" : "Date:"} ${_formatDate(startDate)}',
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Provider Stamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Digital circular seal
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF003B99),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        color: const Color(0xFF003B99).withValues(alpha: 0.04),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF003B99),
                            size: 20,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _isMarathi ? 'यंग मास्टर' : 'YOUNG MASTER',
                            style: const TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF003B99),
                              letterSpacing: 0.4,
                            ),
                          ),
                          Text(
                            _isMarathi ? 'प्रमाणित व अधिकृत' : 'VERIFIED & SEALED',
                            style: const TextStyle(
                              fontSize: 6,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                          Text(
                            _isMarathi ? 'सांगली (महा.)' : 'SANGLI (MH)',
                            style: const TextStyle(
                              fontSize: 6,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF003B99),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isMarathi
                          ? 'अधिकृत प्रतिनिधी स्वाक्षरी व शिक्का'
                          : 'Authorized Signatory & Seal',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003B99),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      _isMarathi
                          ? 'यंग मास्टर होम अप्लायन्स केअर'
                          : 'Young Master Home Appliance Care',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Bottom Thank you note
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF003B99).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFF003B99).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.support_agent_rounded,
                color: Color(0xFF003B99),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isMarathi
                      ? 'घरगुती उपकरणांच्या सुरक्षिततेसाठी आणि अखंड सेवेसाठी यंग मास्टरची निवड केल्याबद्दल धन्यवाद! २४x७ हेल्पलाईन: +91 98220 00000'
                      : 'Thank you for choosing Young Master Home Appliance Care! 24x7 Support Helpline: +91 98220 00000',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003B99),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),
        _buildPageFooter(pageNumber: 2, totalPages: 2),
      ],
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildMetaField({
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isHighlight ? const Color(0xFF003B99) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String numberMr,
    required String numberEn,
    required String titleMr,
    required String titleEn,
  }) {
    final number = _isMarathi ? numberMr : numberEn;
    final title = _isMarathi ? titleMr : titleEn;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: const Color(0xFF003B99),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF003B99),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildApplianceTable() {
    final headers = _isMarathi
        ? ['अ.क्र.', 'उपकरण', 'मेक व मॉडेल', 'सिरीयल क्र.', 'संख्या', 'स्थान']
        : ['Sr.', 'Appliance', 'Make & Model', 'Serial No.', 'Qty', 'Location'];

    final dynamicList = widget.renewal?.equipmentList;
    final List<List<String>> rows;
    if (dynamicList != null && dynamicList.isNotEmpty) {
      rows = dynamicList.asMap().entries.map((entry) {
        final idx = _isMarathi
            ? _toMarathiDigits((entry.key + 1).toString())
            : (entry.key + 1).toString();
        final eq = entry.value;
        return [
          idx,
          _translateAppliance(eq.applianceName),
          eq.brandModel.isEmpty ? '-' : eq.brandModel,
          eq.serialNo.isEmpty ? '-' : eq.serialNo,
          _isMarathi ? _toMarathiDigits(eq.quantity.toString()) : eq.quantity.toString(),
          eq.location.isEmpty ? '-' : _translateLocation(eq.location),
        ];
      }).toList();
    } else {
      rows = [
        [
          _isMarathi ? '१' : '1',
          _isMarathi ? 'स्प्लिट एसी (१.५ टन)' : 'Split AC (1.5T)',
          'Daikin Inverter 5★',
          'DK-884210',
          _isMarathi ? '१' : '1',
          _isMarathi ? 'मास्टर बेडरूम' : 'Master Bedroom'
        ],
        [
          _isMarathi ? '२' : '2',
          _isMarathi ? 'वॉटर प्युरिफायर (RO)' : 'Water Purifier (RO)',
          'Kent Grand Plus 8L',
          'KT-RO-9932',
          _isMarathi ? '१' : '1',
          _isMarathi ? 'किचन' : 'Kitchen'
        ],
        [
          _isMarathi ? '३' : '3',
          _isMarathi ? 'वॉशिंग मशीन (फ्रंट लोड)' : 'Washing Machine (FL)',
          'IFB Senator 8 Kg',
          'IF-741280',
          _isMarathi ? '१' : '1',
          _isMarathi ? 'युटिलिटी एरिया' : 'Utility Area'
        ],
        [
          _isMarathi ? '४' : '4',
          _isMarathi ? 'रेफ्रिजरेटर (डबल डोअर)' : 'Refrigerator (FF)',
          'Samsung 253L 3★',
          'SM-510920',
          _isMarathi ? '१' : '1',
          _isMarathi ? 'किचन' : 'Kitchen'
        ],
      ];
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(0.7),
            1: FlexColumnWidth(2.2),
            2: FlexColumnWidth(2.4),
            3: FlexColumnWidth(1.6),
            4: FlexColumnWidth(0.7),
            5: FlexColumnWidth(1.4),
          },
          border: TableBorder.all(
            color: const Color(0xFFCBD5E1),
            width: 0.8,
          ),
          children: [
            // Table Header
            TableRow(
              decoration: const BoxDecoration(
                color: Color(0xFF003B99),
              ),
              children: headers.map((h) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                  child: Text(
                    h,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 9.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
            // Table Rows
            ...rows.map((r) {
              return TableRow(
                decoration: BoxDecoration(
                  color: rows.indexOf(r) % 2 == 0
                      ? Colors.white
                      : const Color(0xFFF8FAFC),
                ),
                children: r.map((cell) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                    child: Text(
                      cell,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCostTable(double planPrice, double gstPrice, double totalPrice) {
    final isCustom = widget.renewal != null;
    final rawPlan = widget.renewal?.planName;
    final planTitle = (rawPlan != null && rawPlan.isNotEmpty)
        ? _cleanText(rawPlan)
        : (_isMarathi ? 'कम्प्रिहेन्सिव्ह शिल्ड प्लॅन' : 'Comprehensive Shield Plan');

    final rawApp = widget.renewal?.applianceName;
    final appTitle = (rawApp != null && rawApp.isNotEmpty)
        ? _translateAppliance(rawApp)
        : (_isMarathi ? 'सर्व नोंदणीकृत उपकरणे' : 'All Covered Appliances');

    final rawFreq = widget.renewal?.frequency;
    final freqTitle = (rawFreq != null && rawFreq.isNotEmpty)
        ? _cleanText(rawFreq)
        : (_isMarathi ? 'त्रैमासिक (दर ३ महिन्यांनी)' : 'Quarterly (Every 3 Mos)');

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(0.8),
            1: FlexColumnWidth(2.5),
            2: FlexColumnWidth(2.2),
            3: FlexColumnWidth(1.2),
            4: FlexColumnWidth(1.8),
            5: FlexColumnWidth(1.5),
          },
          border: TableBorder.all(
            color: const Color(0xFFCBD5E1),
            width: 0.8,
          ),
          children: [
            // Header
            TableRow(
              decoration: const BoxDecoration(
                color: Color(0xFF003B99),
              ),
              children: [
                _buildThCell(_isMarathi ? 'अ.क्र.' : 'Sr.'),
                _buildThCell(_isMarathi ? 'प्लॅन प्रकार' : 'Plan Type'),
                _buildThCell(_isMarathi ? 'उपकरण' : 'Appliance'),
                _buildThCell(_isMarathi ? 'कालावधी' : 'Period'),
                _buildThCell(_isMarathi ? 'वारंवारता' : 'Frequency'),
                _buildThCell(_isMarathi ? 'शुल्क (₹)' : 'Rate (₹)'),
              ],
            ),
            if (isCustom) ...[
              TableRow(
                children: [
                  _buildTdCell(_isMarathi ? '१' : '1'),
                  _buildTdCell(planTitle),
                  _buildTdCell(appTitle),
                  _buildTdCell(_isMarathi ? '१ वर्ष' : '1 Year'),
                  _buildTdCell(freqTitle),
                  _buildTdCell('₹ ${planPrice.toInt()}', isBold: true),
                ],
              ),
            ] else ...[
              // Row 1
              TableRow(
                children: [
                  _buildTdCell(_isMarathi ? '१' : '1'),
                  _buildTdCell(_isMarathi ? 'कम्प्रिहेन्सिव्ह शिल्ड' : 'Comprehensive Shield'),
                  _buildTdCell(_isMarathi ? 'स्प्लिट एसी (१.५ टन)' : 'Split AC 1.5 Ton'),
                  _buildTdCell(_isMarathi ? '१ वर्ष' : '1 Year'),
                  _buildTdCell(_isMarathi ? 'दर ३ महिन्यांनी' : 'Quarterly (3 Mos)'),
                  _buildTdCell('₹ 2,499', isBold: true),
                ],
              ),
              // Row 2
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  _buildTdCell(_isMarathi ? '२' : '2'),
                  _buildTdCell(_isMarathi ? 'प्युअर केअर प्लॅन' : 'Pure Care RO Plan'),
                  _buildTdCell(_isMarathi ? 'केंट आरओ ८ लिटर' : 'Kent RO UV 8L'),
                  _buildTdCell(_isMarathi ? '१ वर्ष' : '1 Year'),
                  _buildTdCell(_isMarathi ? 'दर ४ महिन्यांनी' : 'Every 4 Months'),
                  _buildTdCell('₹ 1,999', isBold: true),
                ],
              ),
            ],
            // Totals Row
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFEFF6FF)),
              children: [
                const SizedBox(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Text(
                    _isMarathi
                        ? 'रक्कम: ₹ ${planPrice.toInt()} + जीएसटी (१८%): ₹ ${gstPrice.toInt()}'
                        : 'Subtotal: ₹ ${planPrice.toInt()} + GST (18%): ₹ ${gstPrice.toInt()}',
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003B99),
                    ),
                  ),
                ),
                const SizedBox(),
                const SizedBox(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Text(
                    _isMarathi ? 'एकूण देय:' : 'Total Net:',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF003B99),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Text(
                    '₹ ${totalPrice.toInt()}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF003B99),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistTable() {
    final dynamicChecklist = widget.renewal?.checklist;
    final List<List<String>> rows;
    if (dynamicChecklist != null && dynamicChecklist.isNotEmpty) {
      rows = dynamicChecklist.asMap().entries.map((entry) {
        final idx = _isMarathi
            ? _toMarathiDigits((entry.key + 1).toString())
            : (entry.key + 1).toString();
        final item = entry.value;
        return [
          idx,
          _cleanText(item.checkPoint),
          _cleanText(item.status),
          item.remarks.isEmpty ? '-' : _cleanText(item.remarks),
        ];
      }).toList();
    } else {
      rows = [
        [
          _isMarathi ? '१' : '1',
          _isMarathi
              ? 'कुलिंग कॉइल व एअर फिल्टर स्वच्छता'
              : 'AC Cooling Coil & Air Filter Jet Cleaning',
          _isMarathi ? 'पूर्ण' : 'Done',
          _isMarathi ? 'जेट वॉशने स्वच्छ केले' : 'Thoroughly jet washed'
        ],
        [
          _isMarathi ? '२' : '2',
          _isMarathi
              ? 'कॉम्प्रेसर ॲम्पियर व व्होल्टेज टेस्ट'
              : 'Compressor Amperage & Voltage Test',
          _isMarathi ? 'योग्य' : 'OK',
          _isMarathi ? '५.८A (योग्य लोड)' : '5.8A within normal range'
        ],
        [
          _isMarathi ? '३' : '3',
          _isMarathi
              ? 'गॅस प्रेशर व लीकेज तपासणी'
              : 'Refrigerant Gas Pressure & Leak Check',
          _isMarathi ? 'योग्य' : 'OK',
          _isMarathi ? '१३५ PSI (गळती नाही)' : '135 PSI, Zero leakage'
        ],
        [
          _isMarathi ? '४' : '4',
          _isMarathi
              ? 'आरओ टीडीएस पातळी व पाणी गळती टेस्ट'
              : 'RO TDS Output & Water Leakage Test',
          _isMarathi ? 'योग्य' : 'OK',
          _isMarathi ? 'इन: ७४० / आऊट: ७५ TDS' : 'Input: 740 / Output: 75 TDS'
        ],
        [
          _isMarathi ? '५' : '5',
          _isMarathi
              ? 'ड्रेन पाईप स्वच्छता व फ्लो टेस्ट'
              : 'Drain Pipe Flushing & Flow Check',
          _isMarathi ? 'पूर्ण' : 'Done',
          _isMarathi ? 'ब्लॉकेज नाही, सुरळीत प्रवाह' : 'Clear flow, no blockage'
        ],
        [
          _isMarathi ? '६' : '6',
          _isMarathi
              ? 'अर्थिंग, वायरिंग व सुरक्षितता तपासणी'
              : 'Earthing & Electrical Safety Check',
          _isMarathi ? 'सुरक्षित' : 'Safe',
          _isMarathi ? 'अर्थिंग व्होल्टेज योग्य' : 'Proper earthing voltage verified'
        ],
      ];
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(0.7),
            1: FlexColumnWidth(4.0),
            2: FlexColumnWidth(1.6),
            3: FlexColumnWidth(2.7),
          },
          border: TableBorder.all(
            color: const Color(0xFFCBD5E1),
            width: 0.8,
          ),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFF003B99)),
              children: [
                _buildThCell(_isMarathi ? 'अ.क्र.' : 'Sr.'),
                _buildThCell(_isMarathi ? 'तपासणी तपशील' : 'Inspection Check Point'),
                _buildThCell(_isMarathi ? 'स्थिती' : 'Status'),
                _buildThCell(_isMarathi ? 'तंत्रज्ञ शेरा' : 'Technician Remarks'),
              ],
            ),
            ...rows.map((r) {
              return TableRow(
                decoration: BoxDecoration(
                  color: rows.indexOf(r) % 2 == 0
                      ? Colors.white
                      : const Color(0xFFF8FAFC),
                ),
                children: [
                  _buildTdCell(r[0]),
                  _buildTdCell(r[1], alignLeft: true),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF16A34A),
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          r[2],
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildTdCell(r[3], alignLeft: true),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildThCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 9.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTdCell(
    String text, {
    bool isBold = false,
    bool alignLeft = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.5,
          color: const Color(0xFF1E293B),
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
        ),
        textAlign: alignLeft ? TextAlign.left : TextAlign.center,
      ),
    );
  }

  Widget _buildScopePoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF16A34A),
            size: 15,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermPoint(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003B99),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 9.5,
                color: Color(0xFF334155),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageFooter({required int pageNumber, required int totalPages}) {
    final pageNumStr = _isMarathi ? _toMarathiDigits('$pageNumber') : '$pageNumber';
    final totalPageStr = _isMarathi ? _toMarathiDigits('$totalPages') : '$totalPages';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _isMarathi
              ? 'यंग मास्टर होम अप्लायन्स केअर • www.youngmaster.in'
              : 'Young Master Home Appliance Care • www.youngmaster.in',
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          _isMarathi
              ? 'पृष्ठ $pageNumStr / $totalPageStr'
              : 'Page $pageNumStr of $totalPageStr',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  String _toMarathiDigits(String input) {
    const enToMr = {
      '0': '०',
      '1': '१',
      '2': '२',
      '3': '३',
      '4': '४',
      '5': '५',
      '6': '६',
      '7': '७',
      '8': '८',
      '9': '९',
    };
    return input.split('').map((c) => enToMr[c] ?? c).join();
  }

  // Floating Action Bottom Bar
  Widget _buildActionFloatingBar(BuildContext context, String contractNo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF003B99),
                side: const BorderSide(color: Color(0xFF003B99)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(
                _isMarathi ? 'व्हॉट्सॲपवर पाठवा' : 'Share WhatsApp',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () => _shareContract(context, contractNo),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003B99),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(
                _isMarathi ? 'PDF डाऊनलोड करा' : 'Download PDF',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () => _downloadContract(context, contractNo),
            ),
          ),
        ],
      ),
    );
  }

  void _shareContract(BuildContext context, String contractNo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF003B99),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isMarathi
                    ? 'AMC करारपत्र लिंक ($contractNo) तयार झाले व व्हॉट्सॲपवर शेअर केले!'
                    : 'AMC Contract ($contractNo) link prepared & shared on WhatsApp!',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadContract(BuildContext context, String contractNo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.download_done_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isMarathi
                    ? '२-पानी अधिकृत AMC करारपत्र ($contractNo.pdf) यशस्वीरित्या सेव्ह झाले!'
                    : '2-Page Official AMC Agreement ($contractNo.pdf) saved successfully!',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
