// This file contains the actual option widget used.
import 'package:flutter/material.dart';

import '../models/poll_models.dart';

class PollButtonsWidget extends StatelessWidget {
  /// This class does not have state that's why created as stateless.
  final PollOptions optionModel;
  final TextStyle? optionsStyle;
  final Function() onPressed;
  final OutlinedBorder borderShape;

  /// When true, the button shows a checkmark and a filled background if [optionModel.isSelected] is true.
  /// Used for multi-select polls where an option can be toggled before submitting.
  final bool showSelectionIndicator;
  const PollButtonsWidget({
    super.key,
    required this.optionModel,
    required this.onPressed,
    this.optionsStyle,
    this.borderShape = const StadiumBorder(),
    this.showSelectionIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = showSelectionIndicator && optionModel.isSelected;
    return OutlinedButton(
      /// Calls the passed callback to capture response.
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        shape: borderShape,
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),

        /// Custom theme will be applied here.
        /// First it checks the passed parameter , if [optionsStyle] is null the default theme will be applied.
        textStyle:
            optionsStyle ??
            TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isSelected) ...[
            Icon(
              Icons.check_circle,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(optionModel.label, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
