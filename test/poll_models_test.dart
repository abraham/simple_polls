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
  });
}
