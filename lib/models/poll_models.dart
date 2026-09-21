// This file contains 2 models which will be used to create polls widget.
import 'package:flutter/material.dart';

class PollFrameModel {
  /// This model is the main data model to be passed to polls widget.
  int totalPolls;
  final Widget title;
  final List<PollOptions> options;
  final DateTime? endTime;
  bool hasVoted;
  final bool editablePoll;

  /// If true, users can select more than one option before submitting their vote.
  final bool allowMultipleSelection;

  PollFrameModel({
    required this.totalPolls,
    required this.options,
    this.hasVoted = false,
    required this.title,
    this.endTime,
    this.editablePoll = false,
    this.allowMultipleSelection = false,
  });

  /// True only when [endTime] is set and already in the past. A poll with no [endTime] never ends.
  bool get hasEnded =>
      endTime != null && endTime!.toUtc().isBefore(DateTime.now().toUtc());

  /// True when the poll can still accept votes: either it has no [endTime], or [endTime] is still in the future.
  bool get isActive => !hasEnded;
}

class PollOptions {
  /// This model will have properties to configure options of the poll.
  final String label;
  final dynamic id;
  int pollsCount;
  bool isSelected;

  PollOptions({
    required this.label,
    required this.pollsCount,
    required this.id,
    this.isSelected = false,
  });
}
