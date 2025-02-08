import 'package:get/get.dart';
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/core/utils/logger.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/notification/data/notification_model.dart';
import 'package:legalfactfinder2025/features/notification/data/notification_repository.dart';

class NotificationListController extends GetxController {
  final NotificationRepository notificationRepository;

  NotificationListController({required this.notificationRepository});

  var notifications = <NotificationModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    Logger.i('NotificationListController initialized');
    // Uncomment if user authentication is needed
    // final AuthController authController = Get.find();
    // String? userId = authController.getUserId();
    //
    // if (userId == null) {
    //   Logger.e('User not logged in. Redirecting to login page.');
    //   Get.offAllNamed('/login');
    //   return;
    // }
    //
    // Logger.i('User ID: $userId');
    // fetchNotifications(userId); // Fetch notifications if userId is valid
  }

  Future<void> fetchNotifications() async {
    AuthController authController = Get.find<AuthController>();
    final userId = authController.getUserId(); // AuthController에서 userId 가져오기
    if (userId == null) {
      Logger.e('Error: userId is null. Cannot fetch notifications.');
      return;
    }

    Logger.i('Fetching notifications for userId: $userId');

    isLoading(true); // Set loading state to true
    try {
      final data = await notificationRepository.fetchNotifications(userId);
      notifications.value = data;
      Logger.s('Successfully fetched ${data.length} notifications');
    } catch (e) {
      Logger.e('Error fetching notifications: $e', 'NotificationFetch', e);
    } finally {
      isLoading(false); // Set loading state to false after operation is complete
      Logger.i('Fetching notifications completed.');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    Logger.i('Marking notification as read: $notificationId');

    try {
      // Mark the notification as read in the repository
      await notificationRepository.markNotificationAsRead(notificationId);
      Logger.s('Notification marked as read: $notificationId');

      // Find the notification locally and update its status
      NotificationModel notification = notifications.firstWhere((n) => n.id == notificationId);
      notification.isRead = true;
      notifications.refresh(); // Refresh the notifications list to trigger UI update
      Logger.s('Notification status updated: $notificationId isRead = true');
    } catch (e) {
      Logger.e('Error marking notification as read: $e', 'NotificationMarkAsRead', e);
    }
  }
}
