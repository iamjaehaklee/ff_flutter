import 'package:flutter/material.dart';
import '../../data/calendar_event_model.dart';

class CalendarEventTile extends StatelessWidget {
  final CalendarEvent event;

  const CalendarEventTile({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(event.title),
      subtitle: Text(
        '${event.startDate} - ${event.endDate}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          // Handle delete
        },
      ),
    );
  }
}
