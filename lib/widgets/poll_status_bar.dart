import 'package:material_ui/material_ui.dart';

import '../locale/poll_locale.dart';
import '../models/poll_models.dart';
import '../style/poll_style.dart';
import '../style/poll_style_defaults.dart';
import 'poll_expressive.dart';

/// Vote count, time left or ended, and Undo, below the options.
class PollStatusBar extends StatelessWidget {
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

        if (showUndo) ...[
          separator,
          TextButton.icon(
            onPressed: onUndo,
            icon: expressive ? const Icon(Icons.undo, size: 18) : null,
            label: Text(locale.undoLabel),
          ),
        ],
      ],
    );
  }
}
