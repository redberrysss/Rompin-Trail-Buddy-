import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Color extension
// ---------------------------------------------------------------------------
extension ColorFromHex on Color {
  /// Creates a [Color] from a hex string, e.g. `'#2E7D32'` or `'2E7D32'`.
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('FF');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

// ---------------------------------------------------------------------------
// AppTheme – ASD-friendly colour palette & design tokens
// ---------------------------------------------------------------------------
class AppTheme {
  AppTheme._();

  // ── Primary palette ──────────────────────────────────────────────────────
  static const Color forestGreen = Color(0xFF2E7D32);
  static const Color emerald = Color(0xFF00B894);
  static const Color softBlue = Color(0xFF74B9FF);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color softOrange = Color(0xFFFFB347);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color cardWhite = Color(0xFFFAFAF7);
  static const Color secondaryText = Color(0xFF8E8E93);
  static const Color dividerColor = Color(0xFFE8E8E5);
  static const Color softYellow = Color(0xFFFFD93D);
  static const Color gentleCoral = Color(0xFFFF8A80);
  static const Color lavender = Color(0xFFC3AED6);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color creamBackground = Color(0xFFFDFBF7);
  static const Color cardBackground = Color(0xFFFAFAF7);

  // ── Derived / utility colours ────────────────────────────────────────────
  static const Color primary = forestGreen;
  static const Color onPrimary = Colors.white;
  static const Color surface = creamBackground;
  static const Color onSurface = Color(0xFF212121);
  static const Color error = gentleCoral;
  static const Color onError = Colors.white;
  static const Color scaffoldBg = creamBackground;

  // ── Font sizes (match Swift) ─────────────────────────────────────────────
  static const double fontSizeTitle = 28;
  static const double fontSizeHeadline = 22;
  static const double fontSizeBody = 17;
  static const double fontSizeCaption = 13;
  static const double fontSizeSmall = 11;

  // ── Font weights ─────────────────────────────────────────────────────────
  static const FontWeight weightBold = FontWeight.bold;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightRegular = FontWeight.w400;

  // ── Padding (standard = 20) ──────────────────────────────────────────────
  static const double paddingStandard = 20;
  static const double paddingSmall = 12;
  static const double paddingMedium = 16;
  static const double paddingLarge = 24;
  static const double paddingXLarge = 32;

  // ── Border radii ─────────────────────────────────────────────────────────
  static const double radiusCard = 24;
  static const double radiusSmall = 16;
  static const double radiusButton = 20;
  static const double radiusDefault = 12;

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [forestGreen, emerald],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [warmBeige, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [softBlue, lavender],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient forestGradient = LinearGradient(
    colors: [darkGreen, forestGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── ThemeData ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: forestGreen,
      brightness: Brightness.light,
      primary: forestGreen,
      onPrimary: onPrimary,
      surface: surface,
      onSurface: onSurface,
      error: error,
      onError: onError,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSizeTitle,
          fontWeight: weightBold,
          color: onSurface,
        ),
        displayMedium: TextStyle(
          fontSize: fontSizeHeadline,
          fontWeight: weightSemiBold,
          color: onSurface,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: weightSemiBold,
          color: onSurface,
        ),
        headlineLarge: TextStyle(
          fontSize: fontSizeHeadline,
          fontWeight: weightSemiBold,
          color: onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: weightSemiBold,
          color: onSurface,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: weightMedium,
          color: onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeBody,
          fontWeight: weightRegular,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: weightRegular,
          color: onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: fontSizeCaption,
          fontWeight: weightRegular,
          color: secondaryText,
        ),
        labelLarge: TextStyle(
          fontSize: fontSizeBody,
          fontWeight: weightSemiBold,
          color: onPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: fontSizeCaption,
          fontWeight: weightMedium,
          color: secondaryText,
        ),
        labelSmall: TextStyle(
          fontSize: fontSizeSmall,
          fontWeight: weightRegular,
          color: secondaryText,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: fontSizeHeadline,
          fontWeight: weightSemiBold,
          color: onSurface,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          foregroundColor: onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingLarge,
            vertical: paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: fontSizeBody,
            fontWeight: weightSemiBold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forestGreen,
          side: const BorderSide(color: forestGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: paddingLarge,
            vertical: paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          textStyle: const TextStyle(
            fontSize: fontSizeBody,
            fontWeight: weightSemiBold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: paddingMedium,
          vertical: paddingMedium,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: forestGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: gentleCoral),
        ),
        labelStyle: const TextStyle(
          color: secondaryText,
          fontSize: fontSizeBody,
        ),
        hintStyle: const TextStyle(
          color: secondaryText,
          fontSize: fontSizeBody,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable buttons (PrimaryButton equivalent)
// ---------------------------------------------------------------------------

/// Primary filled button – main call-to-action.
class RoundedButton extends StatelessWidget {
  const RoundedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.width,
    this.height = 56,
    this.isEnabled = true,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isEnabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ScaleButton(
        onTap: isEnabled && !isLoading ? onPressed : null,
        child: Container(
          decoration: BoxDecoration(
            gradient: isEnabled
                ? AppTheme.primaryGradient
                : LinearGradient(
                    colors: [Colors.grey.shade300, Colors.grey.shade400],
                  ),
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: AppTheme.forestGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: foregroundColor ?? Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: foregroundColor ?? Colors.white,
                            fontSize: AppTheme.fontSizeBody,
                            fontWeight: AppTheme.weightSemiBold,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Secondary (outlined / ghost) button.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderColor,
    this.foregroundColor,
    this.icon,
    this.width,
    this.height = 56,
    this.isEnabled = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? foregroundColor;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? AppTheme.forestGreen;
    final border = borderColor ?? AppTheme.forestGreen;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ScaleButton(
        onTap: isEnabled ? onPressed : null,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
            border: Border.all(
              color: isEnabled ? border : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: isEnabled ? fg : Colors.grey, size: 20),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isEnabled ? fg : Colors.grey,
                      fontSize: AppTheme.fontSizeBody,
                      fontWeight: AppTheme.weightSemiBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular icon button for toolbars and cards.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.iconSize = 24,
    this.elevation = 2,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: elevation * 4,
              offset: Offset(0, elevation),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppTheme.forestGreen,
          size: iconSize,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ScaleButton – tap-scale animation (matches iOS ScaleButtonStyle)
// ---------------------------------------------------------------------------

/// Wraps its child with a scale-down / scale-up animation on press.
class ScaleButton extends StatefulWidget {
  const ScaleButton({
    super.key,
    required this.onTap,
    required this.child,
    this.scaleDown = 0.95,
    this.duration = const Duration(milliseconds: 120),
  });

  final VoidCallback? onTap;
  final Widget child;
  final double scaleDown;
  final Duration duration;

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scaleAnim = Tween<double>(
      begin: 1,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent _) {
    if (widget.onTap != null) _controller.forward();
  }

  void _onPointerUp(PointerUpEvent _) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onPointerCancel(PointerCancelEvent _) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnim.value, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CardStyle – extension for applying ASD-friendly card decoration
// ---------------------------------------------------------------------------

extension CardStyle on Widget {
  /// Wraps the widget in a styled card matching the Rompin Forest Explorer
  /// design language (soft shadows, rounded corners, cream background).
  Widget cardStyle({
    double borderRadius = AppTheme.radiusCard,
    Color backgroundColor = AppTheme.cardBackground,
    EdgeInsets padding = const EdgeInsets.all(AppTheme.paddingStandard),
    EdgeInsets? margin,
    double elevation = 2,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: elevation * 5,
            offset: Offset(0, elevation * 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(padding: padding, child: this),
      ),
    );
  }
}
