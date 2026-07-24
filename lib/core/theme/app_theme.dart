import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_border_radius.dart';
import 'app_typography.dart';

abstract class AppTheme {
  // Built once and cached: these were getters, so every rebuild of the root
  // MaterialApp reconstructed both full ThemeData trees (and their GoogleFonts
  // text styles) — noticeable jank when toggling dark/light mode.
  static final ThemeData dark = _buildDark();
  static final ThemeData light = _buildLight();

  static ThemeData _buildDark() {
    const colorScheme = ColorScheme.dark(
      primary:        AppColors.teal,
      onPrimary:      AppColors.textInverse,
      secondary:      AppColors.blue,
      onSecondary:    AppColors.textInverse,
      error:          AppColors.error,
      onError:        AppColors.white,
      surface:        AppColors.dark800,
      onSurface:      AppColors.textPrimary,
      surfaceContainerHighest: AppColors.dark700,
      outline:        AppColors.dark600,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.dark900,


      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dark900,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h3,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.dark800,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.xlAll,
          side: const BorderSide(color: AppColors.dark600, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.dark700,
        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textHint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.lgAll,
          borderSide: const BorderSide(color: AppColors.dark600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.lgAll,
          borderSide: const BorderSide(color: AppColors.dark600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.lgAll,
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.lgAll,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.lgAll,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTypography.buttonMd,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.teal,
          side: const BorderSide(color: AppColors.teal),
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTypography.buttonMd,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.teal,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
          textStyle: AppTypography.buttonMd,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.dark700,
        selectedColor: AppColors.teal10,
        labelStyle: AppTypography.labelSm,
        side: const BorderSide(color: AppColors.dark600),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.pill),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.dark800,
        selectedItemColor: AppColors.teal,
        unselectedItemColor: AppColors.textHint,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.dark800,
        indicatorColor: AppColors.teal20,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.teal);
          }
          return const IconThemeData(color: AppColors.textHint);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelXs.copyWith(color: AppColors.teal);
          }
          return AppTypography.labelXs;
        }),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.dark800,
        selectedIconTheme: const IconThemeData(color: AppColors.teal),
        unselectedIconTheme: const IconThemeData(color: AppColors.textHint),
        indicatorColor: AppColors.teal20,
        selectedLabelTextStyle: AppTypography.labelSm.copyWith(color: AppColors.teal),
        unselectedLabelTextStyle: AppTypography.labelSm,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.dark600,
        thickness: 1,
        space: 1,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.dark800,
        modalBackgroundColor: AppColors.dark800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.dark800,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.xxlAll),
        elevation: 0,
        titleTextStyle: AppTypography.h3,
        contentTextStyle: AppTypography.bodyMd,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.dark700,
        contentTextStyle: AppTypography.bodyMd,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
        behavior: SnackBarBehavior.floating,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.teal : AppColors.textHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.teal20 : AppColors.dark600;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.teal : Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textInverse),
        side: const BorderSide(color: AppColors.dark500, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.xsAll),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.teal : AppColors.textHint;
        }),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.teal,
        inactiveTrackColor: AppColors.dark600,
        thumbColor: AppColors.teal,
        overlayColor: AppColors.teal10,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.teal,
        unselectedLabelColor: AppColors.textHint,
        indicatorColor: AppColors.teal,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: AppTypography.labelMd,
        unselectedLabelStyle: AppTypography.labelMd,
        dividerColor: AppColors.dark600,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.teal,
        linearTrackColor: AppColors.dark600,
      ),
    );
  }

  static ThemeData _buildLight() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary:    AppColors.teal,
        onPrimary:  AppColors.textInverse,
        secondary:  AppColors.blue,
        onSecondary: AppColors.textInverse,
        error:      AppColors.error,
        onError:    AppColors.white,
        surface:    AppColors.white,
        onSurface:  Color(0xFF1A202C),
        outline:    AppColors.light300,
      ),
      scaffoldBackgroundColor: AppColors.light100,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: const Color(0xFF1A202C),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h3.copyWith(color: const Color(0xFF1A202C)),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.xlAll,
          side: const BorderSide(color: AppColors.light300),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.light200,
        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.light400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: AppBorderRadius.lgAll, borderSide: const BorderSide(color: AppColors.light300)),
        enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.lgAll, borderSide: const BorderSide(color: AppColors.light300)),
        focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.lgAll, borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: AppBorderRadius.lgAll, borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: AppBorderRadius.lgAll, borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTypography.buttonMd,
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.light300, thickness: 1, space: 1),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        modalBackgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A202C),
        contentTextStyle: AppTypography.bodyMd.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lgAll),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
