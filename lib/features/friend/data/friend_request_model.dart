import 'package:json_annotation/json_annotation.dart';

part 'friend_request_model.g.dart';

@JsonSerializable()
class FriendRequest {
  final String id;
  final String requesterId;
  final String? recipientId;
  final String status;
  final DateTime sentAt;
  final DateTime? respondedAt;
  final String? recipientEmail;

  FriendRequest({
    required this.id,
    required this.requesterId,
    this.recipientId,
    required this.status,
    required this.sentAt,
    this.respondedAt,
    this.recipientEmail,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] as String? ?? '',
      requesterId: json['requester_id'] as String? ?? '',
      recipientId: json['recipient_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      sentAt: DateTime.tryParse(json['sent_at'] as String? ?? '') ?? DateTime.now(),
      respondedAt: json['responded_at'] != null ? DateTime.tryParse(json['responded_at'] as String) : null,
      recipientEmail: json['recipient_email'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$FriendRequestToJson(this);
}