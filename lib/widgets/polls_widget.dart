// This file contains the main widget that will be used to build poll widget.
import 'dart:async';

import 'package:flutter/material.dart';

import 'poll_buttons.dart';
import '../models/poll_models.dart';
import '../translations/translations.dart';
import 'poll_results.dart';
import 'poll_status.dart';

class SimplePollsWidget extends StatefulWidget {
  /// This is the main poll widget , call this with appropriate parameters to create a poll widget.
  final PollFrameModel model;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Decoration? decoration;
  final Function(PollFrameModel frameModel, PollOptions option)? onSelection;

  /// Called when a multi-selection poll (see [PollFrameModel.allowMultipleSelection]) is submitted.
  final Function(PollFrameModel frameModel, List<PollOptions> selectedOptions)?
  onMultiSelection;
  final Function(PollFrameModel frameModel)? onReset;
  final String languageCode;
  final TextStyle? optionsStyle;
  final OutlinedBorder optionsBorderShape;
  const SimplePollsWidget({
    super.key,
    required this.model,
    this.margin,
    this.padding,
    this.decoration,
    this.onSelection,
    this.onMultiSelection,
    this.languageCode = 'en',
    this.optionsStyle,
    this.optionsBorderShape = const StadiumBorder(),
    this.onReset,
  });

  @override
  State<SimplePollsWidget> createState() => _SimplePollsWidgetState();
}

class _SimplePollsWidgetState extends State<SimplePollsWidget> {
  /// [refreshTimer] will have a duration equals to the difference of time now and time to end polling.
  Timer? refreshTimer;

  /// Timer function needs to be created here in order to executed only once.
  @override
  void initState() {
    super.initState();
    final endTime = widget.model.endTime;
    if (endTime != null && widget.model.isActive) {
      /// This will refresh the widget when the poll time expires, this timer will get cancel on dispose.
      refreshTimer = Timer(endTime.difference(DateTime.now().toUtc()), () {
        /// Reloads the widget when poll end time reaches so that results screen will be visible by default, even if user has not voted.
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    /// Check if the timer function is not null and cancel on dispose.
    if (refreshTimer != null) {
      refreshTimer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      /// If [widget.margin] is null apply default margin.
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 8),

      /// If [widget.padding] is null apply default margin.
      padding: widget.padding ?? const EdgeInsets.fromLTRB(15, 15, 15, 5),

      /// If [widget.decoration] is null apply default margin.
      decoration:
          widget.decoration ??
          BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            color: Theme.of(context).colorScheme.surface,
          ),
      child: Column(
        /// CrossAxisAlignment.stretch is used to stretch options buttons to full length.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.model.title,
          const SizedBox(height: 10),

          /// This list will generate all the necessary poll options.
          ...List.generate(widget.model.options.length, (index) {
            /// [percentage] will be used to show progress in the form of bar in results screen.
            /// Check for 0/0 is present to avoid exception.
            double percentage = widget.model.totalPolls == 0
                ? 0
                : widget.model.options[index].pollsCount /
                      widget.model.totalPolls;

            /// Check if the person has voted or poll has expired, if conditions are met the results screen will show up.
            final Widget optionWidget;
            if ((widget.model.hasVoted == true) || widget.model.hasEnded) {
              optionWidget = PollResultsWidget(
                percentage: percentage,
                optionModel: widget.model.options[index],
                optionsStyle: widget.optionsStyle,
              );
            } else if (widget.model.allowMultipleSelection) {
              /// In multi-select mode, tapping only toggles the option; the vote is submitted separately.
              optionWidget = PollButtonsWidget(
                optionModel: widget.model.options[index],
                optionsStyle: widget.optionsStyle,
                borderShape: widget.optionsBorderShape,
                showSelectionIndicator: true,
                onPressed: () {
                  if (widget.model.isActive) {
                    setState(() {
                      widget.model.options[index].isSelected =
                          !widget.model.options[index].isSelected;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Polling time expired.'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                    setState(() {});
                  }
                },
              );
            } else {
              /// If check fails the buttons will appear.
              optionWidget = PollButtonsWidget(
                optionModel: widget.model.options[index],
                optionsStyle: widget.optionsStyle,
                borderShape: widget.optionsBorderShape,
                onPressed: () {
                  /// Check if poll is still active, if active update the widget with user's response.
                  if (widget.model.isActive) {
                    setState(() {
                      widget.model.hasVoted = true;
                      widget.model.options[index].isSelected = true;
                      widget.model.totalPolls += 1;
                      widget.model.options[index].pollsCount += 1;
                      if (widget.onSelection != null) {
                        widget.onSelection!.call(
                          widget.model,
                          widget.model.options[index],
                        );
                      }
                    });
                  } else {
                    /// If poll expired show a snackbar and update the widget.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Polling time expired.'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                    setState(() {});
                  }
                },
              );
            }

            /// Adds a gap above every option except the first so buttons/results aren't flush against each other.
            return index == 0
                ? optionWidget
                : Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: optionWidget,
                  );
          }),
          const SizedBox(height: 5),

          /// For multi-select polls, show a submit button to cast the vote for all toggled options.
          if (widget.model.allowMultipleSelection &&
              widget.model.hasVoted != true &&
              widget.model.isActive)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: ElevatedButton(
                onPressed:
                    widget.model.options.any((option) => option.isSelected)
                    ? () {
                        setState(() {
                          final selectedOptions = widget.model.options
                              .where((option) => option.isSelected)
                              .toList();
                          widget.model.hasVoted = true;
                          widget.model.totalPolls += 1;
                          for (final option in selectedOptions) {
                            option.pollsCount += 1;
                          }
                          if (widget.onMultiSelection != null) {
                            widget.onMultiSelection!.call(
                              widget.model,
                              selectedOptions,
                            );
                          }
                        });
                      }
                    : null,
                child: Text(
                  voteButtonTranslation[widget.languageCode] ?? 'Vote',
                ),
              ),
            ),

          /// Following widget will show the status of total polls and poll timer, it has a undo button which will show up if poll is editable.
          PollStatusWidget(
            model: widget.model,
            languageCode: widget.languageCode,
            onUndo: () {
              setState(() {
                widget.model.hasVoted = false;
                widget.model.totalPolls = widget.model.totalPolls - 1;
                for (var item in widget.model.options) {
                  if (item.isSelected == true) {
                    item.isSelected = false;
                    item.pollsCount -= 1;
                  }
                }
                if (widget.onReset != null) {
                  widget.onReset!.call(widget.model);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
