import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weight_tracker_app/service/database_helper.dart';
import 'package:weight_tracker_app/service/notification_service.dart';
import 'bloc/tracker/tracker_bloc.dart';
import 'bloc/tracker/tracker_event.dart';
import 'bloc/tracker/tracker_state.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.initNotification();
  // Initialize timezone data
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

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<TrackerBloc, TrackerState>(
          builder: (context, state) {
            return Text(state.userName == null ? 'Setup' : 'Weight Tracker');
          },
        ),
      ),
      body: BlocBuilder<TrackerBloc, TrackerState>(
        builder: (context, state) {
          return  WeightTrackerScreen();
        },
      ),
    );
  }
}

// class SetupScreen extends StatelessWidget {
//   final nameController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           TextField(
//             controller: nameController,
//             decoration: const InputDecoration(labelText: 'Enter your name'),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () async {
//               TimeOfDay? time = await showTimePicker(
//                 context: context,
//                 initialTime: const TimeOfDay(hour: 8, minute: 0),
//               );
//
//               if (time != null) {
//                 context.read<TrackerBloc>().add(SaveUserData(nameController.text, time));
//               }
//             },
//             child: const Text('Save and Set Notification'),
//           ),
//         ],
//       ),
//     );
//   }
// }

class WeightTrackerScreen extends StatelessWidget {
  final weightController = TextEditingController();
  final nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Enter your name'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter your weight'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 8, minute: 0),
            );
            if (time != null) {
              try{
                double weight = double.parse(weightController.text);
                context.read<TrackerBloc>().add(RecordWeight(weight,time,nameController.text));
                context.read<TrackerBloc>().add(SaveUserData(nameController.text, time));

                weightController.clear();
              }catch(e){
                print(e);
                ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                  content: Text(e.toString()),
                ));
              }

            }
          },
          child: const Text('Record Weight'),
        ),
        Expanded(
          child: BlocBuilder<TrackerBloc, TrackerState>(
            builder: (context, state) {
              return ListView.builder(
                itemCount: state.weightEntries.length,
                itemBuilder: (context, index) {
                  var entry = state.weightEntries[index];
                  return ListTile(
                    title: Text(entry['date']),
                    subtitle: Text('${entry['weight']} kg'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
