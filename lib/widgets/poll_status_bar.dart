// This file contains the widget which will appear below the options widget.
import 'package:material_ui/material_ui.dart';

import '../locale/poll_locale.dart';
import '../models/poll_models.dart';
import '../style/poll_style.dart';
import '../style/poll_style_defaults.dart';
import 'poll_expressive.dart';

class PollStatusBar extends StatelessWidget {
  /// This widget will show status of the poll.
  /// It shows total votes, time remaining in polling and undo button (if poll is editable).
  final Poll<Object> poll;
  final PollLocale locale;
  final bool showUndo;
  final VoidCallback? onUndo;
  final PollStyle style;
  const PollStatusBar({
    super.key,
    required this.poll,
    required this.locale,
    this.showUndo = false,
    this.onUndo,
    this.style = const PollStyle(),
  });

  static final RoundedPolygon endedShape = MaterialShapes.flower;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: colors.onSurfaceVariant);
    final expressive = style.isExpressive;
    final endsAt = poll.endsAt;
    final hasEnded = poll.hasEnded;
    final separator = Text(' • ', style: textStyle);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '${poll.totalVotes} ${locale.votesLabel}',
          overflow: TextOverflow.ellipsis,
          style: textStyle,
        ),

        /// A poll without an [endsAt] never ends, so there is nothing to show here.
        if (endsAt != null) ...[
          separator,
          if (hasEnded && expressive) ...[
            PollShapeBadge(shape: endedShape, color: colors.tertiary, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            hasEnded
                ? locale.pollingEndedLabel
                : '${locale.endsLabel}: ${locale.formatTimeRemaining(endsAt)}',
            overflow: TextOverflow.ellipsis,
            style: textStyle,
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
