// Labels and time formatting for `SimplePoll`. Use a built-in locale or
// construct one to override any label or add a language.
import 'package:flutter/foundation.dart';
import 'package:timeago/timeago.dart' as timeago;

typedef PollTimeRemainingFormatter = String Function(DateTime endsAt);

@immutable
class PollLocale {
  /// The `timeago` locale used to format the time left, e.g. `'it'`.
  final String languageCode;
  final String votesLabel;
  final String endsLabel;
  final String pollingEndedLabel;
  final String undoLabel;
  final String voteButtonLabel;

  /// Screen reader label for the user's own pick in the results.
  final String selectedLabel;

  /// Screen reader label for the option(s) with the most votes.
  final String leadingLabel;

  /// Replaces the `timeago` formatting of the time left.
  final PollTimeRemainingFormatter? timeRemainingFormatter;

  const PollLocale({
    required this.languageCode,
    required this.votesLabel,
    required this.endsLabel,
    required this.pollingEndedLabel,
    required this.undoLabel,
    required this.voteButtonLabel,
    this.selectedLabel = 'Selected',
    this.leadingLabel = 'Leading',
    this.timeRemainingFormatter,
  });

  static const en = PollLocale(
    languageCode: 'en',
    votesLabel: 'votes',
    endsLabel: 'Ends',
    pollingEndedLabel: 'Polling Ended',
    undoLabel: 'undo',
    voteButtonLabel: 'Vote',
  );

  static const it = PollLocale(
    languageCode: 'it',
    votesLabel: 'voti',
    endsLabel: 'Finisce',
    pollingEndedLabel: 'Sondaggio terminato',
    undoLabel: 'annulla',
    voteButtonLabel: 'Vota',
    selectedLabel: 'Selezionato',
    leadingLabel: 'In testa',
  );

  static const fr = PollLocale(
    languageCode: 'fr',
    votesLabel: 'votes',
    endsLabel: 'Prend fin',
    pollingEndedLabel: 'Sondage terminé',
    undoLabel: 'annuler',
    voteButtonLabel: 'Voter',
    selectedLabel: 'Sélectionné',
    leadingLabel: 'En tête',
  );

  static const es = PollLocale(
    languageCode: 'es',
    votesLabel: 'votos',
    endsLabel: 'Termina',
    pollingEndedLabel: 'Encuesta finalizada',
    undoLabel: 'deshacer',
    voteButtonLabel: 'Votar',
    selectedLabel: 'Seleccionado',
    leadingLabel: 'A la cabeza',
  );

  static const de = PollLocale(
    languageCode: 'de',
    votesLabel: 'Stimmen',
    endsLabel: 'Endet',
    pollingEndedLabel: 'Umfrage beendet',
    undoLabel: 'rückgängig machen',
    voteButtonLabel: 'Abstimmen',
    selectedLabel: 'Ausgewählt',
    leadingLabel: 'Führend',
  );

  String formatTimeRemaining(DateTime endsAt) {
    if (timeRemainingFormatter case final format?) return format(endsAt);
    _registerTimeagoLocales();
    return timeago.format(endsAt, locale: languageCode, allowFromNow: true);
  }
}

var _timeagoLocalesRegistered = false;

/// `timeago` only ships English messages registered by default.
void _registerTimeagoLocales() {
  if (_timeagoLocalesRegistered) return;
  _timeagoLocalesRegistered = true;
  timeago.setLocaleMessages('it', timeago.ItMessages());
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('es', timeago.EsMessages());
  timeago.setLocaleMessages('de', timeago.DeMessages());
}
