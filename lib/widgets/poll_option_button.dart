// This file contains the button used to render a single, votable poll option.
import 'package:flutter/material.dart';

class PollOptionButton extends StatelessWidget {
  /// This class does not have state that's why created as stateless.
  final String label;
  final TextStyle? textStyle;
  final VoidCallback onPressed;
  final OutlinedBorder shape;

  /// When true, the button shows a checkmark and a filled background if [isSelected] is true.
  /// Used for multi-select polls where an option can be toggled before submitting.
  final bool showSelectionIndicator;
  final bool isSelected;
  const PollOptionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textStyle,
    this.shape = const StadiumBorder(),
    this.showSelectionIndicator = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final showIndicator = showSelectionIndicator && isSelected;
    return OutlinedButton(
      /// Calls the passed callback to capture response.
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: showIndicator
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        shape: shape,
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),

        /// Custom theme will be applied here.
        /// First it checks the passed parameter , if [textStyle] is null the default theme will be applied.
        textStyle:
            textStyle ??
            TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
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
