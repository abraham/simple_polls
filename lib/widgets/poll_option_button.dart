import 'package:material_ui/material_ui.dart';

import '../style/poll_style.dart';
import '../style/poll_style_defaults.dart';
import 'poll_expressive.dart';

class PollOptionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final PollStyle style;

  /// Non-null makes the option toggleable with a selection indicator, as in
  /// multi-select polls where options are toggled before submitting.
  final bool? isSelected;

  /// Shows a loading indicator while this option's vote is submitting
  /// (Expressive only).
  final bool isLoading;
  const PollOptionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = const PollStyle(),
    this.isSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return style.isExpressive
        ? _buildExpressive(context)
        : _buildMaterial3(context);
  }

  Widget _buildExpressive(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected = isSelected ?? false;
    final Widget? leading = isLoading
        ? const PollShapeLoader()
        : isSelected != null
        ? PollSelectionIndicator(
            selected: selected,
            color: selected ? colors.onPrimary : colors.primary,
            checkColor: colors.primary,
          )
        : null;
    return expressiveButtonTheme(
      context,
      child: ElevatedButton(
        onPressed: onPressed,
        isSelected: isSelected,
        style: ElevatedButton.styleFrom(
          sizeVariant: ButtonSizeVariant.medium,
          shape: style.effectiveOptionShape,
          textStyle: style.optionTextStyle,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 12)],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterial3(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected = isSelected ?? false;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        backgroundColor: selected ? colors.primaryContainer : null,
        shape: style.effectiveOptionShape,
        side: BorderSide(color: colors.primary, width: 1.5),
        textStyle:
            style.optionTextStyle ?? Theme.of(context).textTheme.labelLarge,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (selected) ...[
            Icon(Icons.check_circle, size: 16, color: colors.primary),
            const SizedBox(width: 6),
          ],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
