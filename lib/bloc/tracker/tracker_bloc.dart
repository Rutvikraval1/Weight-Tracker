
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../service/database_helper.dart';
import '../../service/notification_service.dart';
import 'tracker_event.dart';
import 'tracker_state.dart';
import 'package:intl/intl.dart';

class TrackerBloc extends Bloc<TrackerEvent, TrackerState> {
  DatabaseHelper dbHelper ;
  NotificationService notificationService;

  TrackerBloc(this.dbHelper, this.notificationService)
      : super(TrackerState(userName: null, notificationTime: null, weightEntries: [], isFirstRun: true)) {
    on<LoadUserData>(_onLoadUserData);
    on<SaveUserData>(_onSaveUserData);
    on<RecordWeight>(_onRecordWeight);
    on<ChangeNotificationTime>(_onChangeNotificationTime);
  }

  Future<void> _onLoadUserData(LoadUserData event, Emitter<TrackerState> emit) async {
    var userData = await dbHelper.getUser();
    if (userData != null) {
      final timeParts = userData['notificationTime'].split(':');
      TimeOfDay notificationTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      var weightEntries = await dbHelper.getAllWeights();
      emit(state.copyWith(
        userName: userData['name'],
        notificationTime: notificationTime,
        weightEntries: weightEntries,
        isFirstRun: false,
      ));
    }
  }

  Future<void> _onSaveUserData(SaveUserData event, Emitter<TrackerState> emit) async {
    DateTime now = DateTime.now();
    await dbHelper.insertUser(event.name, '${event.notificationTime.hour}:${event.notificationTime.minute}');
    emit(state.copyWith(userName: event.name, notificationTime: event.notificationTime, isFirstRun: false));
  }

  Future<void> _onRecordWeight(RecordWeight event, Emitter<TrackerState> emit) async {
    DateTime now = DateTime.now();
    DateTime updatedTime = DateTime(
        now.year,
        now.month,
        now.day,
        event.notificationTime.hour,
        event.notificationTime.minute
    );
    String formattedDate = DateFormat('dd-MM-yyyy').format(updatedTime);
    await dbHelper.insertWeight(formattedDate, event.weight);
    var weightEntries = await dbHelper.getAllWeights();
    emit(state.copyWith(weightEntries: weightEntries));
    notificationService.scheduleDailyNotification(updatedTime,title:event.name ,body: "Weight : ${event.weight.toString()}");
  }

  Future<void> _onChangeNotificationTime(ChangeNotificationTime event, Emitter<TrackerState> emit) async {
    DateTime now = DateTime.now();
    await dbHelper.insertUser(state.userName!, '${event.newTime.hour}:${event.newTime.minute}');
    emit(state.copyWith(notificationTime: event.newTime));
    print("SaveUserData");
    DateTime updatedTime = DateTime(
        now.year, // Keep the current year
        now.month, // Keep the current month
        now.day, // Keep the current day
        event.newTime.hour, // Set the hour
        event.newTime.minute // Set the minute
    );
    notificationService.scheduleDailyNotification(updatedTime);
  }

}

