import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:dayline_planner/models/task_model.dart';
import 'package:dayline_planner/providers/task_provider.dart';

class CreateTaskScreen extends StatefulWidget {
  static const routeName = '/create';
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();

  String _section = 'morning';
  bool _isRecurring = false;
  RecurrenceType _rType = RecurrenceType.daily;
  int _everyNDays = 2;
  List<bool> _weekdaySelected = List.generate(7, (_) => false);
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (args['defaultDate'] != null)
        _selectedDate = args['defaultDate'] as DateTime;
      if (args['defaultSection'] != null)
        _section = args['defaultSection'] as String;
    }
  }

  Widget _weekdayRow() {
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Wrap(
      spacing: 6,
      children: List.generate(7, (i) {
        return ChoiceChip(
          label: Text(labels[i]),
          selected: _weekdaySelected[i],
          onSelected: (s) {
            setState(() {
              _weekdaySelected[i] = !(_weekdaySelected[i]);
            });
          },
        );
      }),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final weekdays = <int>[];
    for (var i = 0; i < 7; i++) {
      if (_weekdaySelected[i]) weekdays.add(i + 1); // Mon=1
    }
    final t = TaskModel(
      title: _title.text.trim(),
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      section: _section,
      isRecurring: _isRecurring,
      recurrenceType: _isRecurring ? _rType : RecurrenceType.none,
      everyNDays: _everyNDays,
      weekdays: weekdays,
      date: _selectedDate,
    );
    final provider = Provider.of<TaskProvider>(context, listen: false);
    await provider.addTask(t);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _section,
                items: [
                  DropdownMenuItem(value: 'wake', child: Text('Wake (6-8)')),
                  DropdownMenuItem(
                      value: 'morning', child: Text('Morning (8-12)')),
                  DropdownMenuItem(value: 'noon', child: Text('Noon (12-13)')),
                  DropdownMenuItem(
                      value: 'afternoon', child: Text('Afternoon (13-17)')),
                  DropdownMenuItem(
                      value: 'evening', child: Text('Evening (17-22)')),
                ],
                onChanged: (v) => setState(() => _section = v!),
                decoration: const InputDecoration(labelText: 'Section'),
              ),
              SwitchListTile(
                title: const Text('Recurring?'),
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
              ),
              if (_isRecurring) ...[
                DropdownButtonFormField<RecurrenceType>(
                  value: _rType,
                  decoration:
                      const InputDecoration(labelText: 'Recurrence type'),
                  items: RecurrenceType.values.map((rt) {
                    return DropdownMenuItem(
                        value: rt, child: Text(rt.toString().split('.').last));
                  }).toList(),
                  onChanged: (v) => setState(() {
                    _rType = v!;
                  }),
                ),
                if (_rType == RecurrenceType.everyNDays)
                  TextFormField(
                    initialValue: '2',
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Every N days'),
                    onChanged: (v) => _everyNDays = int.tryParse(v) ?? 2,
                  ),
                if (_rType == RecurrenceType.specificWeekDays)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Weekdays'),
                        const SizedBox(height: 6),
                        _weekdayRow(),
                      ],
                    ),
                  ),
              ] else
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null)
                        setState(() => _selectedDate = picked);
                    },
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
