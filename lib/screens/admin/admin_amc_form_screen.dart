import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/amc_renewal.dart';
import '../../models/user_account.dart';
import '../../state/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import '../customer/amc_contract_document_screen.dart';

class AdminAmcFormScreen extends StatefulWidget {
  final AmcRenewal? renewalToEdit;

  const AdminAmcFormScreen({
    super.key,
    this.renewalToEdit,
  });

  @override
  State<AdminAmcFormScreen> createState() => _AdminAmcFormScreenState();
}

class _AdminAmcFormScreenState extends State<AdminAmcFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _contractNoCtrl;
  late TextEditingController _planNameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _frequencyCtrl;

  late DateTime _startDate;
  late DateTime _endDate;
  late RenewalStatus _status;

  late List<AmcEquipmentItem> _equipmentList;
  late List<AmcChecklistItem> _checklist;

  @override
  void initState() {
    super.initState();
    final r = widget.renewalToEdit;

    _nameCtrl = TextEditingController(text: r?.customerName ?? '');
    _phoneCtrl = TextEditingController(text: r?.customerPhone ?? '');
    _addressCtrl = TextEditingController(
      text: r?.address ?? '',
    );
    _contractNoCtrl = TextEditingController(
      text: r?.contractNo ??
          'AMC-YM-2026-${(1000 + DateTime.now().millisecondsSinceEpoch % 9000)}',
    );
    _planNameCtrl = TextEditingController(
      text: r?.planName ?? '',
    );
    _priceCtrl = TextEditingController(
      text: r != null ? r.planPrice.toInt().toString() : '',
    );
    _frequencyCtrl = TextEditingController(
      text: r?.frequency ?? '',
    );

    _startDate = r?.lastServiceDate ?? DateTime.now();
    _endDate = r?.nextDueDate ?? DateTime.now().add(const Duration(days: 365));
    _status = r?.status ?? RenewalStatus.renewed;

    // Initialize Equipment List
    if (r?.equipmentList != null && r!.equipmentList!.isNotEmpty) {
      _equipmentList = List.from(r.equipmentList!);
    } else {
      _equipmentList = [];
    }

    // Initialize Checklist
    if (r?.checklist != null && r!.checklist!.isNotEmpty) {
      _checklist = List.from(r.checklist!);
    } else {
      _checklist = [];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _contractNoCtrl.dispose();
    _planNameCtrl.dispose();
    _priceCtrl.dispose();
    _frequencyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isEditing = widget.renewalToEdit != null;

    final price = double.tryParse(_priceCtrl.text) ?? 0.0;
    final gst = (price * 0.18).roundToDouble();
    final total = price + gst;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEditing
              ? tr('AMC करारपत्र संपादित करा', 'Edit AMC Agreement')
              : tr('नवीन AMC करारपत्र भरा', 'Create AMC Agreement'),
          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, size: 20),
            tooltip: tr('माहिती', 'Help'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    tr(
                      'येथे भरलेली संपूर्ण माहिती ग्राहकाच्या अधिकृत २-पानी AMC करारपत्रात आपोआप दिसेल.',
                      'All details filled here will appear on the official 2-page AMC agreement.',
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF003B99), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr(
                                  'अधिकृत AMC करार फॉर्म (२-Page Contract)',
                                  'Official AMC Agreement Form (2-Page)',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                tr(
                                  'ग्राहक माहिती, उपकरणे व तपासणी चेकलिस्ट भरा. सेव्ह केल्यावर करारपत्र तयार होईल.',
                                  'Fill customer, appliances, and checklist. Contract generates instantly.',
                                ),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Section 1: Customer Details
                  _buildCard(
                    title: tr('१. ग्राहक तपशील', '1. Customer Details'),
                    icon: Icons.person_outline_rounded,
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: tr('ग्राहकाचे नाव *', 'Customer Name *'),
                          hintText: tr('उदा. सचिन पाटील', 'e.g. Sachin Patil'),
                          prefixIcon: const Icon(Icons.person, size: 20),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? tr('नाव आवश्यक आहे', 'Name required') : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: tr('मोबाईल नंबर *', 'Mobile Number *'),
                          counterText: '',
                          prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                        ),
                        validator: (v) => v == null || v.trim().length != 10
                            ? tr('१० अंकी मोबाईल आवश्यक आहे', 'Valid 10-digit number required')
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: tr('ग्राहकाचा पत्ता *', 'Customer Address *'),
                          hintText: tr('फ्लॅट क्र., सोसायटी, परिसर, सांगली', 'Flat, Society, Area, City'),
                          prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? tr('पत्ता आवश्यक आहे', 'Address required')
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 2: Contract Info
                  _buildCard(
                    title: tr('२. कराराची माहिती', '2. Contract Information'),
                    icon: Icons.receipt_long_rounded,
                    children: [
                      TextFormField(
                        controller: _contractNoCtrl,
                        decoration: InputDecoration(
                          labelText: tr('कॉन्ट्रॅक्ट क्र. *', 'Contract No. *'),
                          hintText: 'AMC-YM-2026-0842',
                          prefixIcon: const Icon(Icons.tag_rounded, size: 20),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? tr('कॉन्ट्रॅक्ट क्र. आवश्यक आहे', 'Contract No required')
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final p = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                                );
                                if (p != null) {
                                  setState(() {
                                    _startDate = p;
                                    _endDate = p.add(const Duration(days: 365));
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: tr('सुरुवात तारीख', 'Start Date'),
                                  prefixIcon: const Icon(Icons.calendar_today, size: 18),
                                ),
                                child: Text(AppHelpers.formatDate(_startDate), style: const TextStyle(fontSize: 12.5)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final p = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: _startDate,
                                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                                );
                                if (p != null) {
                                  setState(() => _endDate = p);
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: tr('मुदत समाप्ती तारीख', 'Valid Till Date'),
                                  prefixIcon: const Icon(Icons.event_available, size: 18),
                                ),
                                child: Text(AppHelpers.formatDate(_endDate), style: const TextStyle(fontSize: 12.5)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 3: Equipment Details
                  _buildCard(
                    title: tr('३. उपकरणांची यादी (Appliances)', '3. Equipment / Appliances List'),
                    icon: Icons.devices_other_rounded,
                    action: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF003B99),
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: Text(tr('+ उपकरण जोडा', '+ Add Appliance')),
                      onPressed: _addEquipmentDialog,
                    ),
                    children: [
                      if (_equipmentList.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: Text(
                              tr('कोणतेही उपकरण जोडलेले नाही. वरील बटण दाबून जोडा.', 'No appliances added. Tap above to add.'),
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _equipmentList.length,
                          separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                          itemBuilder: (ctx, idx) {
                            final eq = _equipmentList[idx];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFF003B99).withValues(alpha: 0.1),
                                child: Text(
                                  '${idx + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF003B99),
                                  ),
                                ),
                              ),
                              title: Text(
                                '${eq.applianceName} • ${eq.brandModel}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              subtitle: Text(
                                'Sr: ${eq.serialNo.isNotEmpty ? eq.serialNo : "-"} | स्थान: ${eq.location.isNotEmpty ? eq.location : "-"} | संख्या: ${eq.quantity}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 19),
                                onPressed: () {
                                  setState(() {
                                    _equipmentList.removeAt(idx);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 4: Plan & Cost
                  _buildCard(
                    title: tr('४. प्लॅन व शुल्क तपशील', '4. Plan & Cost Breakup'),
                    icon: Icons.currency_rupee_rounded,
                    children: [
                      TextFormField(
                        controller: _planNameCtrl,
                        decoration: InputDecoration(
                          labelText: tr('AMC प्लॅन नाव *', 'Plan Name *'),
                          hintText: 'Comprehensive Shield',
                          prefixIcon: const Icon(Icons.shield_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: tr('मूळ शुल्क (₹) *', 'Base Rate (₹) *'),
                                prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _frequencyCtrl,
                              decoration: InputDecoration(
                                labelText: tr('सर्व्हिस वारंवारता', 'Frequency'),
                                hintText: tr('उदा. दर ३ महिन्यांनी', 'e.g. Quarterly'),
                                prefixIcon: const Icon(Icons.repeat_rounded, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Calculation summary banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${tr("मूळ शुल्क:", "Base Rate:")} ₹${price.toInt()}',
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E40AF)),
                                ),
                                Text(
                                  '${tr("जीएसटी (१८%):", "GST (18%):")} ₹${gst.toInt()}',
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E40AF)),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  tr('एकूण देय रक्कम (Total Net):', 'Total Net Payable:'),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF003B99),
                                  ),
                                ),
                                Text(
                                  '₹${total.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF003B99),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 5: Technical Quality Checklist
                  _buildCard(
                    title: tr('५. सर्व्हिस तपासणी चेकलिस्ट', '5. Technical Quality Checklist'),
                    icon: Icons.checklist_rounded,
                    children: [
                      ..._checklist.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final isDone = item.status.contains('Done') ||
                            item.status.contains('पूर्ण') ||
                            item.status.contains('OK') ||
                            item.status.contains('Safe');
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isDone,
                                activeColor: const Color(0xFF16A34A),
                                onChanged: (val) {
                                  setState(() {
                                    _checklist[idx] = AmcChecklistItem(
                                      checkPoint: item.checkPoint,
                                      status: (val ?? false) ? 'पूर्ण (Done)' : 'प्रलंबित (Pending)',
                                      remarks: item.remarks,
                                    );
                                  });
                                },
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.checkPoint,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'शेरा: ${item.remarks}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save & View Contract Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003B99),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.save_rounded, size: 20),
                    label: Text(
                      isEditing
                          ? tr('अपडेट करा व २-पानी करारपत्र पहा', 'Update & View 2-Page Agreement')
                          : tr('करारपत्र जतन करा व तयार करा (View 2-Page Contract)', 'Save & Generate 2-Page Contract'),
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    onPressed: () => _saveAndOpenContract(context, appState, isEditing),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF003B99), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  void _addEquipmentDialog() {
    final appCtrl = TextEditingController();
    final brandCtrl = TextEditingController();
    final serialCtrl = TextEditingController();
    final locCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(tr('+ नवीन उपकरण जोडा', '+ Add Appliance Details'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: appCtrl,
                decoration: InputDecoration(
                  labelText: tr('उपकरणाचा प्रकार', 'Appliance Type'),
                  hintText: 'उदा. Split AC, Water Purifier RO, Fridge',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: brandCtrl,
                decoration: InputDecoration(
                  labelText: tr('ब्रँड व मॉडेल', 'Brand & Model'),
                  hintText: 'उदा. Daikin 1.5T, Kent Grand Plus',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: serialCtrl,
                decoration: InputDecoration(
                  labelText: tr('सिरीयल नंबर', 'Serial No.'),
                  hintText: 'उदा. DK-884210',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locCtrl,
                decoration: InputDecoration(
                  labelText: tr('स्थान / खोली', 'Room / Location'),
                  hintText: 'उदा. मास्टर बेडरूम, किचन',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text(tr('रद्द', 'Cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003B99),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (appCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _equipmentList.add(
                    AmcEquipmentItem(
                      applianceName: appCtrl.text.trim(),
                      brandModel: brandCtrl.text.trim(),
                      serialNo: serialCtrl.text.trim(),
                      quantity: 1,
                      location: locCtrl.text.trim(),
                    ),
                  );
                });
                Navigator.pop(dCtx);
              }
            },
            child: Text(tr('जोडा', 'Add')),
          ),
        ],
      ),
    );
  }

  void _saveAndOpenContract(BuildContext context, AppState appState, bool isEditing) {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;

    final primaryAppliance = _equipmentList.isNotEmpty
        ? _equipmentList.first.applianceName
        : (_planNameCtrl.text.trim().isNotEmpty ? _planNameCtrl.text.trim() : 'होम अप्लायन्सेस (Home Appliances)');
    final primaryBrand = _equipmentList.isNotEmpty
        ? _equipmentList.first.brandModel
        : '';

    final id = widget.renewalToEdit?.id ??
        'amc_${DateTime.now().millisecondsSinceEpoch}';

    final cName = _nameCtrl.text.trim();
    final cPhone = _phoneCtrl.text.trim();
    final cleanPhone = cPhone.replaceAll(RegExp(r'[^0-9]'), '');
    UserAccount? matchedUser;
    for (final u in appState.users) {
      final uClean = u.phone.replaceAll(RegExp(r'[^0-9]'), '');
      if ((cleanPhone.isNotEmpty && (uClean.endsWith(cleanPhone) || cleanPhone.endsWith(uClean))) ||
          (u.name.trim().toLowerCase() == cName.toLowerCase())) {
        matchedUser = u;
        break;
      }
    }

    final renewal = AmcRenewal(
      id: id,
      customerId: widget.renewalToEdit?.customerId ?? matchedUser?.id,
      contractNo: _contractNoCtrl.text.trim(),
      customerName: cName,
      customerPhone: cPhone,
      applianceName: primaryAppliance,
      brandModel: primaryBrand,
      lastServiceDate: _startDate,
      nextDueDate: _endDate,
      planName: _planNameCtrl.text.trim(),
      planPrice: price,
      frequency: _frequencyCtrl.text.trim(),
      status: _status,
      address: _addressCtrl.text.trim(),
      equipmentList: _equipmentList,
      checklist: _checklist,
    );

    if (isEditing) {
      appState.updateRenewal(renewal);
    } else {
      appState.addRenewal(renewal);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        content: Text(
          tr(
            'AMC करारपत्र यशस्वीरित्या सेव्ह झाले व तयार केले!',
            'AMC Agreement saved and generated successfully!',
          ),
        ),
      ),
    );

    // Open the 2-page Official Document Viewer immediately
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AmcContractDocumentScreen(renewal: renewal),
      ),
    );
  }
}
