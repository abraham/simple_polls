// This file contains the widget which will appear below the options widget.
import 'package:flutter/material.dart';

import '../locale/poll_locale.dart';

class PollStatusBar extends StatelessWidget {
  /// This widget will show status of the poll.
  /// It shows total votes, time remaining in polling and undo button (if poll is editable).
  final int totalVotes;
  final PollLocale locale;
  final DateTime? endsAt;
  final bool hasEnded;
  final bool showUndo;
  final VoidCallback? onUndo;
  const PollStatusBar({
    super.key,
    required this.totalVotes,
    required this.locale,
    this.endsAt,
    this.hasEnded = false,
    this.showUndo = false,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Text(
          '$totalVotes ${locale.votesLabel}',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        /// A poll without an [endsAt] never ends, so there is nothing to show here.
        if (endsAt != null) ...[
          Text(
            ' • ',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            hasEnded
                ? locale.pollingEndedLabel
                : '${locale.endsLabel}: ${locale.formatTimeRemaining(endsAt!)}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],

        /// [showUndo] is only true when the poll is editable, the user has voted, and the poll hasn't ended.
        if (showUndo) ...[
          Text(
            ' • ',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          GestureDetector(
            onTap: onUndo,
            child: Text(
              locale.undoLabel,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
