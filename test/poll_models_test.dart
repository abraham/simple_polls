import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_polls/simple_polls.dart';

void main() {
  group('PollOptions', () {
    test('defaults isSelected to false', () {
      final option = PollOptions(label: 'Yes', pollsCount: 0, id: 1);
      expect(option.isSelected, isFalse);
    });
  });

  group('PollFrameModel', () {
    test('defaults hasVoted and editablePoll to false', () {
      final model = PollFrameModel(
        totalPolls: 0,
        options: const [],
        title: const Text('Question'),
      );
      expect(model.hasVoted, isFalse);
      expect(model.editablePoll, isFalse);
    });

    test('is never ended/always active when endTime is null', () {
      final model = PollFrameModel(
        totalPolls: 0,
        options: const [],
        title: const Text('Question'),
      );
      expect(model.hasEnded, isFalse);
      expect(model.isActive, isTrue);
    });

    test('hasEnded/isActive reflect a past endTime', () {
      final model = PollFrameModel(
        totalPolls: 0,
        options: const [],
        title: const Text('Question'),
        endTime: DateTime.now().toUtc().subtract(const Duration(days: 1)),
      );
      expect(model.hasEnded, isTrue);
      expect(model.isActive, isFalse);
    });
  });
}
