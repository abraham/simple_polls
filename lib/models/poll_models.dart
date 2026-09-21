// Immutable data model for a poll: `Poll`, `PollOption`, and the vote a user has cast, `PollVote`.
import 'package:flutter/foundation.dart';

@immutable
class Poll<T extends Object> {
  /// The question/topic being polled, and the answers available for it.
  final String title;
  final List<PollOption<T>> options;
  final DateTime? endsAt;

  /// If true, users can select more than one option before submitting their vote.
  final bool allowsMultipleAnswers;

  /// If true, a voted poll shows an "undo" action to clear the vote and vote again.
  final bool isEditable;

  const Poll({
    required this.title,
    required this.options,
    this.endsAt,
    this.allowsMultipleAnswers = false,
    this.isEditable = false,
  });

  int get totalVotes =>
      options.fold(0, (total, option) => total + option.voteCount);

  /// True only when [endsAt] is set and already in the past. A poll with no [endsAt] never ends.
  bool get hasEnded =>
      endsAt != null && endsAt!.toUtc().isBefore(DateTime.now().toUtc());

  /// True when the poll can still accept votes: either it has no [endsAt], or [endsAt] is still in the future.
  bool get isActive => !hasEnded;

  Poll<T> copyWith({
    String? title,
    List<PollOption<T>>? options,
    DateTime? endsAt,
    bool? allowsMultipleAnswers,
    bool? isEditable,
  }) {
    return Poll<T>(
      title: title ?? this.title,
      options: options ?? this.options,
      endsAt: endsAt ?? this.endsAt,
      allowsMultipleAnswers:
          allowsMultipleAnswers ?? this.allowsMultipleAnswers,
      isEditable: isEditable ?? this.isEditable,
    );
  }

  /// Returns a copy with [previousVote]'s counts removed and [newVote]'s counts
  /// added, so a host app can optimistically update vote counts locally after
  /// a [PollVoteChanged] callback fires.
  Poll<T> withVoteApplied({
    required PollVote<T>? previousVote,
    required PollVote<T>? newVote,
  }) {
    final previousIds = previousVote?.selectedOptionIds ?? const {};
    final newIds = newVote?.selectedOptionIds ?? const {};
    return copyWith(
      options: options.map((option) {
        var voteCount = option.voteCount;
        if (previousIds.contains(option.id) && !newIds.contains(option.id)) {
          voteCount -= 1;
        } else if (!previousIds.contains(option.id) &&
            newIds.contains(option.id)) {
          voteCount += 1;
        }
        return option.copyWith(voteCount: voteCount);
      }).toList(),
    );
  }
}

@immutable
class PollOption<T extends Object> {
  /// A single answer a poll can be voted for.
  final T id;
  final String label;
  final int voteCount;

  const PollOption({required this.id, required this.label, this.voteCount = 0});

  PollOption<T> copyWith({String? label, int? voteCount}) {
    return PollOption<T>(
      id: id,
      label: label ?? this.label,
      voteCount: voteCount ?? this.voteCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PollOption<T> &&
          other.id == id &&
          other.label == label &&
          other.voteCount == voteCount);

  @override
  int get hashCode => Object.hash(id, label, voteCount);
}

@immutable
class PollVote<T extends Object> {
  /// The option(s) a user selected. A single-answer poll always has exactly one id.
  final Set<T> selectedOptionIds;

  const PollVote(this.selectedOptionIds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PollVote<T> &&
          setEquals(other.selectedOptionIds, selectedOptionIds));

  @override
  int get hashCode => Object.hashAllUnordered(selectedOptionIds);
}
