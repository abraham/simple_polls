## 2.0.0

* BREAKING: API redesign
* `SimplePollsWidget` -> `SimplePoll<T>`, `PollFrameModel` -> `Poll<T>`,
`PollOptions` -> `PollOption<T>` (`id` is now generic instead of `dynamic`).
* The widget no longer mutates its model. It is a fully controlled widget:
it takes an immutable `Poll<T>` plus a `PollVote<T>?`, and reports intended
changes through a single `onVoteChanged` callback instead of the old
`onSelection`/`onMultiSelection`/`onReset` trio. `onVoteChanged` returns
`FutureOr<void>` so a network call can be awaited before the vote is
reflected, and a new `onVoteError` callback reports failures.
* Added `Poll.withVoteApplied(...)` to compute updated vote counts after a
vote changes.
* `margin`/`padding`/`decoration`/`optionsStyle`/`optionsBorderShape`
constructor parameters replaced by a single `style: PollStyle(...)`.
* `languageCode` string + hardcoded translation maps replaced by a
pluggable `locale: PollLocale` (built-in `PollLocale.en/.it/.fr/.es/.de`).
* `PollFrameModel.title` is now a `String` instead of a `Widget` (use the
new `titleBuilder` for custom rendering).
* Renamed internal widgets: `PollButtonsWidget` -> `PollOptionButton`,
`PollResultsWidget` -> `PollOptionResult`, `PollStatusWidget` ->
`PollStatusBar`, `CustomLinearProgressBar` -> `PollProgressBar`.

## 1.0.0

* Initial release.

## 1.0.1

* Minor changes.

## 1.0.2

* Minor changes on readme file, attached screenshots.

## 1.0.3

* Added a functionality to hide undo button on timer expire and added more documentation.

## 1.0.4

* Corrected and added more documentation.

## 1.0.5

* Now onselection method of SimplePollsWidget will return 2 objects as show below. This change was done because a loop was needed to get the selectd option now it just returns the options which registered a tap.
New:
onSelection: (PollFrameModel model, PollOptions selectedOptionModel) {
            print('Now total polls are : ' + model.totalPolls.toString());
            print('Selected option has label : ' + selectedOptionModel.label);
},

Old:
onSelection: (PollFrameModel model) {
        print('Now total polls are : ' + model.totalPolls.toString());
},

## 1.0.6

* Now user can set custom border shape of option and can pass a function onreset which will be called when poll is editable.

## 1.0.7

* Minor optimizations.

## 1.0.8

* Minor optimizations.
