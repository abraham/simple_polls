// Single style object for a `SimplePoll`, replacing separate loose constructor params.
import 'package:flutter/widgets.dart';

@immutable
class PollStyle {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Decoration? decoration;
  final TextStyle? optionTextStyle;
  final OutlinedBorder optionShape;
  final Color? progressBarColor;

  const PollStyle({
    this.margin = const EdgeInsets.symmetric(horizontal: 8),
    this.padding = const EdgeInsets.fromLTRB(15, 15, 15, 5),
    this.decoration,
    this.optionTextStyle,
    this.optionShape = const StadiumBorder(),
    this.progressBarColor,
  });

  PollStyle copyWith({
    EdgeInsets? margin,
    EdgeInsets? padding,
    Decoration? decoration,
    TextStyle? optionTextStyle,
    OutlinedBorder? optionShape,
    Color? progressBarColor,
  }) {
    return PollStyle(
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
      optionTextStyle: optionTextStyle ?? this.optionTextStyle,
      optionShape: optionShape ?? this.optionShape,
      progressBarColor: progressBarColor ?? this.progressBarColor,
    );
  }
}
