import 'package:json_annotation/json_annotation.dart';

part 'work_room_request_model.g.dart';

@JsonSerializable()
class WorkRoomRequest {
  final String id;
  final String requesterId;
  final String? recipientId;
  final String workRoomId;
  final String? recipientEmail;
  final String status;
  final DateTime sentAt;
  final DateTime? respondedAt;

  WorkRoomRequest({
    required this.id,
    required this.requesterId,
    this.recipientId,
    required this.workRoomId,
    this.recipientEmail,
    required this.status,
    required this.sentAt,
    this.respondedAt,
  });

  factory WorkRoomRequest.fromJson(Map<String, dynamic> json) {
    return WorkRoomRequest(
      id: json['id'] as String? ?? '',
      requesterId: json['requester_id'] as String? ?? '',
      recipientId: json['recipient_id'] as String?,
      workRoomId: json['work_room_id'] as String? ?? '',
      recipientEmail: json['recipient_email'] as String?,
      status: json['status'] as String? ?? 'pending',
      sentAt: DateTime.tryParse(json['sent_at'] as String? ?? '') ?? DateTime.now(),
      respondedAt: json['responded_at'] != null ? DateTime.tryParse(json['responded_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => _$WorkRoomRequestToJson(this);
}
