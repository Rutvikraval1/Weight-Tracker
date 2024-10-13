import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weight_tracker_app/screen/homeScreen.dart';
import 'package:weight_tracker_app/service/database_helper.dart';
import 'package:weight_tracker_app/service/notification_service.dart';
import 'bloc/tracker/tracker_bloc.dart';
import 'bloc/tracker/tracker_event.dart';
import 'package:timezone/data/latest.dart' as tz;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.initNotification();
  tz.initializeTimeZones();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weight Tracker',
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => TrackerBloc(DatabaseHelper.instance, NotificationService())..add(LoadUserData()),
        child: HomeScreen(),
      ),
    );
  }
}


