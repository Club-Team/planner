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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final dateStr = DateFormat('yMMMd').format(_dueDate);

    final inputDecoration = theme.inputDecorationTheme.copyWith(
      border: const OutlineInputBorder(),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 6,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create To-Do Item',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              /// Title
              TextFormField(
                decoration: inputDecoration.copyWith(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Enter a title' : null,
                onChanged: (v) => _title = v,
              ),
              const SizedBox(height: 12),

              /// Description
              TextFormField(
                decoration: inputDecoration.copyWith(labelText: 'Description'),
                maxLines: 3,
                onChanged: (v) => _description = v,
              ),
              const SizedBox(height: 16),

              /// Recurring toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recurring', style: textTheme.bodyMedium),
                  Switch(
                    value: _isRecurring,
                    onChanged: (v) => setState(() => _isRecurring = v),
                  ),
                ],
              ),

              /// Non-recurring: show date picker
              if (!_isRecurring) ...[
                const SizedBox(height: 12),
                Text('Due Date', style: textTheme.bodyMedium),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(dateStr, style: textTheme.bodyMedium),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.outline),
                  ),
                  onPressed: _pickDate,
                ),
              ],

              /// Recurring options
              if (_isRecurring) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _recurrenceType,
                  decoration:
                      inputDecoration.copyWith(labelText: 'Recurrence Type'),
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
                    children: _weekdays.map((day) {
                      final selected = _selectedWeekdays.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: selected,
                        onSelected: (_) => _toggleWeekday(day),
                        selectedColor: colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: selected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Create'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle:
                        textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
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
