import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayline_planner/providers/section_provider.dart';
import 'package:dayline_planner/utils/icon_helper.dart';
import 'package:dayline_planner/models/section_model.dart';

/// A modern, special vertical timeline for the left of the planner page.
class PlannerTimeline extends StatelessWidget {
  final int startHour;
  final int endHour;
  final double hourHeight;
  const PlannerTimeline({
    this.startHour = 0,
    this.endHour = 24,
    this.hourHeight = 36,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentHour = now.hour;
    final sections = Provider.of<SectionProvider>(context).fullSections;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.02),
            Theme.of(context).colorScheme.secondary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(endHour - startHour + 1, (i) {
          final hour = startHour + i;
          final isFirst = i == 0;
          final isLast = i == endHour - startHour;
          final isCurrentHour = hour == currentHour;
          final isPastHour = hour < currentHour;
          // Determine if this hour slot is a start/end boundary or inside any section
          Section? boundarySection;
          bool isInsideAnySection = false;
          for (final s in sections) {
            // Boundary if the section starts or ends within this hour slot
            if (s.startTime.hour == hour) {
              boundarySection = s;
            }
            // Inside if the section fully covers this hour slot (not a boundary)
            else if (s.startTime.hour < hour && s.endTime.hour > hour) {
              isInsideAnySection = true;
            }
          }
          final bool hideIndicator =
              boundarySection == null && isInsideAnySection;

          return SizedBox(
              height: hourHeight,
              child: TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.8,
                isFirst: isFirst,
                isLast: isLast,
                beforeLineStyle: LineStyle(
                  color: isPastHour
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : Theme.of(context).dividerColor.withOpacity(0.25),
                  thickness: isPastHour ? 2.5 : 2,
                ),
                afterLineStyle: LineStyle(
                  color: isPastHour
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : Theme.of(context).dividerColor.withOpacity(0.25),
                  thickness: isPastHour ? 2.5 : 2,
                ),
                indicatorStyle: IndicatorStyle(
                  drawGap: !hideIndicator,
                  width: hideIndicator
                      ? 5
                      : isCurrentHour
                          ? (boundarySection != null ? 20 : 12)
                          : (boundarySection != null ? 18 : 10),
                  height: hideIndicator
                      ? 5
                      : isCurrentHour
                          ? (boundarySection != null ? 20 : 12)
                          : (boundarySection != null ? 18 : 10),
                  indicator: boundarySection != null
                      ? Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrentHour
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.15)
                                : Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.9),
                            boxShadow: isCurrentHour
                                ? [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.35),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.6),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            IconHelper.getIconData(boundarySection.iconName),
                            size: isCurrentHour ? 14 : 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isCurrentHour
                                ? LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                    ],
                                  )
                                : null,
                            color: isCurrentHour
                                ? null
                                : isPastHour
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.6)
                                    : Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.4),
                            boxShadow: isCurrentHour
                                ? [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                ),
                startChild: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: boundarySection != null ? 3 : 2,
                          vertical: 1),
                      decoration: isCurrentHour
                          ? BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.15),
                                  Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            )
                          : null,
                      child: hideIndicator && !isCurrentHour
                          ? null
                          : Text(
                              hour.toString().padLeft(2, '0') + ':00',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isCurrentHour
                                        ? Theme.of(context).colorScheme.primary
                                        : isPastHour
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onBackground
                                                .withOpacity(0.4)
                                            : Theme.of(context)
                                                .colorScheme
                                                .onBackground
                                                .withOpacity(0.6),
                                    fontSize: isCurrentHour ? 10 : 8,
                                    fontWeight: isCurrentHour
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    letterSpacing: 0.5,
                                  ),
                            )),
                ),
                endChild: const SizedBox(width: 5),
              ));
        }),
      ),
    );
  }
}
