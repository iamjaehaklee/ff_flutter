import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String userId;
  final String notificationType;
  final String relatedId;
  final String content;
  bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.notificationType,
    required this.relatedId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
  });

  // Null-safe factory method for JSON deserialization
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      notificationType: json['notification_type'] as String? ?? '',
      relatedId: json['related_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      title: json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
