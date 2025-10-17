import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateTodoItem extends StatefulWidget {
  final void Function(Map<String, dynamic> todo)? onCreate;

  const CreateTodoItem({super.key, this.onCreate});

  @override
  State<CreateTodoItem> createState() => _CreateTodoItemState();
}

class _CreateTodoItemState extends State<CreateTodoItem> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _description = '';
  bool _isRecurring = false;
  DateTime _dueDate = DateTime.now();

  String _recurrenceType = 'Everyday';
  final List<String> _selectedWeekdays = [];

  final List<String> _recurrenceOptions = [
    'Everyday',
    'Every other day',
    'Specific weekdays'
  ];

  final List<String> _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _toggleWeekday(String day) {
    setState(() {
      if (_selectedWeekdays.contains(day)) {
        _selectedWeekdays.remove(day);
      } else {
        _selectedWeekdays.add(day);
      }
    });
  }

  void _createTodo() {
    if (!_formKey.currentState!.validate()) return;
    if (_isRecurring &&
        _recurrenceType == 'Specific weekdays' &&
        _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one weekday')),
      );
      return;
    }

    final todo = {
      'title': _title.trim(),
      'description': _description.trim(),
      'isRecurring': _isRecurring,
      'dueDate': !_isRecurring ? _dueDate.toIso8601String() : null,
      'recurrenceType': _isRecurring ? _recurrenceType : null,
      'weekdays':
          _isRecurring && _recurrenceType == 'Specific weekdays' ? _selectedWeekdays : [],
    };

    widget.onCreate?.call(todo);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('To-do created!')),
    );
    _formKey.currentState!.reset();
    setState(() {
      _isRecurring = false;
      _selectedWeekdays.clear();
      _dueDate = DateTime.now();
      _recurrenceType = 'Everyday';
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yMMMd').format(_dueDate);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create To-Do Item',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter a title' : null,
                onChanged: (v) => _title = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (v) => _description = v,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recurring'),
                  Switch(
                    value: _isRecurring,
                    onChanged: (v) => setState(() => _isRecurring = v),
                  ),
                ],
              ),
              if (!_isRecurring) ...[
                const Text('Due Date'),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: _pickDate,
                  child: Text(dateStr),
                ),
              ],
              if (_isRecurring) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _recurrenceType,
                  decoration: const InputDecoration(
                    labelText: 'Recurrence Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _recurrenceOptions
                      .map((opt) =>
                          DropdownMenuItem(value: opt, child: Text(opt)))
                      .toList(),
                  onChanged: (val) => setState(() => _recurrenceType = val!),
                ),
                if (_recurrenceType == 'Specific weekdays') ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: _weekdays
                        .map((day) => FilterChip(
                              label: Text(day),
                              selected: _selectedWeekdays.contains(day),
                              onSelected: (_) => _toggleWeekday(day),
                            ))
                        .toList(),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Create'),
                  onPressed: _createTodo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
