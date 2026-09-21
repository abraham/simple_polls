import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:simple_polls/simple_polls.dart';

base class SimplePollsPreviewThemeData extends PreviewThemeData {
  const SimplePollsPreviewThemeData({this.light, this.dark});

  final ThemeData? light;
  final ThemeData? dark;

  @override
  Widget apply(BuildContext context, Widget child) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final theme = brightness == Brightness.light ? light : dark;
    if (theme != null) {
      return Theme(data: theme, child: child);
    }
    return child;
  }
}

PreviewThemeData simplePollsPreviewTheme() {
  return SimplePollsPreviewThemeData(
    light: ThemeData.light(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
      ),
    ),
    dark: ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
      ),
    ),
  );
}

base class SimplePollsBrightnessPreview extends MultiPreview {
  const SimplePollsBrightnessPreview(this.name);

  final String name;

  @override
  List<Preview> get previews => <Preview>[
    Preview(
      name: '$name (Light)',
      group: 'SimplePolls',
      brightness: Brightness.light,
      size: const Size(420, 500),
      theme: simplePollsPreviewTheme,
    ),
    Preview(
      name: '$name (Dark)',
      group: 'SimplePolls',
      brightness: Brightness.dark,
      size: const Size(420, 500),
      theme: simplePollsPreviewTheme,
    ),
  ];
}

Poll<int> _buildPoll({bool allowsMultipleAnswers = false}) {
  return Poll<int>(
    title: 'What is your favorite flavor?',
    endsAt: DateTime.now().toUtc().add(const Duration(days: 10)),
    isEditable: true,
    allowsMultipleAnswers: allowsMultipleAnswers,
    options: const <PollOption<int>>[
      PollOption(id: 1, label: 'Vanilla', voteCount: 40),
      PollOption(id: 2, label: 'Chocolate', voteCount: 25),
      PollOption(id: 3, label: 'Strawberry', voteCount: 35),
    ],
  );
}

/// Since [SimplePoll] is a controlled widget, the preview needs its own
/// state holder to actually reflect a tapped option as a cast vote.
class _InteractivePollPreview extends StatefulWidget {
  const _InteractivePollPreview({required this.initialPoll, this.initialVote});

  final Poll<int> initialPoll;
  final PollVote<int>? initialVote;

  @override
  State<_InteractivePollPreview> createState() =>
      _InteractivePollPreviewState();
}

class _InteractivePollPreviewState extends State<_InteractivePollPreview> {
  late Poll<int> _poll = widget.initialPoll;
  late PollVote<int>? _vote = widget.initialVote;

  @override
  Widget build(BuildContext context) {
    return SimplePoll<int>(
      poll: _poll,
      vote: _vote,
      onVoteChanged: (newVote) {
        setState(() {
          _poll = _poll.withVoteApplied(previousVote: _vote, newVote: newVote);
          _vote = newVote;
        });
      },
    );
  }
}

@SimplePollsBrightnessPreview('Unvoted poll')
WidgetBuilder simplePollUnvotedPreview() {
  return (context) => _InteractivePollPreview(initialPoll: _buildPoll());
}

@SimplePollsBrightnessPreview('Results poll')
WidgetBuilder simplePollResultsPreview() {
  return (context) => _InteractivePollPreview(
    initialPoll: _buildPoll(),
    initialVote: const PollVote<int>({3}),
  );
}

@SimplePollsBrightnessPreview('Multi-select poll')
WidgetBuilder simplePollMultiSelectPreview() {
  return (context) => _InteractivePollPreview(
    initialPoll: _buildPoll(allowsMultipleAnswers: true),
  );
}
