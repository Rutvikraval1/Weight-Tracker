import 'package:flutter/material.dart';

class TrackerState {
  final String? userName;
  final TimeOfDay? notificationTime;
  final List<Map<String, dynamic>> weightEntries;
  final bool isFirstRun;

  TrackerState({
    required this.userName,
    required this.notificationTime,
    required this.weightEntries,
    required this.isFirstRun,
  });

  TrackerState copyWith({
    String? userName,
    TimeOfDay? notificationTime,
    List<Map<String, dynamic>>? weightEntries,
    bool? isFirstRun,
  }) {
    return TrackerState(
      userName: userName ?? this.userName,
      notificationTime: notificationTime ?? this.notificationTime,
      weightEntries: weightEntries ?? this.weightEntries,
      isFirstRun: isFirstRun ?? this.isFirstRun,
    );
  }
}
