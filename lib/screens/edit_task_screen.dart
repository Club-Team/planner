import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dayline_planner/models/task_model.dart';
import 'package:dayline_planner/providers/task_provider.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel? task; // null → create mode
  final DateTime? initialDate; // 👈 add this

  const EditTaskScreen({super.key, this.task, this.initialDate});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _description;
  late bool _isRecurring;
  late RecurrenceType _recurrenceType;
  late int _everyNDays;
  late List<int> _weekdays;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = t?.title ?? '';
    _description = t?.description ?? '';
    _isRecurring = t?.isRecurring ?? false;
    _recurrenceType = t?.recurrenceType ?? RecurrenceType.none;
    _everyNDays = t?.everyNDays ?? 1;
    _weekdays = List<int>.from(t?.weekdays ?? []);
    _date = t?.date ?? widget.initialDate ?? DateTime.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        // make date picker also follow theme
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _toggleWeekday(int day) {
    setState(() {
      if (_weekdays.contains(day)) {
        _weekdays.remove(day);
      } else {
        _weekdays.add(day);
      }
    });
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<TaskProvider>(context, listen: false);

    final updatedTask = TaskModel(
      id: widget.task?.id,
      title: _title.trim(),
      description: _description.trim(),
      section: widget.task?.section ?? 'morning',
      isRecurring: _isRecurring,
      recurrenceType: _isRecurring ? _recurrenceType : RecurrenceType.none,
      everyNDays: _everyNDays,
      weekdays:
          _isRecurring && _recurrenceType == RecurrenceType.specificWeekDays
              ? _weekdays
              : [],
      date: _date,
      createdAt: widget.task?.createdAt,
    );

    if (widget.task == null) {
      provider.addTask(updatedTask);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Task created!')));
    } else {
      provider.updateTask(updatedTask);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Task updated!')));
    }

    Navigator.pop(context);
  }

  void _deleteTask() {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    if (widget.task != null) {
      provider.deleteTask(widget.task!);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Task deleted')));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isEdit = widget.task != null;
    final dateStr = DateFormat('yMMMd').format(_date);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : 'Create Task'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTask,
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Title', textTheme, colorScheme),
              TextFormField(
                initialValue: _title,
                decoration: _inputDecoration('Enter task title', theme),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter a title' : null,
                onChanged: (v) => _title = v,
              ),
              const SizedBox(height: 16),
              _buildLabel('Description', textTheme, colorScheme),
              TextFormField(
                initialValue: _description,
                maxLines: 3,
                decoration: _inputDecoration('Enter description', theme),
                onChanged: (v) => _description = v,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Recurring task'),
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
                activeColor: colorScheme.primary,
              ),
              if (!_isRecurring) ...[
                _buildLabel('Date', textTheme, colorScheme),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(dateStr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                  ),
                ),
              ],
              if (_isRecurring) ...[
                _buildLabel('Recurrence', textTheme, colorScheme),
                DropdownButtonFormField<RecurrenceType>(
                  value: _recurrenceType == RecurrenceType.none
                      ? null
                      : _recurrenceType,
                  hint: const Text('Select recurrence type'),
                  items: RecurrenceType.values
                      .where((r) => r != RecurrenceType.none)
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.name),
                          ))
                      .toList(),
                  onChanged: (val) => setState(
                      () => _recurrenceType = val ?? RecurrenceType.none),
                  decoration: _inputDecoration('Recurrence type', theme),
                ),
                if (_recurrenceType == RecurrenceType.specificWeekDays) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (i) {
                      final dayNum = i + 1;
                      final dayName =
                          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i];
                      final selected = _weekdays.contains(dayNum);
                      return FilterChip(
                        label: Text(dayName),
                        selected: selected,
                        onSelected: (_) => _toggleWeekday(dayNum),
                        selectedColor: colorScheme.primary.withOpacity(0.2),
                        checkmarkColor: colorScheme.primary,
                        labelStyle: TextStyle(
                          color: selected
                              ? colorScheme.primary
                              : textTheme.bodyMedium?.color,
                        ),
                      );
                    }),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(isEdit ? Icons.save : Icons.check),
                  label: Text(isEdit ? 'Save Changes' : 'Create Task'),
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: theme
                            .elevatedButtonTheme.style?.foregroundColor
                            ?.resolve({}) ??
                        Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, ThemeData theme) {
    final base = theme.inputDecorationTheme;
    return InputDecoration(
      labelText: label,
      border: base.border,
      focusedBorder: base.focusedBorder,
      enabledBorder: base.enabledBorder,
      filled: base.filled,
      fillColor: base.fillColor,
      contentPadding: base.contentPadding,
    );
  }

  Widget _buildLabel(
          String text, TextTheme textTheme, ColorScheme colorScheme) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      );
}
