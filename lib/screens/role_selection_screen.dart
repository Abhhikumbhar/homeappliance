import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../utils/colors.dart';
import 'customer/customer_home_screen.dart';
import 'partner/partner_dashboard_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import '../widgets/language_dropdown.dart';
import '../widgets/design_components.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
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
                  width: 38,
                  height: 38,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.home_repair_service_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Home Appliance Care',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    tr('सांगली • कराड • कुपवाड • मिरज', 'Sangli • Karad • Kupwad • Miraj'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: LanguageDropdown(compact: true),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              Text(
                appState.tr(
                  'ॲप सुरू करण्यासाठी पोर्टल निवडा',
                  'Select Portal to Continue',
                  hi: 'ऐप शुरू करने के लिए पोर्टल चुनें',
                  kn: 'ಆ್ಯಪ್ ಪ್ರಾರಂಭಿಸಲು ಪೋರ್ಟಲ್ ಆಯ್ಕೆಮಾಡಿ',
                  gu: 'એપ શરૂ કરવા માટે પોર્ટલ પસંદ કરો',
                ),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                appState.tr(
                  'आपण ग्राहक, अधिकृत कामगार किंवा ॲडमिन म्हणून प्रवेश करू शकता:',
                  'Choose your portal to enter as a Customer, Field Partner, or Admin:',
                  hi: 'आप ग्राहक, सर्विस पार्टनर या एडमिन के रूप में प्रवेश कर सकते हैं:',
                  kn: 'ನೀವು ಗ್ರಾಹಕರು, ಸೇವಾ ಪಾಲುದಾರರು ಅಥವಾ ನಿರ್ವಾಹಕರಾಗಿ ಪ್ರವೇಶಿಸಬಹುದು:',
                  gu: 'તમે ગ્રાહક, સર્વિસ પાર્ટનર અથવા એડમિન તરીકે પ્રવેશ કરી શકો છો:',
                ),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),

              // OPTION 1: CUSTOMER APP (ग्राहक ॲप)
              _buildRoleCard(
                context: context,
                themeColor: AppColors.primary,
                gradient: const LinearGradient(
                  colors: [Color(0xFF0047BA), Color(0xFF00338D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.person_pin_circle_rounded,
                badgeText: appState.tr(
                  'सर्व्हिस बुकिंग व केअर',
                  'Service Booking & AMC',
                  hi: 'सर्विस बुकिंग व केयर',
                  kn: 'ಸೇವಾ ಬುಕಿಂಗ್ ಮತ್ತು ಕಾಳಜಿ',
                  gu: 'સર્વિસ બુકિંગ અને કેર',
                ),
                title: appState.tr(
                  '१. ग्राहक पोर्टल',
                  '1. Customer Portal',
                  hi: '१. ग्राहक पोर्टल',
                  kn: '೧. ಗ್ರಾಹಕ ಪೋರ್ಟಲ್',
                  gu: '૧. ગ્રાહક પોર્ટલ',
                ),
                description: tr('घरातील एसी, फ्रीज, वॉशिंग मशीन, आरओ व प्लंबिंग सर्व्हिस बुक करा. दिवाळी ऑफर्स, पारदर्शक बिलिंग व ३० दिवस गॅरंटी.', 'Book AC, Refrigerator, RO, Washing Machine & Plumbing repairs with 30-day warranty & transparent pricing.'),
                features: trList([
                        '३० दिवस सर्व्हिस शील्ड',
                        'सुरक्षित OTP पडताळणी',
                        'लाईव्ह ट्रॅकिंग',
                      ], [
                        '30-Day Service Shield',
                        'Secure OTP Start',
                        'Live Tracking',
                      ]),
                buttonText: appState.tr('ग्राहक ॲप उघडा', 'ENTER CUSTOMER PORTAL', hi: 'ग्राहक ऐप खोलें', kn: 'ಗ್ರಾಹಕ ಆ್ಯಪ್ ತೆರೆಯಿರಿ', gu: 'ગ્રાહક એપ ખોલો'),
                onTap: () {
                  appState.setRole(AppRole.customer);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerHomeScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // OPTION 2: PARTNER APP (कामगार ॲप)
              _buildRoleCard(
                context: context,
                themeColor: AppColors.partnerTheme,
                gradient: AppColors.partnerGradient,
                icon: Icons.engineering_rounded,
                badgeText: appState.tr(
                  '१०वी-१२वी कामगारांसाठी सोपे',
                  'Partner & Technician Edition',
                  hi: 'टेक्नीशियन पार्टनर एडिशन',
                  kn: 'ತಂತ್ರಜ್ಞ ಪಾಲುದಾರ ಆವೃತ್ತಿ',
                  gu: 'ટેકનિશિયન પાર્ટનર એડિશન',
                ),
                title: appState.tr(
                  '२. कामगार पोर्टल',
                  '2. Service Partner Portal',
                  hi: '२. पार्टनर पोर्टल',
                  kn: '೨. ಪಾಲುದಾರ ಪೋರ್ಟಲ್',
                  gu: '૨. પાર્ટનર પોર્ટલ',
                ),
                description: tr('नवीन कामाचे थेट अलर्ट, १-क्लिक गुगल मॅप्सने ग्राहकाचे घर शोधणे, OTP व्हेरिफिकेशन, सुटे भाग ऍड करणे व रोजची कमाई ट्रॅकिंग.', 'Real-time job alerts, 1-tap Google Maps route, OTP start verification, spare parts biller & daily earnings tracker.'),
                features: trList([
                        '१-क्लिक गुगल मॅप्स',
                        'थेट व्हॉट्सॲप चॅट',
                        'रोजची कमाई तपशील',
                      ], [
                        '1-Tap Google Maps',
                        'WhatsApp Concierge',
                        'Daily Earnings',
                      ]),
                buttonText: appState.tr('कामगार ॲप उघडा', 'ENTER PARTNER PORTAL', hi: 'पार्टनर ऐप खोलें', kn: 'ಪಾಲುದಾರ ಆ್ಯಪ್ ತೆರೆಯಿರಿ', gu: 'પાર્ટનર એપ ખોલો'),
                onTap: () {
                  appState.setRole(AppRole.partner);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PartnerDashboardScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // OPTION 3: SUPER ADMIN (सुपर ॲडमिन)
              _buildRoleCard(
                context: context,
                themeColor: AppColors.adminPrimary,
                gradient: AppColors.adminGradient,
                icon: Icons.admin_panel_settings_rounded,
                badgeText: appState.tr(
                  'व्यवसाय नियंत्रण व ऑपरेशन्स',
                  'Operations & Dispatch Control',
                  hi: 'बिजनेस कंट्रोल व ऑपरेशन्स',
                  kn: 'ವ್ಯವಹಾರ ನಿಯಂತ್ರಣ ಮತ್ತು ಕಾರ್ಯಾಚರಣೆಗಳು',
                  gu: 'બિઝનેસ કંટ્રોલ અને ઓપરેશન્સ',
                ),
                title: appState.tr(
                  '३. सुपर ॲडमिन पॅनेल',
                  '3. Super Admin Portal',
                  hi: '३. सुपर एडमिन पोर्टल',
                  kn: '೩. ಸೂಪರ್ ನಿರ್ವಾಹಕ ಪೋರ್ಟಲ್',
                  gu: '૩. સુપર એડમિન પોર્ટલ',
                ),
                description: tr('ऑटो किंवा मॅन्युअल लीड असाइनमेंट, AMC व सर्व्हिसिंग रिन्युअल्स ट्रॅकर, १-क्लिक व्हॉट्सॲप अलर्ट्स, सेवा कॅटलॉग व महसूल आकडेवारी.', 'Smart auto/manual lead routing, AMC renewal radar, 1-click WhatsApp alerts, service catalog control & revenue analytics.'),
                features: trList([
                        'स्मार्ट डिस्पेच इंजिन',
                        'कॅटलॉग व्यवस्थापन',
                        'AMC रिन्युअल्स ट्रॅकर',
                      ], [
                        'Smart Dispatch Engine',
                        'Catalog Control',
                        'AMC Renewal Radar',
                      ]),
                buttonText: appState.tr('ॲडमिन पॅनेल उघडा', 'ENTER ADMIN PORTAL', hi: 'एडमिन पोर्टल खोलें', kn: 'ನಿರ್ವಾಹಕ ಪೋರ್ಟಲ್ ತೆರೆಯಿರಿ', gu: 'એડમિન પોર્ટલ ખોલો'),
                onTap: () {
                  appState.setRole(AppRole.admin);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDashboardScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required Color themeColor,
    required LinearGradient gradient,
    required IconData icon,
    required String badgeText,
    required String title,
    required String description,
    required List<String> features,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: AppColors.coloredShadow(
                    themeColor,
                    opacity: 0.25,
                    blur: 8,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: features.map((f) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 12,
                      color: themeColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      f,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
