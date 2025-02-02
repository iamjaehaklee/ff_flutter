import '../data/notification_repository.dart';
import '../data/notification_model.dart';

class FetchNotificationsUseCase {
  final NotificationRepository repository;

  FetchNotificationsUseCase(this.repository);

  Future<List<NotificationModel>> call(String userId) {
    return repository.fetchNotifications(userId);
  }
}
