import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'state/app_state.dart';
import 'screens/splash_screen.dart';
import 'utils/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
  // Load local cached preferences/session immediately (< 15ms)
  await appState.init();

  // Render UI immediately so SplashScreen appears with zero white screen delay!
  runApp(HomeApplianceApp(appState: appState));

  // Initialize Firebase and Cloud Firestore sync asynchronously in background
  _initializeFirebaseAsync(appState);
}

Future<void> _initializeFirebaseAsync(AppState appState) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase successfully initialized!');
    await appState.initFirebaseSync();
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }
}

class HomeApplianceApp extends StatefulWidget {
  final AppState appState;
  const HomeApplianceApp({super.key, required this.appState});

  @override
  State<HomeApplianceApp> createState() => _HomeApplianceAppState();
}

class _HomeApplianceAppState extends State<HomeApplianceApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = widget.appState;
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  static String _getFontFamilyFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.marathi:
      case AppLanguage.hindi:
        return 'Noto Sans Devanagari';
      case AppLanguage.gujarati:
        return 'Noto Sans Gujarati';
      case AppLanguage.kannada:
        return 'Noto Sans Kannada';
      case AppLanguage.english:
        return 'Roboto';
    }
  }

  static const List<String> _fontFallback = [
    'Noto Sans Devanagari',
    'Kohinoor Devanagari',
    'Noto Sans Gujarati',
    'Gujarati Sangam MN',
    'Noto Sans Kannada',
    'Kannada Sangam MN',
    'Roboto',
    'system-ui',
    '-apple-system',
    'sans-serif',
  ];

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: _appState,
      child: ListenableBuilder(
        listenable: _appState,
        builder: (context, _) {
          final lang = _appState.currentLanguage;
          return MaterialApp(
            title: 'Home Appliances On-Demand',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                onPrimary: Colors.white,
                secondary: AppColors.accent,
                onSecondary: Colors.white,
                surface: AppColors.surface,
                onSurface: AppColors.textPrimary,
                error: AppColors.error,
                onError: Colors.white,
              ),
              scaffoldBackgroundColor: AppColors.background,
              fontFamily: _getFontFamilyFor(lang),
              fontFamilyFallback: _fontFallback,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
            iconTheme: IconThemeData(color: AppColors.textPrimary),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border, width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
            labelStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
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
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            margin: EdgeInsets.zero,
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titleTextStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: AppColors.textPrimary,
            contentTextStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: AppColors.border,
            thickness: 1,
            space: 1,
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),
        ),
        home: const SplashScreen(),
      );
    },
  ),
);
  }
}
