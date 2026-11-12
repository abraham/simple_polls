// Single style object for a `SimplePoll`, replacing separate loose constructor params.
import 'package:material_ui/material_ui.dart';

@immutable
class PollStyle {
  /// [StyleVariant.material3Expressive] by default; use
  /// [StyleVariant.material3] for the 2.x look.
  final StyleVariant variant;
  final EdgeInsets margin;

  /// Defaults to 16/16/16/12 for Expressive and 15/15/15/5 for Material 3.
  final EdgeInsets? padding;

  /// Replaces the default card. Overrides [containerRadius].
  final Decoration? decoration;
  final TextStyle? optionTextStyle;

  /// Shape of every option button in every state. When null, Material 3 uses
  /// a [StadiumBorder] and Expressive uses the button's own shapes, which
  /// morph when pressed or selected.
  final OutlinedBorder? optionShape;
  final Color? progressBarColor;

  /// Defaults to 30 for Expressive, which makes result rows as tall as the
  /// option buttons, and 35 for Material 3.
  final double? progressBarHeight;

  /// Corner radius of the Expressive card. Defaults to 28.
  final BorderRadius? containerRadius;

  const PollStyle({
    this.variant = StyleVariant.material3Expressive,
    this.margin = const EdgeInsets.symmetric(horizontal: 8),
    this.padding,
    this.decoration,
    this.optionTextStyle,
    this.optionShape,
    this.progressBarColor,
    this.progressBarHeight,
    this.containerRadius,
  });

  PollStyle copyWith({
    StyleVariant? variant,
    EdgeInsets? margin,
    EdgeInsets? padding,
    Decoration? decoration,
    TextStyle? optionTextStyle,
    OutlinedBorder? optionShape,
    Color? progressBarColor,
    double? progressBarHeight,
    BorderRadius? containerRadius,
  }) {
    return PollStyle(
      variant: variant ?? this.variant,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
      optionTextStyle: optionTextStyle ?? this.optionTextStyle,
      optionShape: optionShape ?? this.optionShape,
      progressBarColor: progressBarColor ?? this.progressBarColor,
      progressBarHeight: progressBarHeight ?? this.progressBarHeight,
      containerRadius: containerRadius ?? this.containerRadius,
    );
  }
}
