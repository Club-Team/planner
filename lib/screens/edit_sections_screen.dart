import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayline_planner/models/section_model.dart';
import '../providers/section_provider.dart';

class EditSectionsScreen extends StatelessWidget {
  const EditSectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Your Day Sections')),
      body: const Padding(
        padding: EdgeInsets.all(12),
        child: _VerticalTimeline(),
      ),
      floatingActionButton: const _AddSectionButton(),
    );
  }
}

class _VerticalTimeline extends StatefulWidget {
  const _VerticalTimeline();

  @override
  State<_VerticalTimeline> createState() => _VerticalTimelineState();
}

class _VerticalTimelineState extends State<_VerticalTimeline> {
  static const totalMinutes = 24 * 60;

  // helper map for consistent icon lookup
  static const _iconMap = {
    'wb_sunny': Icons.wb_sunny,
    'coffee': Icons.coffee,
    'lunch_dining': Icons.lunch_dining,
    'work': Icons.work,
    'nightlight_round': Icons.nightlight_round,
    'book': Icons.book,
    'fitness_center': Icons.fitness_center,
    'schedule': Icons.schedule,
    'alarm': Icons.alarm,
    'school': Icons.school,
    'music_note': Icons.music_note,
    'restaurant': Icons.restaurant,
    'local_cafe': Icons.local_cafe,
    'directions_run': Icons.directions_run,
    'movie': Icons.movie,
    'local_hospital': Icons.local_hospital,
    'shopping_cart': Icons.shopping_cart,
    'beach_access': Icons.beach_access,
    'pets': Icons.pets,
    'flight': Icons.flight,
    'brush': Icons.brush,
    'camera_alt': Icons.camera_alt,
    'local_grocery_store': Icons.local_grocery_store,
    'terrain': Icons.terrain,
    'directions_bike': Icons.directions_bike,
    'sports_soccer': Icons.sports_soccer,
    'theaters': Icons.theaters,
    'mic': Icons.mic,
    'gamepad': Icons.gamepad,
    'local_library': Icons.local_library,
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SectionProvider>();

    final sections = provider.fullSections.where((s) => !s.isDeleted).toList()
      ..sort((a, b) => (a.startTime.hour * 60 + a.startTime.minute)
          .compareTo(b.startTime.hour * 60 + b.startTime.minute));

    return SingleChildScrollView(
      child: Column(
        children: sections.map((s) {
          final start = s.startTime.hour * 60 + s.startTime.minute;
          final end = s.endTime.hour * 60 + s.endTime.minute;
          final height = (end - start) / totalMinutes * 800;
          return GestureDetector(
            onTap: () => _showInlineEditor(context, s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: height.clamp(90, 220),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _iconMap[s.iconName] ?? Icons.schedule,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _format(s.startTime),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _format(s.endTime),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _showInlineEditor(BuildContext context, Section s) async {
    final provider = context.read<SectionProvider>();
    double start = (s.startTime.hour * 60 + s.startTime.minute).toDouble();
    double end = (s.endTime.hour * 60 + s.endTime.minute).toDouble();
    final titleCtrl = TextEditingController(text: s.title);
    String selectedIcon = s.iconName;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Section name'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_format(_toTime(start))),
                        Text(_format(_toTime(end))),
                      ],
                    ),
                    RangeSlider(
                      min: 0,
                      max: 1440,
                      divisions: 96,
                      values: RangeValues(
                        start <= end ? start : end,
                        end >= start ? end : start,
                      ),
                      activeColor: Theme.of(ctx).colorScheme.primary,
                      onChanged: (val) {
                        setModalState(() {
                          // ensure start <= end
                          start = val.start <= val.end ? val.start : val.end;
                          end = val.end >= val.start ? val.end : val.start;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Select Icon:'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 60,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _iconMap.entries.map((entry) {
                            final iconName = entry.key;
                            final iconData = entry.value;
                            final selected = selectedIcon == iconName;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setModalState(
                                    () => selectedIcon = iconName),
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: selected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade300,
                                  child: Icon(
                                    iconData,
                                    color: selected
                                        ? Colors.white
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Save'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () async {
                              final startT = _toTime(start);
                              final endT = _toTime(end);
                              final err = await provider.updateSection(
                                s,
                                titleCtrl.text.trim(),
                                startT,
                                endT,
                                selectedIcon,
                              );
                              if (err != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(err)),
                                );
                              }
                              if (context.mounted) Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete section',
                          onPressed: () async {
                            await provider.removeSection(s.id);
                            if (context.mounted) Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static String _format(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static TimeOfDay _toTime(double minutes) {
    final h = minutes ~/ 60;
    final m = (minutes % 60).round();
    return TimeOfDay(hour: h, minute: m);
  }
}

class _AddSectionButton extends StatelessWidget {
  const _AddSectionButton();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SectionProvider>();
    return FloatingActionButton.extended(
      icon: const Icon(Icons.add),
      label: const Text('Add Section'),
      onPressed: () async {
        final existing = provider.fullSections.where((s) => !s.isDeleted);
        TimeOfDay start = const TimeOfDay(hour: 0, minute: 0);
        if (existing.isNotEmpty) {
          final l = existing.last.endTime;
          start = TimeOfDay(hour: l.hour, minute: l.minute);
        }
        final end =
            TimeOfDay(hour: (start.hour + 2) % 24, minute: start.minute);
        final err = await provider.addSection(
          'New Section',
          start,
          end,
          'schedule', // default icon
        );
        if (err != null && context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(err)));
        }
      },
    );
  }
}
