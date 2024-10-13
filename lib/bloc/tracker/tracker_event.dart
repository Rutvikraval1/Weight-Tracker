
import 'package:flutter/material.dart';

abstract class TrackerEvent {}

class LoadUserData extends TrackerEvent {}

class SaveUserData extends TrackerEvent {
  final String name;
  final TimeOfDay notificationTime;

  SaveUserData(this.name, this.notificationTime);
}

class RecordWeight extends TrackerEvent {
  final double weight;
  final TimeOfDay notificationTime;
  final String name;

  RecordWeight(this.weight,this.notificationTime,this.name);
}

class ChangeNotificationTime extends TrackerEvent {
  final TimeOfDay newTime;

  ChangeNotificationTime(this.newTime);
}
