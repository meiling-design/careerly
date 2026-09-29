import 'package:flutter/material.dart';

import '../motion/careerly_page_transition.dart';
import '../tokens/tokens.dart';

/// Careerly 统一主题。
///
/// 依据 Phase 1 §十二：
/// Material 3 可以作为 Flutter 的基础能力使用，
/// **但 Careerly 的视觉系统不能被 Material 3 默认样式主导**。
///
/// 因此这里显式覆盖了所有 Careerly 会实际用到的组件主题，
/// 不用 Material 的默认色板（`ColorScheme.fromSeed` 会覆盖品牌色，故不采用）。
abstract final class CareerlyTheme {
  /// App 使用的 ThemeData。
  static ThemeData light() {
    final ColorScheme colorScheme = _colorScheme();
    final TextTheme textTheme = AppTypography.asTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      // 中文 UI 的字体决策在此统一声明（Phase 0 O1）。
      fontFamily: AppTypography.fontFamily,
      // Careerly 使用自绘导航与自定义转场，不使用 Material 的默认页面转场。
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _CareerlyPageTransitionsBuilder(),
          TargetPlatform.iOS: _CareerlyPageTransitionsBuilder(),
        },
      ),
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: _appBarTheme(textTheme),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: _cardTheme(),
      chipTheme: _chipTheme(textTheme),
      elevatedButtonTheme: _elevatedButtonTheme(textTheme),
      outlinedButtonTheme: _outlinedButtonTheme(textTheme),
      textButtonTheme: _textButtonTheme(textTheme),
      inputDecorationTheme: _inputDecorationTheme(textTheme),
      bottomSheetTheme: _bottomSheetTheme(),
      dialogTheme: _dialogTheme(textTheme),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryBlue,
        linearTrackColor: AppColors.disabledSurface,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
      snackBarTheme: _snackBarTheme(textTheme),
    );
  }

  // ---------------------------------------------------------------------------
  // ColorScheme
  // ---------------------------------------------------------------------------

  /// 以 Careerly 品牌色为准构建 ColorScheme。
  ///
  /// 不使用 `ColorScheme.fromSeed`——种子算法会派生出一整套与 Figma 不符的色阶。
  static ColorScheme _colorScheme() {
    const ColorScheme base = ColorScheme.light(
      primary: AppColors.primaryBlue,
      onPrimary: AppColors.textInverse,
      primaryContainer: AppColors.primaryPurple,
      onPrimaryContainer: AppColors.textInverse,
      secondary: AppColors.primaryPurple,
      onSecondary: AppColors.textInverse,
      tertiary: AppColors.info,
      onTertiary: AppColors.textInverse,
      error: AppColors.danger,
      onError: AppColors.textInverse,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerHighest: AppColors.surfaceSubtle,
      outline: AppColors.divider,
      outlineVariant: AppColors.divider,
      shadow: Color(0x144F7EF5),
    );
    return base;
  }

  // ---------------------------------------------------------------------------
  // 组件主题
  // ---------------------------------------------------------------------------

  static AppBarTheme _appBarTheme(TextTheme textTheme) {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
      systemOverlayStyle: null,
    );
  }

  static CardThemeData _cardTheme() {
    return const CardThemeData(
      color: AppColors.glassFill,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
    );
  }

  static ChipThemeData _chipTheme(TextTheme textTheme) {
    return ChipThemeData(
      backgroundColor: AppColors.glassFillLight,
      selectedColor: AppColors.surfaceDark,
      disabledColor: AppColors.disabledSurface,
      labelStyle: textTheme.labelMedium,
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(
        color: AppColors.textInverse,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderPill),
      side: const BorderSide(color: AppColors.glassBorderLight),
      showCheckmark: false,
      elevation: 0,
      pressElevation: 0,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(TextTheme textTheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textInverse,
        disabledBackgroundColor: AppColors.disabledSurface,
        disabledForegroundColor: AppColors.disabled,
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(TextTheme textTheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        disabledForegroundColor: AppColors.disabled,
        textStyle: textTheme.labelLarge,
        side: const BorderSide(color: AppColors.glassBorder),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(TextTheme textTheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        disabledForegroundColor: AppColors.disabled,
        textStyle: textTheme.labelLarge,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(TextTheme textTheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.glassFillLight,
      hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      border: const OutlineInputBorder(
        borderRadius: AppRadius.borderMd,
        borderSide: BorderSide(color: AppColors.glassBorderLight),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppRadius.borderMd,
        borderSide: BorderSide(color: AppColors.glassBorderLight),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppRadius.borderMd,
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: AppRadius.borderMd,
        borderSide: BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: AppRadius.borderMd,
        borderSide: BorderSide(color: AppColors.danger, width: 1.5),
      ),
      disabledBorder: const OutlineInputBorder(
        borderRadius: AppRadius.borderMd,
        borderSide: BorderSide(color: AppColors.divider),
      ),
    );
  }

  static BottomSheetThemeData _bottomSheetTheme() {
    return const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: AppColors.surface,
      elevation: 0,
      modalElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      showDragHandle: true,
      dragHandleColor: AppColors.divider,
    );
  }

  static DialogThemeData _dialogTheme(TextTheme textTheme) {
    return DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
      titleTextStyle: textTheme.titleMedium,
      contentTextStyle: textTheme.bodyMedium,
    );
  }

  static SnackBarThemeData _snackBarTheme(TextTheme textTheme) {
    return SnackBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.textInverse,
      ),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      elevation: 0,
    );
  }
}

/// Careerly 自定义页面转场。
///
/// 依据 Baseline §6.6：
/// - 二级页面进入：右侧轻微进入（translationX 16–24px），240–300ms
/// - 返回：与进入形成相反关系，不允许瞬移或重新淡入整页
///
/// 不使用 M3 默认转场。
///
/// ⚠️ **本类不再自带转场实现**：它委托给 [CareerlyPageTransition]
/// —— `app/router/page_transitions.dart` 用的是同一个实现。
/// 早先这里抄了第二份（同为 280ms / `easeOutCubic` / `20/320`），
/// 改一处不会同步另一处（Phase 3 审计 B-7）。
class _CareerlyPageTransitionsBuilder extends PageTransitionsBuilder {
  const _CareerlyPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return CareerlyPageTransition.build(
      kind: CareerlyTransitionKind.push,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}
