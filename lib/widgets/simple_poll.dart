// This file contains the main widget used to render a poll.
import 'dart:async';

import 'package:flutter/material.dart';

import '../locale/poll_locale.dart';
import '../models/poll_models.dart';
import '../style/poll_style.dart';
import 'poll_option_button.dart';
import 'poll_option_result.dart';
import 'poll_status_bar.dart';

/// Called when the user casts, changes, or clears (`null`) their vote.
/// The returned future is awaited before the "submitting" state clears, so a
/// host app can `await` a network call before [SimplePoll] reflects the vote.
typedef PollVoteChanged<T extends Object> = FutureOr<void> Function(
  PollVote<T>? vote,
);

/// Called when a future returned by [PollVoteChanged] throws.
typedef PollVoteError = void Function(Object error, StackTrace stackTrace);

class SimplePoll<T extends Object> extends StatefulWidget {
  /// The main poll widget. This is a fully controlled widget: it never
  /// mutates [poll] or [vote], it only reports intended changes via
  /// [onVoteChanged]. Pass the updated [poll]/[vote] back in once the host
  /// app has applied the change (see [Poll.withVoteApplied]).
  final Poll<T> poll;

  /// The vote already cast for [poll], or `null` if the user hasn't voted yet.
  final PollVote<T>? vote;
  final PollVoteChanged<T> onVoteChanged;
  final PollVoteError? onVoteError;
  final PollStyle style;
  final PollLocale locale;

  /// Overrides the default title text rendering, e.g. for rich text or a custom style.
  final WidgetBuilder? titleBuilder;

  const SimplePoll({
    super.key,
    required this.poll,
    required this.vote,
    required this.onVoteChanged,
    this.onVoteError,
    this.style = const PollStyle(),
    this.locale = PollLocale.en,
    this.titleBuilder,
  });

  @override
  State<SimplePoll<T>> createState() => _SimplePollState<T>();
}

class _SimplePollState<T extends Object> extends State<SimplePoll<T>> {
  /// [_endTimer] fires once the poll's end time is reached so the widget
  /// flips to the results view even if [widget.vote] never changes.
  Timer? _endTimer;
  bool _isSubmitting = false;

  /// Locally toggled-but-not-yet-submitted options for a multi-select poll.
  late Set<T> _pendingSelection;

  @override
  void initState() {
    super.initState();
    _pendingSelection = {...?widget.vote?.selectedOptionIds};
    _scheduleEndTimer();
  }

  @override
  void didUpdateWidget(covariant SimplePoll<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newVote = widget.vote;
    final isNewPoll = !_haveSameOptionIds(
      widget.poll.options,
      oldWidget.poll.options,
    );
    if (isNewPoll) {
      /// A genuinely different poll (different options) always resets any draft.
      _pendingSelection = {...?newVote?.selectedOptionIds};
    } else if (newVote != oldWidget.vote && newVote != null) {
      _pendingSelection = {...newVote.selectedOptionIds};
    }

    /// When [newVote] becomes null on the *same* poll (e.g. the user tapped
    /// Undo), [_pendingSelection] is intentionally left as-is so a
    /// multi-select poll re-opens with the previous choices still toggled.
    if (widget.poll.endsAt != oldWidget.poll.endsAt) {
      _endTimer?.cancel();
      _scheduleEndTimer();
    }
  }

  bool _haveSameOptionIds(List<PollOption<T>> a, List<PollOption<T>> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  void _scheduleEndTimer() {
    final endsAt = widget.poll.endsAt;
    if (endsAt != null && widget.poll.isActive) {
      _endTimer = Timer(endsAt.toUtc().difference(DateTime.now().toUtc()), () {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _endTimer?.cancel();
    super.dispose();
  }

  Future<void> _submit(PollVote<T>? newVote) async {
    setState(() => _isSubmitting = true);
    try {
      await widget.onVoteChanged(newVote);
    } catch (error, stackTrace) {
      widget.onVoteError?.call(error, stackTrace);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _selectSingle(T id) {
    if (!widget.poll.isActive || _isSubmitting) return;
    _submit(PollVote<T>({id}));
  }

  void _toggleMultiple(T id) {
    if (!widget.poll.isActive || _isSubmitting) return;
    setState(() {
      if (!_pendingSelection.remove(id)) {
        _pendingSelection.add(id);
      }
    });
  }

  void _submitMultiple() {
    if (_pendingSelection.isEmpty || _isSubmitting) return;
    _submit(PollVote<T>(Set.of(_pendingSelection)));
  }

  void _undo() {
    if (_isSubmitting) return;
    _submit(null);
  }

  @override
  Widget build(BuildContext context) {
    final poll = widget.poll;
    final vote = widget.vote;
    final hasVoted = vote != null && vote.selectedOptionIds.isNotEmpty;
    final showResults = hasVoted || poll.hasEnded;

    return Container(
      margin: widget.style.margin,
      padding: widget.style.padding,
      decoration:
          widget.style.decoration ??
          BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            color: Theme.of(context).colorScheme.surface,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.titleBuilder?.call(context) ??
              Text(
                poll.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
          const SizedBox(height: 10),

          /// This list will generate all the necessary poll options.
          ...List.generate(poll.options.length, (index) {
            final option = poll.options[index];
            final Widget optionWidget;
            if (showResults) {
              /// Check for 0/0 is present to avoid a division by zero.
              final percentage = poll.totalVotes == 0
                  ? 0.0
                  : option.voteCount / poll.totalVotes;
              optionWidget = PollOptionResult(
                label: option.label,
                percentage: percentage,
                isSelected:
                    vote?.selectedOptionIds.contains(option.id) ?? false,
                textStyle: widget.style.optionTextStyle,
                progressBarColor: widget.style.progressBarColor,
              );
            } else if (poll.allowsMultipleAnswers) {
              /// In multi-select mode, tapping only toggles the option; the vote is submitted separately.
              optionWidget = PollOptionButton(
                label: option.label,
                textStyle: widget.style.optionTextStyle,
                shape: widget.style.optionShape,
                showSelectionIndicator: true,
                isSelected: _pendingSelection.contains(option.id),
                onPressed: () => _toggleMultiple(option.id),
              );
            } else {
              optionWidget = PollOptionButton(
                label: option.label,
                textStyle: widget.style.optionTextStyle,
                shape: widget.style.optionShape,
                onPressed: () => _selectSingle(option.id),
              );
            }

            /// Adds a gap above every option except the first so buttons/results aren't flush against each other.
            return index == 0
                ? optionWidget
                : Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: optionWidget,
                  );
          }),
          const SizedBox(height: 5),

          /// For multi-select polls, show a submit button to cast the vote for all toggled options.
          if (poll.allowsMultipleAnswers && !showResults)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: ElevatedButton(
                onPressed: _pendingSelection.isNotEmpty && !_isSubmitting
                    ? _submitMultiple
                    : null,
                child: Text(widget.locale.voteButtonLabel),
              ),
            ),

          PollStatusBar(
            totalVotes: poll.totalVotes,
            locale: widget.locale,
            endsAt: poll.endsAt,
            hasEnded: poll.hasEnded,
            showUndo: poll.isEditable && hasVoted && poll.isActive,
            onUndo: _undo,
          ),
        ],
      ),
    );
  }
}
