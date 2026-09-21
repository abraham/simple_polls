import 'package:flutter_test/flutter_test.dart';
import 'package:simple_polls/simple_polls.dart';

void main() {
  group('PollOption', () {
    test('defaults voteCount to 0', () {
      const option = PollOption(label: 'Yes', id: 1);
      expect(option.voteCount, 0);
    });

    test('copyWith overrides only the given fields', () {
      const option = PollOption(label: 'Yes', id: 1, voteCount: 5);
      final updated = option.copyWith(voteCount: 6);
      expect(updated.id, 1);
      expect(updated.label, 'Yes');
      expect(updated.voteCount, 6);
    });
  });

  group('Poll', () {
    test('defaults allowsMultipleAnswers and isEditable to false', () {
      const poll = Poll(title: 'Question', options: <PollOption<int>>[]);
      expect(poll.allowsMultipleAnswers, isFalse);
      expect(poll.isEditable, isFalse);
    });

    test('totalVotes sums each option voteCount', () {
      const poll = Poll(
        title: 'Question',
        options: [
          PollOption(id: 1, label: 'A', voteCount: 3),
          PollOption(id: 2, label: 'B', voteCount: 4),
        ],
      );
      expect(poll.totalVotes, 7);
    });

    test('is never ended/always active when endsAt is null', () {
      const poll = Poll(title: 'Question', options: <PollOption<int>>[]);
      expect(poll.hasEnded, isFalse);
      expect(poll.isActive, isTrue);
    });

    test('hasEnded/isActive reflect a past endsAt', () {
      final poll = Poll(
        title: 'Question',
        options: const <PollOption<int>>[],
        endsAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
      );
      expect(poll.hasEnded, isTrue);
      expect(poll.isActive, isFalse);
    });

    test('withVoteApplied increments the newly selected option', () {
      const poll = Poll(
        title: 'Question',
        options: [
          PollOption(id: 1, label: 'A', voteCount: 0),
          PollOption(id: 2, label: 'B', voteCount: 0),
        ],
      );
      final updated = poll.withVoteApplied(
        previousVote: null,
        newVote: const PollVote({1}),
      );
      expect(updated.options[0].voteCount, 1);
      expect(updated.options[1].voteCount, 0);
    });

    test('withVoteApplied moves the vote from the previous option', () {
      const poll = Poll(
        title: 'Question',
        options: [
          PollOption(id: 1, label: 'A', voteCount: 1),
          PollOption(id: 2, label: 'B', voteCount: 0),
        ],
      );
      final updated = poll.withVoteApplied(
        previousVote: const PollVote({1}),
        newVote: const PollVote({2}),
      );
      expect(updated.options[0].voteCount, 0);
      expect(updated.options[1].voteCount, 1);
    });

    test('withVoteApplied(null) undoes a vote', () {
      const poll = Poll(
        title: 'Question',
        options: [PollOption(id: 1, label: 'A', voteCount: 1)],
      );
      final updated = poll.withVoteApplied(
        previousVote: const PollVote({1}),
        newVote: null,
      );
      expect(updated.options[0].voteCount, 0);
    });
  });

  group('PollVote', () {
    test('equal sets of ids are equal', () {
      expect(const PollVote({1, 2}), const PollVote({2, 1}));
    });
  });
}
