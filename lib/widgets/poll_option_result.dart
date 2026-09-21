// This file contains the results widget for a single poll option.
import 'package:flutter/material.dart';

import 'poll_progress_bar.dart';

class PollOptionResult extends StatelessWidget {
  /// This widget will show the results of a single poll option.
  final String label;
  final double percentage;
  final bool isSelected;
  final TextStyle? textStyle;
  final Color? progressBarColor;
  const PollOptionResult({
    super.key,
    required this.label,
    required this.percentage,
    this.isSelected = false,
    this.textStyle,
    this.progressBarColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      dense: true,
      minVerticalPadding: 0,
      visualDensity: VisualDensity.compact,
      title: Stack(
        alignment: Alignment.centerLeft,
        children: [
          /// PollProgressBar is a widget that works like a progress bar but will be static.
          PollProgressBar(value: percentage, color: progressBarColor),

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
                        TextStyle(
                          fontSize: 13,
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
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18,
                  ),
                ),
            ],
          ),
        ],
      ),

      /// Trailing portion will show the percentage of votes for each option.
      trailing: Text(
        '${(percentage * 100).toStringAsFixed(1)}%',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
