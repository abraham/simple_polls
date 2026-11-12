// Per-variant defaults for `PollStyle`. Not exported: internal to the widgets.
import 'package:material_ui/material_ui.dart';

import 'poll_style.dart';

extension PollStyleDefaults on PollStyle {
  bool get isExpressive => variant == StyleVariant.material3Expressive;

  EdgeInsets get effectivePadding =>
      padding ??
      (isExpressive
          ? const EdgeInsets.fromLTRB(16, 16, 16, 12)
          : const EdgeInsets.fromLTRB(15, 15, 15, 5));

  /// 30 makes Expressive result rows as tall as the option buttons.
  double get effectiveProgressBarHeight =>
      progressBarHeight ?? (isExpressive ? 30 : 35);

  /// Null lets the Expressive button morph its own shape.
  OutlinedBorder? get effectiveOptionShape =>
      optionShape ?? (isExpressive ? null : const StadiumBorder());

  double get titleGap => isExpressive ? 16 : 10;
  double get optionsGap => isExpressive ? 12 : 5;
  double get voteButtonGap => isExpressive ? 8 : 5;

  Decoration effectiveDecoration(BuildContext context) {
    if (decoration case final decoration?) return decoration;
    final theme = Theme.of(context);
    return isExpressive
        ? ShapeDecoration(
            color: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius:
                  containerRadius ??
                  const BorderRadius.all(Radius.circular(28)),
            ),
          )
        : BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            color: theme.colorScheme.surface,
          );
  }

  TextStyle? titleStyle(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    return isExpressive
        ? theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          )
        : theme.textTheme.titleSmall?.copyWith(color: color);
  }
}
