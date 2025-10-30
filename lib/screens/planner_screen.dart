import 'dart:io';
import 'package:dayline_planner/widgets/day_content.dart';
import 'package:dayline_planner/widgets/day_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:dayline_planner/screens/edit_task_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlannerScreen extends StatefulWidget {
  static const routeName = '/planner';
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final int windowDays = 21;
  late int centerIndex;
  late int selectedDayIndex;
  String? _avatarPath;
  final ScrollController _scrollController = ScrollController();
  bool _fabVisible = true;

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('avatarPath');
    if (mounted) setState(() => _avatarPath = path);
  }

  @override
  void initState() {
    super.initState();
    centerIndex = windowDays ~/ 2;
    selectedDayIndex = centerIndex;
    _loadAvatar();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_fabVisible) setState(() => _fabVisible = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_fabVisible) setState(() => _fabVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime dateForIndex(int idx) =>
      DateTime.now().add(Duration(days: idx - centerIndex));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Profile',
          icon: _avatarPath != null && _avatarPath!.isNotEmpty
              ? CircleAvatar(
                  radius: 14,
                  backgroundImage: FileImage(File(_avatarPath!)),
                )
              : const Icon(Icons.person),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Tasks',
            onPressed: () => Navigator.pushNamed(context, '/tasks'),
          ),
        ],
        title: Text(
          'Dayline Planner',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: _fabVisible ? Offset.zero : const Offset(2, 0),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _fabVisible ? 1 : 0,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditTaskScreen(
                    initialDate: dateForIndex(selectedDayIndex)),
              ),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ),
      body: Column(
        children: [
          DaySelector(
            windowDays: windowDays,
            selectedIndex: selectedDayIndex,
            onSelected: (idx) => setState(() => selectedDayIndex = idx),
            dateForIndex: dateForIndex,
          ),
          Expanded(
            child: DayContent(
              date: dateForIndex(selectedDayIndex),
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }
}
