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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Scroll to today's index after build
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
    const itemWidth = 72.0 + 12.0; // width + horizontal margin
    final screenWidth = MediaQuery.of(context).size.width;
    final offset = idx * itemWidth - (screenWidth / 2) + (itemWidth / 2);
    _scrollController.jumpTo(offset.clamp(0, _scrollController.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.windowDays,
        itemBuilder: (context, idx) {
          final d = widget.dateForIndex(idx);
          final isToday = DateFormat('yyyy-MM-dd').format(d) ==
              DateFormat('yyyy-MM-dd').format(DateTime.now());

          return GestureDetector(
            onTap: () {
              widget.pageController.animateToPage(
                idx,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 72,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              decoration: BoxDecoration(
                color: isToday ? Theme.of(context).primaryColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat.E().format(d),
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat.d().format(d),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
