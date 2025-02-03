import 'package:json_annotation/json_annotation.dart';

part 'latest_message_model.g.dart';

@JsonSerializable()
class LatestMessageModel {
  final String workRoomId;
  final String lastMessageId;
  final String lastMessageContent;
  final String lastMessageSenderId;
  final DateTime lastMessageTime;

  LatestMessageModel({
    required this.workRoomId,
    required this.lastMessageId,
    required this.lastMessageContent,
    required this.lastMessageSenderId,
    required this.lastMessageTime,
  });

  /// **JSON → 객체 변환 (`fromJson`)**
  factory LatestMessageModel.fromJson(Map<String, dynamic> json) {
    return LatestMessageModel(
      workRoomId: json['work_room_id'] as String? ?? '',
      lastMessageId: json['last_message_id'] as String? ?? '',
      lastMessageContent: json['last_message_content'] as String? ?? '',
      lastMessageSenderId: json['last_message_sender_id'] as String? ?? '',
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'] as String)
          : DateTime.now(),
    );
  }

  /// **객체 → JSON 변환 (`toJson`)**
  Map<String, dynamic> toJson() => _$LatestMessageModelToJson(this);
}
//flutter pub run build_runner build --delete-conflicting-outputs