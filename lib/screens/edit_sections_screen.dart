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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SectionProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sections = provider.fullSections.where((s) => !s.isDeleted).toList()
      ..sort((a, b) =>
          (a.startTime.hour * 60 + a.startTime.minute)
              .compareTo(b.startTime.hour * 60 + b.startTime.minute));

    return SingleChildScrollView(
      child: Column(
        children: sections.map((s) {
          final start = s.startTime.hour * 60 + s.startTime.minute;
          final end = s.endTime.hour * 60 + s.endTime.minute;
          final height = (end - start) / totalMinutes * 800; // proportional height
          final baseColor = Colors.primaries[
              sections.indexOf(s) % Colors.primaries.length];

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
      Text(
        s.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
        maxLines: 2, // allow wrapping to avoid clipping
        overflow: TextOverflow.ellipsis,
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

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                      values: RangeValues(start, end),
                      activeColor: Theme.of(ctx).colorScheme.primary,
                      onChanged: (val) {
                        setModalState(() {
                          start = val.start;
                          end = val.end;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
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
                            s, titleCtrl.text.trim(), startT, endT);
                        if (err != null && context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(err)));
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
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
        final end = TimeOfDay(hour: (start.hour + 2) % 24, minute: start.minute);
        final err =
            await provider.addSection('New Section', start, end);
        if (err != null && context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(err)));
        }
      },
    );
  }
}
