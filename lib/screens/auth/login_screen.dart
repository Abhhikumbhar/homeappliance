import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/user_account.dart';
import '../../state/app_state.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import '../customer/customer_home_screen.dart';
import '../partner/partner_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../../widgets/language_dropdown.dart';
import '../../widgets/design_components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sign In controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  bool _obscureLoginPassword = true;
  String? _loginError;
  bool _isLoggingIn = false;

  // Customer Register controllers
  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _regPhoneController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  bool _obscureRegPassword = true;
  String? _regError;
  bool _isRegistering = false;

  bool _checkedSession = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_checkedSession) {
      _checkedSession = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final appState = AppStateScope.of(context);
        if (appState.isLoggedIn && appState.currentUser != null) {
          final user = appState.currentUser!;
          if (user.role == UserRole.admin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          } else if (user.role == UserRole.partner) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PartnerDashboardScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
            );
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regPhoneController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AppState appState, bool isMr) async {
    if (_isLoggingIn) return;
    setState(() {
      _loginError = null;
      _isLoggingIn = true;
    });

    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _loginError = tr('कृपया ईमेल आणि पासवर्ड भरा.', 'Please enter email and password.');
        _isLoggingIn = false;
      });
      return;
    }

    try {
      final user = await appState.login(email, password);

      if (!mounted) return;

      setState(() {
        _isLoggingIn = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tr('लॉगिन यशस्वी! स्वागत आहे, ${AppHelpers.localizedText(user.name, isMr)}', 'Login successful! Welcome, ${AppHelpers.localizedText(user.name, isMr)}'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );

      if (user.role == UserRole.admin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else if (user.role == UserRole.partner) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PartnerDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loginError = e.toString().replaceAll('Exception: ', '');
        _isLoggingIn = false;
      });
    } finally {
      if (mounted && _isLoggingIn) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  Future<void> _handleRegisterCustomer(AppState appState, bool isMr) async {
    if (_isRegistering) return;
    setState(() {
      _regError = null;
      _isRegistering = true;
    });

    final name = _regNameController.text.trim();
    final phone = _regPhoneController.text.trim();
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _regError = tr('कृपया सर्व माहिती भरा.', 'Please fill in all details.');
        _isRegistering = false;
      });
      return;
    }

    if (phone.length != 10) {
      setState(() {
        _regError = tr('कृपया किमान १० अंकी वैध मोबाईल नंबर टाका.', 'Please enter a valid 10-digit phone number.');
        _isRegistering = false;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _regError = tr('पासवर्ड किमान ६ अक्षरी असावा.', 'Password must be at least 6 characters.');
        _isRegistering = false;
      });
      return;
    }

    try {
      final user = await appState.registerCustomer(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      // Pre-fill the login tab so user credentials are saved and ready
      _loginEmailController.text = email;
      _loginPasswordController.text = password;

      if (!mounted) return;

      setState(() {
        _isRegistering = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tr('नोंदणी यशस्वी! स्वागत आहे, ${AppHelpers.localizedText(user.name, isMr)}', 'Registration successful! Welcome, ${AppHelpers.localizedText(user.name, isMr)}'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );

      // Direct entry into customer home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _regError = e.toString().replaceAll('Exception: ', '');
        _isRegistering = false;
      });
    } finally {
      if (mounted && _isRegistering) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isMr = appState.isMarathi;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with Language Dropdown
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [LanguageDropdown()],
              ),
              const SizedBox(height: 12),

              // Brand Emblem & Heading
              Center(
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/young_master_logo.png',
                      width: 82,
                      height: 82,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Icon(
                          Icons.home_repair_service_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                tr('होम अप्लायन्स केअर', 'Home Appliance Care'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr('सांगली • मिरज • कराड • कुपवाड झोन', 'Sangli • Miraj • Karad • Kupwad Hub'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),

              // Segmented Tab Switcher (Register vs Sign In)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: [
                    Tab(
                      text: appState.tr(
                        'लॉगिन करा',
                        'Sign In',
                        hi: 'लॉगिन करें',
                        kn: 'ಲಾಗಿನ್ ಮಾಡಿ',
                        gu: 'લૉગિન કરો',
                      ),
                    ),
                    Tab(
                      text: appState.tr(
                        'नवीन नोंदणी',
                        'Create Account',
                        hi: 'नया खाता बनाएं',
                        kn: 'ಹೊಸ ಖಾತೆ ರಚಿಸಿ',
                        gu: 'નવું એકાઉન્ટ બનાવો',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tab View Content (Sign In first, Register second)
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _tabController.index == 0
                        ? _buildSignInForm(context, appState, isMr)
                        : _buildRegisterForm(context, appState, isMr),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SIGN IN FORM (Admin, Partner, Customer)
  // ==========================================
  Widget _buildSignInForm(BuildContext context, AppState appState, bool isMr) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('आपल्या खात्यात प्रवेश करा', 'Sign In to Your Portal'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr('नोंदणीकृत ईमेल आणि पासवर्ड भरा', 'Enter your registered email & password'),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_loginError != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.errorBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _loginError!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_loginError!.contains('नोंदणी') ||
                      _loginError!.toLowerCase().contains('register')) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        if (_loginEmailController.text.trim().isNotEmpty) {
                          _regEmailController.text =
                              _loginEmailController.text.trim();
                        }
                        _tabController.animateTo(1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 26),
                        child: Text(
                          tr('👉 प्रथम येथे नोंदणी करा (Register Here)', '👉 Register Here First'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Email Field
          TextField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: tr('ईमेल आयडी', 'Email Address'),
              hintText: 'name@example.com',
              prefixIcon: const Icon(
                Icons.alternate_email_rounded,
                size: 19,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Password Field
          TextField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPassword,
            decoration: InputDecoration(
              labelText: tr('पासवर्ड', 'Password'),
              hintText: '••••••••',
              prefixIcon: const Icon(
                Icons.key_rounded,
                size: 19,
                color: AppColors.textSecondary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureLoginPassword = !_obscureLoginPassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Primary Sign In Button
          AppButton(
            label: tr('लॉगिन करा', 'Sign In'),
            icon: Icons.login_rounded,
            variant: AppButtonVariant.primary,
            isLoading: _isLoggingIn,
            onPressed: () => _handleLogin(appState, isMr),
          ),
          const SizedBox(height: 16),


          // Link to Register Tab
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tr('नवीन ग्राहक आहात?', "New customer?"),
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  if (_loginEmailController.text.trim().isNotEmpty) {
                    _regEmailController.text =
                        _loginEmailController.text.trim();
                  }
                  _tabController.animateTo(1);
                },
                child: Text(
                  tr('येथे नोंदणी करा', 'Register Here'),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
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

  // ==========================================
  // CUSTOMER REGISTER FORM
  // ==========================================
  Widget _buildRegisterForm(
    BuildContext context,
    AppState appState,
    bool isMr,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('नवीन ग्राहक नोंदणी', 'Create Customer Account'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr('होम अप्लायन्स दुरुस्ती व AMC साठी खाते उघडा', 'Book home appliance repairs & AMC plans'),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_regError != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.errorBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _regError!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Full Name
          TextField(
            controller: _regNameController,
            decoration: InputDecoration(
              labelText: tr('पूर्ण नाव', 'Full Name'),
              hintText: tr('उदा. सचिन पाटील', 'e.g. Rahul Sharma'),
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Phone Number
          TextField(
            controller: _regPhoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              labelText: tr('मोबाईल नंबर', 'Phone Number'),
              hintText: '9822XXXXXX',
              counterText: '',
              prefixIcon: const Icon(
                Icons.phone_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Email
          TextField(
            controller: _regEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: tr('ईमेल आयडी', 'Email Address'),
              hintText: 'name@example.com',
              prefixIcon: const Icon(
                Icons.alternate_email_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Password
          TextField(
            controller: _regPasswordController,
            obscureText: _obscureRegPassword,
            decoration: InputDecoration(
              labelText: tr('पासवर्ड (किमान ६ अक्षरे)', 'Password (min 6 chars)'),
              prefixIcon: const Icon(
                Icons.key_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureRegPassword = !_obscureRegPassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Submit Button
          AppButton(
            label: tr('नोंदणी करा व पुढे जा', 'Create Account & Continue'),
            icon: Icons.arrow_forward_rounded,
            variant: AppButtonVariant.accent,
            isLoading: _isRegistering,
            onPressed: () => _handleRegisterCustomer(appState, isMr),
          ),
          const SizedBox(height: 16),

          // Link to Sign In Tab
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tr('आधीच खाते आहे?', 'Already have an account?'),
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  if (_regEmailController.text.trim().isNotEmpty) {
                    _loginEmailController.text =
                        _regEmailController.text.trim();
                  }
                  if (_regPasswordController.text.trim().isNotEmpty) {
                    _loginPasswordController.text =
                        _regPasswordController.text.trim();
                  }
                  _tabController.animateTo(0);
                },
                child: Text(
                  tr('लॉगिन करा', 'Sign In'),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
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
}
