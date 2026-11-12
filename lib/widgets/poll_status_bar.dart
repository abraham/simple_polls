// This file contains the widget which will appear below the options widget.
import 'package:material_ui/material_ui.dart';

import '../locale/poll_locale.dart';
import 'poll_expressive.dart';

class PollStatusBar extends StatelessWidget {
  /// This widget will show status of the poll.
  /// It shows total votes, time remaining in polling and undo button (if poll is editable).
  final int totalVotes;
  final PollLocale locale;
  final DateTime? endsAt;
  final bool hasEnded;
  final bool showUndo;
  final VoidCallback? onUndo;
  final StyleVariant variant;
  const PollStatusBar({
    super.key,
    required this.totalVotes,
    required this.locale,
    this.endsAt,
    this.hasEnded = false,
    this.showUndo = false,
    this.onUndo,
    this.variant = StyleVariant.material3Expressive,
  });

  static final RoundedPolygon endedShape = MaterialShapes.flower;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: colors.onSurfaceVariant);
    final expressive = variant == StyleVariant.material3Expressive;
    final separator = Text(' • ', style: style);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$totalVotes ${locale.votesLabel}',
          overflow: TextOverflow.ellipsis,
          style: style,
        ),

        /// A poll without an [endsAt] never ends, so there is nothing to show here.
        if (endsAt != null) ...[
          separator,
          if (hasEnded && expressive) ...[
            ExcludeSemantics(
              child: PollShapeBadge(
                shape: endedShape,
                color: colors.tertiary,
                size: 14,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            hasEnded
                ? locale.pollingEndedLabel
                : '${locale.endsLabel}: ${locale.formatTimeRemaining(endsAt!)}',
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ],

        /// [showUndo] is only true when the poll is editable, the user has voted, and the poll hasn't ended.
        if (showUndo) ...[
          separator,
          if (expressive)
            TextButton.icon(
              onPressed: onUndo,
              icon: const Icon(Icons.undo, size: 18),
              label: Text(locale.undoLabel),
            )
          else
            TextButton(onPressed: onUndo, child: Text(locale.undoLabel)),
        ],
      ],
    );
  }
}
