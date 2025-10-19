import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef OnDateSelected = void Function(int idx);

class HorizontalDates extends StatefulWidget {
  final int windowDays;
  final DateTime Function(int idx) dateForIndex;
  final int selectedIndex;
  final OnDateSelected onSelected;

  const HorizontalDates({
    super.key,
    required this.windowDays,
    required this.dateForIndex,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<HorizontalDates> createState() => _HorizontalDatesState();
}

class _HorizontalDatesState extends State<HorizontalDates> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final todayIdx = _findTodayIndex();
      _scrollToCenter(todayIdx);
    });
  }

  int _findTodayIndex() {
    for (int i = 0; i < widget.windowDays; i++) {
      final d = widget.dateForIndex(i);
      if (DateFormat('yyyy-MM-dd').format(d) ==
          DateFormat('yyyy-MM-dd').format(DateTime.now())) {
        return i;
      }
    }
    return 0;
  }

  void _scrollToCenter(int idx) {
    const itemWidth = 60.0 + 12.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final offset = idx * itemWidth - (screenWidth / 2) + (itemWidth / 2);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300), // how long the scroll takes
        curve: Curves.easeInOut, // how the motion feels
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.windowDays,
        itemBuilder: (context, idx) {
          final d = widget.dateForIndex(idx);
          final isToday = DateFormat('yyyy-MM-dd').format(d) ==
              DateFormat('yyyy-MM-dd').format(DateTime.now());
          final isSelected = widget.selectedIndex == idx;

          final Color backgroundColor = isSelected
              ? colorScheme.primary
              : theme.cardColor;

          final Color textColor = isSelected
              ? colorScheme.onPrimary
              : (isToday
                  ? colorScheme.primary
                  : colorScheme.onSurface);

          final BoxBorder? border = (isToday && !isSelected)
              ? Border.all(color: colorScheme.primary, width: 2)
              : null;

          return GestureDetector(
            onTap: () {
              widget.onSelected(idx);
              _scrollToCenter(idx);
            },
            child: AnimatedScale(
              scale: isSelected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                width: 60,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: border,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.E().format(d),
                        style: textTheme.bodySmall?.copyWith(color: textColor),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat.d().format(d),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
