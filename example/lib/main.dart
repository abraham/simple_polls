// This file contains the example showing how to use the poll widget in your application.
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:simple_polls/simple_polls.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.indigo,
        primarySwatch: Colors.indigo,
      ),
      debugShowCheckedModeBanner: false,
      home: const ExampleApp(),
    );
  }
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  /// The poll's server-truth data. In a real app this would come from a backend.
  var _poll = Poll<int>(
    title: 'Questo è il titolo del sondaggio. Questo è il titolo del sondaggio. Questo è il titolo del sondaggio.',

    /// Poll end time.
    endsAt: DateTime.now().toUtc().add(const Duration(days: 10)),

    /// If poll is editable then an undo button will appear once voted.
    isEditable: true,
    options: const <PollOption<int>>[
      /// Configure options here. [PollOption.id] can be any type, not just int.
      PollOption(id: 1, label: 'opzione 1', voteCount: 40),
      PollOption(id: 2, label: 'opzione 2', voteCount: 25),
      PollOption(id: 3, label: 'opzione 3', voteCount: 35),
    ],
  );

  /// The vote cast for [_poll], or null if the user hasn't voted yet.
  PollVote<int>? _vote;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Polls Widget',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
        centerTitle: true,
        toolbarHeight: 40,
      ),
      body: SimplePoll<int>(
        poll: _poll,
        vote: _vote,

        /// Called whenever the user casts, changes, or clears (undo) their vote.
        /// It returns `FutureOr<void>` so a network call can be awaited here
        /// before the widget reflects the new vote.
        onVoteChanged: (newVote) {
          log('Selected option ids: ${newVote?.selectedOptionIds}');
          setState(() {
            _poll = _poll.withVoteApplied(
              previousVote: _vote,
              newVote: newVote,
            );
            _vote = newVote;
          });
        },
        onVoteError: (error, stackTrace) => log('Vote failed: $error'),

        /// A single object controls margin/padding/decoration/text style/shape.
        style: PollStyle(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(15),
          optionTextStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).primaryColor,
          ),
        ),

        /// Built-in locales: [PollLocale.en] (default), [PollLocale.it],
        /// [PollLocale.fr], [PollLocale.es], [PollLocale.de]. Construct a
        /// custom [PollLocale] to add another language or override any label.
        locale: PollLocale.it,
      ),
    );
  }
}
