import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../utils/colors.dart';

class LanguageDropdown extends StatelessWidget {
  final bool compact;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? borderColor;

  const LanguageDropdown({
    super.key,
    this.compact = false,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final currentLang = appState.currentLanguage;

    final effectiveBg = backgroundColor ?? Colors.white;
    final effectiveText = textColor ?? AppColors.primary;
    final effectiveIcon = iconColor ?? AppColors.primary;
    final effectiveBorder = borderColor ?? AppColors.border;

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: PopupMenuButton<AppLanguage>(
        tooltip: appState.tr('भाषा निवडा', 'Select Language', hi: 'भाषा चुनें', kn: 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ', gu: 'ભાષા પસંદ કરો'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        color: Colors.white,
        elevation: 10,
        shadowColor: const Color(0x260F172A),
        offset: Offset(0, compact ? 34 : 40),
        onSelected: (AppLanguage selected) {
          appState.setAppLanguage(selected);
        },
        itemBuilder: (BuildContext context) {
          final items = <PopupMenuEntry<AppLanguage>>[];
          for (int i = 0; i < AppLanguage.values.length; i++) {
            final lang = AppLanguage.values[i];
            final isSelected = lang == currentLang;

            items.add(
              PopupMenuItem<AppLanguage>(
                value: lang,
                height: 44,
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        lang.flag,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            lang.nativeName,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (lang != AppLanguage.english)
                            Text(
                              lang.englishName,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.8)
                                    : AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: AppColors.success,
                      ),
                  ],
                ),
              ),
            );

            if (i < AppLanguage.values.length - 1) {
              items.add(const PopupMenuDivider(height: 1));
            }
          }
          return items;
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 9 : 12,
            vertical: compact ? 5 : 7,
          ),
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: effectiveBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_rounded,
                size: compact ? 15 : 17,
                color: effectiveIcon,
              ),
              const SizedBox(width: 6),
              Text(
                currentLang.nativeName,
                style: TextStyle(
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  color: effectiveText,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: compact ? 16 : 18,
                color: effectiveIcon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
