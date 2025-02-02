import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/calendar/data/calendar_event_model.dart';
import 'package:legalfactfinder2025/features/calendar/data/calendar_repository.dart';


class CalendarController extends GetxController {
  final CalendarRepository repository = CalendarRepository();

  var events = <CalendarEvent>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  void loadEvents() {
    events.value = repository.getEvents();
  }

  void addEvent(CalendarEvent event) {
    repository.addEvent(event);
    loadEvents();
  }

  void updateEvent(String id, CalendarEvent updatedEvent) {
    repository.updateEvent(id, updatedEvent);
    loadEvents();
  }

  void deleteEvent(String id) {
    repository.deleteEvent(id);
    loadEvents();
  }
}
