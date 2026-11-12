import 'package:flutter_test/flutter_test.dart';
import 'package:simple_polls/simple_polls.dart';

void main() {
  final endsAt = DateTime.now().add(const Duration(days: 10, minutes: 1));

  test('built-in locales format the time left in their language', () {
    final formatted = {
      for (final locale in [
        PollLocale.en,
        PollLocale.it,
        PollLocale.fr,
        PollLocale.es,
        PollLocale.de,
      ])
        locale.languageCode: locale.formatTimeRemaining(endsAt),
    };

    expect(formatted['en'], '10 days from now');
    expect(formatted.values.toSet(), hasLength(5));
  });

  test('timeRemainingFormatter replaces timeago', () {
    final locale = PollLocale(
      languageCode: 'en',
      votesLabel: 'votes',
      endsLabel: 'Ends',
      pollingEndedLabel: 'Ended',
      undoLabel: 'undo',
      voteButtonLabel: 'Vote',
      timeRemainingFormatter: (endsAt) => 'soon',
    );

    expect(locale.formatTimeRemaining(endsAt), 'soon');
  });
}
