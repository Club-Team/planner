import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayline_planner/providers/task_provider.dart';
import 'package:dayline_planner/screens/planner_screen.dart';
import 'package:dayline_planner/screens/create_task_screen.dart';
import 'package:dayline_planner/screens/tasks_screen.dart';
import 'package:dayline_planner/screens/profile_screen.dart';
import 'package:dayline_planner/screens/splash_screen.dart';
import 'package:dayline_planner/services/db_service.dart';
import 'package:dayline_planner/themes/light_theme.dart';

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
        debugShowCheckedModeBanner: false,
        title: 'Dayline Planner',
        theme: AppTheme.lightTheme, // use centralized theme
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          'PlannerScreen.routeName': (_) => const PlannerScreen(),
          CreateTaskScreen.routeName: (_) => const CreateTaskScreen(),
          TasksScreen.routeName: (_) => const TasksScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
        },
    ),
    );
  }
}
