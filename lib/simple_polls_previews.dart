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

PollFrameModel _buildPollModel(
  BuildContext context, {
  required bool hasVoted,
  bool editablePoll = true,
}) {
  return PollFrameModel(
    title: Text(
      'What is your favorite flavor?',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
    totalPolls: 100,
    endTime: DateTime.now().toUtc().add(const Duration(days: 10)),
    hasVoted: hasVoted,
    editablePoll: editablePoll,
    options: <PollOptions>[
      PollOptions(label: 'Vanilla', pollsCount: 40, isSelected: false, id: 1),
      PollOptions(label: 'Chocolate', pollsCount: 25, isSelected: false, id: 2),
      PollOptions(label: 'Strawberry', pollsCount: 35, isSelected: true, id: 3),
    ],
  );
}

@SimplePollsBrightnessPreview('Unvoted poll')
WidgetBuilder simplePollUnvotedPreview() {
  return (context) {
    return SimplePollsWidget(
      languageCode: 'en',
      optionsBorderShape: const StadiumBorder(),
      model: _buildPollModel(context, hasVoted: false),
      onSelection: (_, _) {},
      onReset: (_) {},
    );
  };
}

@SimplePollsBrightnessPreview('Results poll')
WidgetBuilder simplePollResultsPreview() {
  return (context) {
    return SimplePollsWidget(
      languageCode: 'en',
      optionsBorderShape: const StadiumBorder(),
      model: _buildPollModel(context, hasVoted: true),
      onSelection: (_, _) {},
      onReset: (_) {},
    );
  };
}
