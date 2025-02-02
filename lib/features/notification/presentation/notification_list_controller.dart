import 'package:get/get.dart';
import 'package:legalfactfinder2025/constants.dart';
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
    print("🔄 NotificationListController initialized");
    // Uncomment if user authentication is needed
    // final AuthController authController = Get.find();
    // String? userId = authController.getUserId();
    //
    // if (userId == null) {
    //   print("🚨 User not logged in. Redirecting to login page.");
    //   Get.offAllNamed('/login');
    //   return;
    // }
    //
    // print("User ID: $userId");
    // fetchNotifications(userId); // Fetch notifications if userId is valid
  }

  Future<void> fetchNotifications() async {
    AuthController authController = Get.find<AuthController>();
    final userId = authController.getUserId(); // AuthController에서 userId 가져오기
    if (userId == null) {
      print("❌ Error: userId is null. Cannot fetch notifications.");
      return;
    }

    print("🔵 Fetching notifications for userId: $userId");

    isLoading(true); // Set loading state to true
    try {
      final data = await notificationRepository.fetchNotifications(userId);
      notifications.value = data;
      print("🟢 Successfully fetched ${data.length} notifications");
    } catch (e) {
      print("❌ Error fetching notifications: $e");
    } finally {
      isLoading(false); // Set loading state to false after operation is complete
      print("🔚 Fetching notifications completed.");
    }
  }

  Future<void> markAsRead(String notificationId) async {
    print("🔵 Marking notification as read: $notificationId");

    try {
      // Mark the notification as read in the repository
      await notificationRepository.markNotificationAsRead(notificationId);
      print("🟢 Notification marked as read: $notificationId");

      // Find the notification locally and update its status
      NotificationModel notification = notifications.firstWhere((n) => n.id == notificationId);
      notification.isRead = true;
      notifications.refresh(); // Refresh the notifications list to trigger UI update
      print("🟢 Notification status updated: $notificationId isRead = true");
    } catch (e) {
      print("❌ Error marking notification as read: $e");
    }
  }
}
