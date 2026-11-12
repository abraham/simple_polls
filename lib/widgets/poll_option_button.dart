// This file contains the button used to render a single, votable poll option.
import 'package:material_ui/material_ui.dart';

import 'poll_expressive.dart';

class PollOptionButton extends StatelessWidget {
  /// This class does not have state that's why created as stateless.
  final String label;
  final TextStyle? textStyle;
  final VoidCallback onPressed;

  /// Overrides the variant's default shape in every state.
  final OutlinedBorder? shape;
  final StyleVariant variant;

  /// When true, the button shows a selection indicator, filled if [isSelected] is true.
  /// Used for multi-select polls where an option can be toggled before submitting.
  final bool showSelectionIndicator;
  final bool isSelected;

  /// Shows a loading indicator while this option's vote is submitting
  /// (Expressive only).
  final bool isLoading;
  const PollOptionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textStyle,
    this.shape,
    this.variant = StyleVariant.material3Expressive,
    this.showSelectionIndicator = false,
    this.isSelected = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      StyleVariant.material3 => _buildMaterial3(context),
      StyleVariant.material3Expressive => _buildExpressive(context),
    };
  }

  Widget _buildExpressive(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected = showSelectionIndicator && isSelected;
    final Widget? leading = isLoading
        ? const PollShapeLoader()
        : showSelectionIndicator
        ? PollSelectionIndicator(
            selected: selected,
            color: selected ? colors.onPrimary : colors.primary,
            checkColor: colors.primary,
          )
        : null;
    return pollButtonTheme(
      context,
      variant: StyleVariant.material3Expressive,
      child: ElevatedButton(
        onPressed: onPressed,
        isSelected: showSelectionIndicator ? isSelected : null,
        style: ElevatedButton.styleFrom(
          sizeVariant: ButtonSizeVariant.medium,
          shape: shape,
          textStyle: textStyle,
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
    final showIndicator = showSelectionIndicator && isSelected;
    return OutlinedButton(
      /// Calls the passed callback to capture response.
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: showIndicator
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        shape: shape ?? const StadiumBorder(),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),

        /// Custom theme will be applied here.
        /// First it checks the passed parameter , if [textStyle] is null the default theme will be applied.
        textStyle: textStyle ?? Theme.of(context).textTheme.labelLarge,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIndicator) ...[
            Icon(
              Icons.check_circle,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
