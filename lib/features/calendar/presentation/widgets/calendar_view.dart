import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/calendar/calendar_controller.dart';
import 'package:table_calendar/table_calendar.dart';


class CalendarView extends StatelessWidget {
  final CalendarController controller;

  const CalendarView({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: DateTime.now(),
      firstDay: DateTime(2000),
      lastDay: DateTime(2100),
      eventLoader: (day) {
        return controller.events
            .where((event) => isSameDay(event.startDate, day))
            .toList();
      },
      calendarStyle: const CalendarStyle(
        markerDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        // Handle day selection
      },
    );
  }
}
