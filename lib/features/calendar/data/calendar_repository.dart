import 'calendar_event_model.dart';

class CalendarRepository {
  final List<CalendarEvent> _events = [];

  List<CalendarEvent> getEvents() {
    return _events;
  }

  void addEvent(CalendarEvent event) {
    _events.add(event);
  }

  void updateEvent(String id, CalendarEvent updatedEvent) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index] = updatedEvent;
    }
  }

  void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
  }
}
