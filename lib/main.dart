import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:dayline_planner/providers/task_provider.dart';
import 'package:dayline_planner/screens/planner_screen.dart';
import 'package:dayline_planner/screens/create_task_screen.dart';
import 'package:dayline_planner/screens/tasks_screen.dart';
import 'package:dayline_planner/screens/profile_screen.dart';
import 'package:dayline_planner/screens/splash_screen.dart';
import 'package:dayline_planner/services/db_service.dart';
import 'package:dayline_planner/providers/theme_provider.dart';
import 'package:dayline_planner/providers/section_provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI bindings for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }

  await DBService.instance.init();
  runApp(const DaylineApp());
}

class DaylineApp extends StatelessWidget {
  const DaylineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadAll()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SectionProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Dayline Planner',
          theme: themeProvider.currentTheme,
          initialRoute: '/',
          routes: {
            '/': (_) => const SplashScreen(),
            PlannerScreen.routeName: (_) => const PlannerScreen(),
            CreateTaskScreen.routeName: (_) => const CreateTaskScreen(),
            TasksScreen.routeName: (_) => const TasksScreen(),
            ProfileScreen.routeName: (_) => const ProfileScreen(),
          },
        ),
      ),
    );
  }
}
