import 'dart:convert';
import 'package:http/http.dart' as http;
import 'notification_model.dart';

class NotificationRepository {
  final String getUserNotificationsUrl; // Supabase Edge Function URL
  final String jwtToken;

  NotificationRepository({
    required this.getUserNotificationsUrl,
    required this.jwtToken,
  });

  /// Fetch notifications for a specific user
  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final uri = Uri.parse('$getUserNotificationsUrl');

    final requestBody = jsonEncode({"p_user_id": userId});

    // Log request details for debugging
    print("🔵 [REQUEST] Fetching notifications for userId: $userId");
    print("🔸 Request Body: $requestBody");

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      // Log response status and body for debugging
      print("🟢 [RESPONSE] Status Code: ${response.statusCode}");
      print("🟢 [RESPONSE] Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedResponse)['notifications'];

        // Log the number of notifications returned
        print("🟢 [SUCCESS] Fetched ${responseData.length} notifications");

        return (responseData as List)
            .map((notificationJson) => NotificationModel.fromJson(notificationJson))
            .toList();
      } else {
        // Log the error details
        print("❌ [ERROR] Failed to fetch notifications: ${response.body}");

        // Try to parse error details or throw a generic exception
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(
              "Failed to fetch notifications: ${errorData['error'] ?? response.body}");
        } catch (_) {
          throw Exception("Failed to fetch notifications: ${response.body}");
        }
      }
    } catch (e, stackTrace) {
      // Log the exception and stack trace if there's an error
      print("🚨 [EXCEPTION] Error during fetch: $e");
      print("🔴 Stack Trace: $stackTrace");
      rethrow;
    }
  }

  /// Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    // Log when marking a notification as read
    print("🔵 [REQUEST] Marking notification as read: $notificationId");

    try {
      // Simulate marking the notification as read (actual API call can go here)
      print("🟢 [SUCCESS] Notification $notificationId marked as read");

      // In a real scenario, you'd make an API call to mark it as read
      // Example: await notificationRepository.markNotificationAsRead(notificationId);

    } catch (e, stackTrace) {
      // Log errors while marking the notification as read
      print("❌ [ERROR] Failed to mark notification $notificationId as read: $e");
      print("🔴 Stack Trace: $stackTrace");
    }
  }
}
