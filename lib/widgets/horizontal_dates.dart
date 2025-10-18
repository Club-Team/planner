import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HorizontalDates extends StatefulWidget {
  final int windowDays;
  final DateTime Function(int idx) dateForIndex;
  final PageController pageController;

  const HorizontalDates({
    super.key,
    required this.windowDays,
    required this.dateForIndex,
    required this.pageController,
  });

  @override
  State<HorizontalDates> createState() => _HorizontalDatesState();
}

class _HorizontalDatesState extends State<HorizontalDates> {
  late final ScrollController _scrollController;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // initialize selection to today
    _selectedIndex = _findTodayIndex();

    // Scroll to today's index after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final todayIdx = _selectedIndex ?? 0;
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
    const itemWidth = 60.0 + 12.0; // width + horizontal margin
    final screenWidth = MediaQuery.of(context).size.width;
    final offset = idx * itemWidth - (screenWidth / 2) + (itemWidth / 2);
    _scrollController.jumpTo(offset.clamp(0, _scrollController.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
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
          final isSelected = _selectedIndex == idx;

          final primary = Theme.of(context).colorScheme.primary;
          final onPrimary = Theme.of(context).colorScheme.onPrimary;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = idx;
              });
              widget.pageController.animateToPage(
                idx,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedScale(
              scale: isSelected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 60,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary
                      : (isToday ? Theme.of(context).cardColor : const Color.fromRGBO(250, 246, 237, 1.0)),
                  borderRadius: BorderRadius.circular(12),
                  border: (isToday && !isSelected)
                      ? Border.all(color: primary, width: 2)
                      : null,
                  boxShadow: isSelected
                      ? [BoxShadow(color: primary.withOpacity(0.18), blurRadius: 12, offset: Offset(0, 2))]
                      : [],
                ),
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 220),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.E().format(d),
                        style: TextStyle(
                          color: isSelected ? onPrimary : (isToday ? primary : Colors.black),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat.d().format(d),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? onPrimary : (isToday ? primary : Colors.black),
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
