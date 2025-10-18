import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dayline_planner/models/task_model.dart';
import 'package:dayline_planner/providers/task_provider.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel? task; // null → create mode

  const EditTaskScreen({super.key, this.task});

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

  final Color primaryColor = const Color.fromRGBO(90, 130, 130, 1);
  final Color backgroundColor = const Color.fromRGBO(247, 240, 22, 1);

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
    _date = t?.date ?? DateTime.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
      weekdays: _isRecurring && _recurrenceType == RecurrenceType.specificWeekDays
          ? _weekdays
          : [],
      date: _date,
      createdAt: widget.task?.createdAt,
    );

    if (widget.task == null) {
      provider.addTask(updatedTask);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task created!')));
    } else {
      provider.updateTask(updatedTask);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task updated!')));
    }

    Navigator.pop(context);
  }

  void _deleteTask() {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    if (widget.task != null) {
      provider.deleteTask(widget.task!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    final dateStr = DateFormat('yMMMd').format(_date);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : 'Create Task'),
        backgroundColor: primaryColor,
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
              _buildLabel('Title'),
              TextFormField(
                initialValue: _title,
                decoration: _inputDecoration('Enter task title'),
                validator: (v) => v == null || v.isEmpty ? 'Enter a title' : null,
                onChanged: (v) => _title = v,
              ),
              const SizedBox(height: 16),
              _buildLabel('Description'),
              TextFormField(
                initialValue: _description,
                maxLines: 3,
                decoration: _inputDecoration('Enter description'),
                onChanged: (v) => _description = v,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Recurring task'),
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
                activeColor: primaryColor,
              ),
              if (!_isRecurring) ...[
                _buildLabel('Date'),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(dateStr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                  ),
                ),
              ],
              if (_isRecurring) ...[
                _buildLabel('Recurrence'),
                DropdownButtonFormField<RecurrenceType>(
                  value: _recurrenceType,
                  items: RecurrenceType.values
                      .where((r) => r != RecurrenceType.none)
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.name),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _recurrenceType = val!),
                  decoration: _inputDecoration('Recurrence type'),
                ),
                if (_recurrenceType == RecurrenceType.specificWeekDays) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (i) {
                      final dayNum = i + 1;
                      final dayName = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][i];
                      final selected = _weekdays.contains(dayNum);
                      return FilterChip(
                        label: Text(dayName),
                        selected: selected,
                        onSelected: (_) => _toggleWeekday(dayNum),
                        selectedColor: primaryColor.withOpacity(0.2),
                        checkmarkColor: primaryColor,
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
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
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

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      );

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
        ),
      );
}
