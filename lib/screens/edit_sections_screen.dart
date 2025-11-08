import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayline_planner/models/section_model.dart';
import '../providers/section_provider.dart';

class EditSectionsScreen extends StatelessWidget {
  const EditSectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Your Day Sections'),
        centerTitle: true,
      ),
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

    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        children: sections.map((s) {
          final start = s.startTime.hour * 60 + s.startTime.minute;
          final end = s.endTime.hour * 60 + s.endTime.minute;
          final height = (end - start) / totalMinutes * 800;
          final color = theme.colorScheme.primary;
          return Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              onTap: () => _VerticalTimelineState.showEditor(context, section: s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: height.clamp(90, 220),
                decoration: BoxDecoration(
                  // Use surface tint to avoid extra elevation while keeping M3 look
                  color: theme.cardColor,
                ),
                child: Stack(
                  children: [
                    // Left accent bar indicating the section
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              color,
                              color.withOpacity(0.65),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  _iconMap[s.iconName] ?? Icons.schedule,
                                  size: 20,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  s.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
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
                              Row(
                                children: [
                                  const Icon(Icons.play_arrow_rounded, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    _format(s.startTime),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.stop_rounded, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    _format(s.endTime),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
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

  static Future<void> showEditor(BuildContext context, {Section? section}) async {
    final provider = context.read<SectionProvider>();
    // Initialize fields for create or edit
    late double start;
    late double end;
    late TextEditingController titleCtrl;
    late String selectedIcon;

    if (section != null) {
      start = (section.startTime.hour * 60 + section.startTime.minute).toDouble();
      end = (section.endTime.hour * 60 + section.endTime.minute).toDouble();
      titleCtrl = TextEditingController(text: section.title);
      selectedIcon = section.iconName;
    } else {
      // Defaults for creating a new section: start at last section's end, span 2 hours
      final existing = provider.fullSections.where((s) => !s.isDeleted);
      TimeOfDay startTod = const TimeOfDay(hour: 0, minute: 0);
      if (existing.isNotEmpty) {
        final l = existing.last.endTime;
        startTod = TimeOfDay(hour: l.hour, minute: l.minute);
      }
      start = (startTod.hour * 60 + startTod.minute) > 1439 ? 0 : (startTod.hour * 60 + startTod.minute).toDouble();
      final endTod = TimeOfDay(hour: (startTod.hour + 2) % 24, minute: startTod.minute);
      end = (endTod.hour * 60 + endTod.minute) > 1439 ? 1439 : (endTod.hour * 60 + endTod.minute).toDouble();
      titleCtrl = TextEditingController(text: 'New Section');
      selectedIcon = 'schedule';
    }

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
                    // drag handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            _iconMap[selectedIcon] ?? Icons.schedule,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: titleCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Section name',
                              hintText: 'e.g. Morning Routine',
                            ),
                          ),
                        ),
                      ],
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
                      labels: RangeLabels(
                        _format(_toTime(start)),
                        _format(_toTime(end)),
                      ),
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
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOut,
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.18)
                                        : Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Icon(
                                    iconData,
                                    color: selected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
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
                              String? err;
                              if (section == null) {
                                err = await provider.addSection(
                                  titleCtrl.text.trim(),
                                  startT,
                                  endT,
                                  selectedIcon,
                                );
                              } else {
                                err = await provider.updateSection(
                                  section,
                                  titleCtrl.text.trim(),
                                  startT,
                                  endT,
                                  selectedIcon,
                                );
                              }
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
                        if (section != null)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete section',
                            onPressed: () async {
                              await provider.removeSection(section.id);
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
    return FloatingActionButton.extended(
      icon: const Icon(Icons.add),
      label: const Text('Add Section'),
      onPressed: () => _VerticalTimelineState.showEditor(context, section: null),
    );
  }
}
