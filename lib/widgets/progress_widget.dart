// This file contains a custom linear progress indicator.
import 'package:flutter/material.dart';

class CustomLinearProgressBar extends StatelessWidget {
  /// This class will return a widget that will show the percentage of polls of each options in bar representation.
  final double value;
  final Color? color;
  final double height;
  const CustomLinearProgressBar({
    super.key,
    this.value = 0,
    this.color,
    this.height = 35,
  });

  @override
  Widget build(BuildContext context) {
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
              height: height,

              /// constraint.maxWidth * value will return the width that shows the bar.
              /// For Example : on a 400px available space and value = 0.25, bar will take 25% of the 400px available.
              width: constraint.maxWidth * value,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              height: 35,

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
