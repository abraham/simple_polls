// This file contains a custom linear progress indicator.
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'poll_expressive.dart';

class PollProgressBar extends StatelessWidget {
  /// This class will return a widget that will show the percentage of votes of each option in bar representation.
  final double value;
  final Color? color;

  /// Defaults to 30 for Expressive and 35 for Material 3.
  final double? height;
  final StyleVariant variant;
  const PollProgressBar({
    super.key,
    this.value = 0,
    this.color,
    this.height,
    this.variant = StyleVariant.material3Expressive,
  });

  static const activeKey = ValueKey<String>('poll-progress-active');
  static const _gap = 4.0;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      StyleVariant.material3 => _buildMaterial3(context),
      StyleVariant.material3Expressive => _buildExpressive(context),
    };
  }

  /// Rounded active segment, a gap, then the track with a stop dot at its end.
  Widget _buildExpressive(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final activeColor = color ?? colors.primary;
    final barHeight = height ?? 30;
    final radius = BorderRadius.circular(barHeight / 2);
    final stopSize = math.min(barHeight / 3, 6.0);
    return SizedBox(
      height: barHeight,
      child: PollSpringValue(
        initialValue: 0,
        value: value,
        spring: Springs.standardSlowSpatial,
        builder: (context, animated) => LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final fraction = animated.clamp(0.0, 1.0);
            final activeWidth = fraction == 0
                ? 0.0
                : math.max(barHeight, width * fraction);
            final trackWidth = math.max(0.0, width - activeWidth - _gap);
            return Row(
              children: [
                Container(
                  key: activeKey,
                  width: math.min(activeWidth, width),
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: radius,
                  ),
                ),
                if (activeWidth > 0 && trackWidth > 0)
                  const SizedBox(width: _gap),
                if (trackWidth > 0)
                  Expanded(
                    child: Container(
                      alignment: AlignmentDirectional.centerEnd,
                      padding: EdgeInsets.all((barHeight - stopSize) / 2),
                      decoration: BoxDecoration(
                        color: colors.secondaryContainer,
                        borderRadius: radius,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: activeColor,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox.square(dimension: stopSize),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMaterial3(BuildContext context) {
    final barHeight = height ?? 35;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraint) {
        return Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),

                /// If [color] of bar is null default color will be applied.
                color: color ?? Theme.of(context).colorScheme.primaryContainer,
              ),
              height: barHeight,

              /// constraint.maxWidth * value will return the width that shows the bar.
              /// For Example : on a 400px available space and value = 0.25, bar will take 25% of the 400px available.
              width: constraint.maxWidth * value,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              height: barHeight,

              /// constraint.maxWidth * (1 - value) will fill the remanining space with the theme's surface color.
              /// For Example : on a 400px available space and value = 0.25, bar will take 75% of the 400px available.
              width: constraint.maxWidth * (1 - value),
            ),
          ],
        );
      },
    );
  }
}
