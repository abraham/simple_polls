import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
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
  const SimplePollsBrightnessPreview(
    this.name, {
    this.textScaleFactor,
    this.size = const Size(420, 500),
  });

  final String name;
  final double? textScaleFactor;
  final Size size;

  @override
  List<Preview> get previews => <Preview>[
    Preview(
      name: '$name (Light)',
      group: 'SimplePolls',
      brightness: Brightness.light,
      size: size,
      textScaleFactor: textScaleFactor,
      theme: simplePollsPreviewTheme,
    ),
    Preview(
      name: '$name (Dark)',
      group: 'SimplePolls',
      brightness: Brightness.dark,
      size: size,
      textScaleFactor: textScaleFactor,
      theme: simplePollsPreviewTheme,
    ),
  ];
}

Poll<int> _buildPoll({
  bool allowsMultipleAnswers = false,
  bool hasEnded = false,
}) {
  return Poll<int>(
    title: 'What is your favorite flavor?',
    endsAt: DateTime.now().toUtc().add(
      hasEnded ? const Duration(days: -1) : const Duration(days: 10),
    ),
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
  const _InteractivePollPreview({
    required this.initialPoll,
    this.initialVote,
    this.style = const PollStyle(),
  });

  final Poll<int> initialPoll;
  final PollVote<int>? initialVote;
  final PollStyle style;

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
      style: widget.style,
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

@SimplePollsBrightnessPreview('Ended poll')
WidgetBuilder simplePollEndedPreview() {
  return (context) => _InteractivePollPreview(
    initialPoll: _buildPoll(hasEnded: true),
    initialVote: const PollVote<int>({2}),
  );
}

@SimplePollsBrightnessPreview(
  'Results poll at 200% text',
  textScaleFactor: 2,
  size: Size(420, 900),
)
WidgetBuilder simplePollLargeTextPreview() {
  return (context) => _InteractivePollPreview(
    initialPoll: _buildPoll(),
    initialVote: const PollVote<int>({3}),
  );
}

@SimplePollsBrightnessPreview('Material 3 poll')
WidgetBuilder simplePollMaterial3Preview() {
  return (context) => _InteractivePollPreview(
    initialPoll: _buildPoll(allowsMultipleAnswers: true),
    style: const PollStyle(variant: StyleVariant.material3),
  );
}

@SimplePollsBrightnessPreview('Material 3 results')
WidgetBuilder simplePollMaterial3ResultsPreview() {
  return (context) => _InteractivePollPreview(
    initialPoll: _buildPoll(),
    initialVote: const PollVote<int>({3}),
    style: const PollStyle(variant: StyleVariant.material3),
  );
}
