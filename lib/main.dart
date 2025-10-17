import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayline_planner/providers/task_provider.dart';
import 'package:dayline_planner/screens/planner_screen.dart';
import 'package:dayline_planner/screens/create_task_screen.dart';
import 'package:dayline_planner/screens/tasks_screen.dart';
import 'package:dayline_planner/screens/profile_screen.dart';
import 'package:dayline_planner/services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBService.instance.init();
  runApp(const DaylineApp());
}

class DaylineApp extends StatelessWidget {
  const DaylineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider()..loadAll(),
      child: MaterialApp(
        title: 'Dayline Planner',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const PlannerScreen(),
          CreateTaskScreen.routeName: (_) => const CreateTaskScreen(),
          TasksScreen.routeName: (_) => const TasksScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
        },
      ),
    );
  }
}
