import 'package:flutter/material.dart';

import '../../models/amc_renewal.dart';
import '../../state/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import '../../widgets/design_components.dart';
import 'amc_contract_document_screen.dart';

class CustomerRenewalsScreen extends StatefulWidget {
  const CustomerRenewalsScreen({super.key});

  @override
  State<CustomerRenewalsScreen> createState() => _CustomerRenewalsScreenState();
}

class _CustomerRenewalsScreenState extends State<CustomerRenewalsScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Due Soon, 2: Active

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isMr = appState.isMarathi;
    final allRenewals = appState.customerRenewals;

    final filteredRenewals = allRenewals.where((r) {
      if (_selectedFilterIndex == 1) {
        return r.status == RenewalStatus.dueThisWeek ||
            r.status == RenewalStatus.dueThisMonth ||
            r.status == RenewalStatus.overdue;
      } else if (_selectedFilterIndex == 2) {
        return r.status == RenewalStatus.renewed;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          tr('माझे प्लॅन्स व AMC रिन्युअल्स', 'My Plans & AMC Protection'),
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Protection Shield Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.bannerGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppColors.coloredShadow(
                  const Color(0xFF003B99),
                  opacity: 0.25,
                  blur: 12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        tr('अप्लायन्स प्रोटेक्शन शील्ड', 'Annual Maintenance Shield'),
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('वेळेवर नियमित सर्व्हिसिंग आणि फिल्टर बदलल्याने उपकरणे दीर्घकाळ टिकतात आणि मोठा खर्च टळतो.', 'Periodic maintenance & filter replacements ensure peak efficiency and zero sudden breakdown repair costs.'),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.description_outlined, size: 16),
                    label: Text(
                      tr('अधिकृत AMC करारपत्र पहा (२-Page Document)', 'View Official AMC Agreement (2-Page Doc)'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AmcContractDocumentScreen(
                            renewal: allRenewals.isNotEmpty ? allRenewals.first : null,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section Title & Filter Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('नोंदणीकृत उपकरणे', 'Registered Appliances'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  '${allRenewals.length} ${tr("उपकरणे", "devices")}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip(
                    0,
                    tr('सर्व (${allRenewals.length})', 'All (${allRenewals.length})'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(1, tr('मुदत जवळ आली', 'Due Soon')),
                  const SizedBox(width: 8),
                  _buildFilterChip(2, tr('सक्रिय प्लॅन्स', 'Active Plans')),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (filteredRenewals.isEmpty)
              EmptyStateWidget(
                icon: Icons.shield_outlined,
                title: tr('कोणताही AMC प्लॅन नाही', 'No AMC Plans Found'),
                description: tr('आपल्या उपकरणांच्या सुरक्षेसाठी AMC प्लॅन निवडून सुरक्षित रहा.', 'No AMC plans in this filter category.'),
              )
            else
              ...filteredRenewals.map(
                (r) => _buildPlanCard(context, appState, r, isMr),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryLight,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
      ),
      onSelected: (val) {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    AppState appState,
    AmcRenewal r,
    bool isMr,
  ) {
    Color badgeColor;
    switch (r.status) {
      case RenewalStatus.dueThisWeek:
        badgeColor = AppColors.warning;
        break;
      case RenewalStatus.dueThisMonth:
        badgeColor = AppColors.primary;
        break;
      case RenewalStatus.overdue:
        badgeColor = AppColors.error;
        break;
      case RenewalStatus.renewed:
        badgeColor = AppColors.success;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (r.applianceName.isNotEmpty) ...[
                        Text(
                          r.applianceName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF003B99),
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        r.brandModel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: badgeColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    tr(r.status.labelMr, r.status.labelEn),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              r.planName,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${tr("मागील सर्व्हिस:", "Last Service:")} ${AppHelpers.formatDate(r.lastServiceDate)}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.alarm_rounded,
                    size: 16,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${tr("मुदत:", "Due:")} ${AppHelpers.formatDate(r.nextDueDate)}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppHelpers.formatCurrency(r.planPrice),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF003B99),
                        side: const BorderSide(color: Color(0xFF003B99)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.description_outlined, size: 14),
                      label: Text(
                        tr('करारपत्र', 'Contract'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AmcContractDocumentScreen(renewal: r),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    if (r.status != RenewalStatus.renewed)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          appState.renewAmc(r.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                tr('${r.brandModel} ची AMC १ वर्षासाठी वाढवली!', '${r.brandModel} AMC extended for 1 year!'),
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        child: Text(
                          tr('रिन्यू करा', 'RENEW'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else
                      const Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.success,
                            size: 16,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'सक्रिय',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
