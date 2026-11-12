// Pluggable text/formatting strategy for `SimplePoll`, replacing the hardcoded
// translation maps from 1.x. Provide a built-in `PollLocale` or construct a
// custom one to override any label or add a language.
import 'package:flutter/foundation.dart';
import 'package:timeago/timeago.dart' as timeago;

typedef PollTimeRemainingFormatter = String Function(DateTime endsAt);

@immutable
class PollLocale {
  final String votesLabel;
  final String endsLabel;
  final String pollingEndedLabel;
  final String undoLabel;
  final String voteButtonLabel;

  /// Screen reader label for the user's own pick in the results.
  final String selectedLabel;

  /// Screen reader label for the option(s) with the most votes.
  final String leadingLabel;
  final PollTimeRemainingFormatter formatTimeRemaining;

  const PollLocale({
    required this.votesLabel,
    required this.endsLabel,
    required this.pollingEndedLabel,
    required this.undoLabel,
    required this.voteButtonLabel,
    this.selectedLabel = 'Selected',
    this.leadingLabel = 'Leading',
    required this.formatTimeRemaining,
  });

  static const en = PollLocale(
    votesLabel: 'votes',
    endsLabel: 'Ends',
    pollingEndedLabel: 'Polling Ended',
    undoLabel: 'undo',
    voteButtonLabel: 'Vote',
    formatTimeRemaining: _formatTimeRemainingEn,
  );

  static const it = PollLocale(
    votesLabel: 'sondaggi',
    endsLabel: 'Finisce',
    pollingEndedLabel: 'Sondaggio terminato',
    undoLabel: 'disfare',
    voteButtonLabel: 'Vota',
    selectedLabel: 'Selezionato',
    leadingLabel: 'In testa',
    formatTimeRemaining: _formatTimeRemainingIt,
  );

  static const fr = PollLocale(
    votesLabel: 'les sondages',
    endsLabel: 'Prend fin',
    pollingEndedLabel: 'Sondage terminé',
    undoLabel: 'annuler',
    voteButtonLabel: 'Voter',
    selectedLabel: 'Sélectionné',
    leadingLabel: 'En tête',
    formatTimeRemaining: _formatTimeRemainingFr,
  );

  static const es = PollLocale(
    votesLabel: 'votos',
    endsLabel: 'Termina',
    pollingEndedLabel: 'Encuesta finalizada',
    undoLabel: 'deshacer',
    voteButtonLabel: 'Votar',
    selectedLabel: 'Seleccionado',
    leadingLabel: 'A la cabeza',
    formatTimeRemaining: _formatTimeRemainingEs,
  );

  static const de = PollLocale(
    votesLabel: 'Stimmen',
    endsLabel: 'Endet',
    pollingEndedLabel: 'Umfrage beendet',
    undoLabel: 'rückgängig machen',
    voteButtonLabel: 'Abstimmen',
    selectedLabel: 'Ausgewählt',
    leadingLabel: 'Führend',
    formatTimeRemaining: _formatTimeRemainingDe,
  );
}

/// Locale codes whose `timeago` messages have already been registered.
final Set<String> _registeredTimeagoLocales = {'en'};

void _ensureTimeagoLocaleRegistered(String localeCode) {
  if (!_registeredTimeagoLocales.add(localeCode)) return;
  switch (localeCode) {
    case 'it':
      timeago.setLocaleMessages('it', timeago.ItMessages());
    case 'fr':
      timeago.setLocaleMessages('fr', timeago.FrMessages());
    case 'es':
      timeago.setLocaleMessages('es', timeago.EsMessages());
    case 'de':
      timeago.setLocaleMessages('de', timeago.DeMessages());
  }
}

String _formatTimeRemaining(DateTime endsAt, String localeCode) {
  _ensureTimeagoLocaleRegistered(localeCode);
  return timeago.format(endsAt, locale: localeCode, allowFromNow: true);
}

String _formatTimeRemainingEn(DateTime endsAt) =>
    _formatTimeRemaining(endsAt, 'en');
String _formatTimeRemainingIt(DateTime endsAt) =>
    _formatTimeRemaining(endsAt, 'it');
String _formatTimeRemainingFr(DateTime endsAt) =>
    _formatTimeRemaining(endsAt, 'fr');
String _formatTimeRemainingEs(DateTime endsAt) =>
    _formatTimeRemaining(endsAt, 'es');
String _formatTimeRemainingDe(DateTime endsAt) =>
    _formatTimeRemaining(endsAt, 'de');
