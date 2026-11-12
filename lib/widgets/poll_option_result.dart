// This file contains the results widget for a single poll option.
import 'package:material_ui/material_ui.dart';

import '../locale/poll_locale.dart';
import 'poll_expressive.dart';
import 'poll_progress_bar.dart';

class PollOptionResult extends StatelessWidget {
  /// This widget will show the results of a single poll option.
  final String label;
  final double percentage;
  final bool isSelected;

  /// True for the option(s) with the most votes (Expressive only).
  final bool isLeading;
  final TextStyle? textStyle;
  final Color? progressBarColor;
  final double? progressBarHeight;
  final StyleVariant variant;
  final PollLocale locale;
  const PollOptionResult({
    super.key,
    required this.label,
    required this.percentage,
    this.isSelected = false,
    this.isLeading = false,
    this.textStyle,
    this.progressBarColor,
    this.progressBarHeight,
    this.variant = StyleVariant.material3Expressive,
    this.locale = PollLocale.en,
  });

  static final RoundedPolygon selectedBadgeShape = MaterialShapes.cookie12Sided;
  static final RoundedPolygon leadingBadgeShape = MaterialShapes.softBurst;

  String get _percentageText => '${(percentage * 100).toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      StyleVariant.material3 => _buildMaterial3(context),
      StyleVariant.material3Expressive => _buildExpressive(context),
    };
  }

  Widget _buildExpressive(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style:
                          textStyle ??
                          textTheme.titleSmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: isSelected ? FontWeight.w700 : null,
                          ),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Semantics(
                      label: locale.selectedLabel,
                      child: ExcludeSemantics(
                        child: PollShapeBadge(
                          shape: selectedBadgeShape,
                          color: colors.primary,
                          icon: Icons.check,
                          iconColor: colors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isLeading) ...[
              Semantics(
                label: locale.leadingLabel,
                child: ExcludeSemantics(
                  child: PollShapeBadge(
                    shape: leadingBadgeShape,
                    color: colors.tertiaryContainer,
                    icon: Icons.star_rounded,
                    iconColor: colors.onTertiaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              _percentageText,
              style: textTheme.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        PollProgressBar(
          value: percentage,
          color: progressBarColor,
          height: progressBarHeight,
        ),
      ],
    );
  }

  Widget _buildMaterial3(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      dense: true,
      minVerticalPadding: 0,
      visualDensity: VisualDensity.compact,
      title: Stack(
        alignment: Alignment.centerLeft,
        children: [
          /// PollProgressBar is a widget that works like a progress bar but will be static.
          PollProgressBar(
            value: percentage,
            color: progressBarColor,
            height: progressBarHeight,
            variant: StyleVariant.material3,
          ),

          /// This will create the label of the option in results screen.
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style:
                        textStyle ??
                        Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),

              /// If [isSelected] is true a circle with tick will appear after that label, which indicates the selection of that particular option.
              if (isSelected)
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18,
                    semanticLabel: locale.selectedLabel,
                  ),
                ),
            ],
          ),
        ],
      ),

      /// Trailing portion will show the percentage of votes for each option.
      trailing: Text(
        _percentageText,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
