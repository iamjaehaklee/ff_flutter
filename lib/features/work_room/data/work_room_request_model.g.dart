// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_room_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkRoomRequest _$WorkRoomRequestFromJson(Map<String, dynamic> json) =>
    WorkRoomRequest(
      id: json['id'] as String,
      requesterId: json['requesterId'] as String,
      recipientId: json['recipientId'] as String?,
      workRoomId: json['workRoomId'] as String,
      recipientEmail: json['recipientEmail'] as String?,
      status: json['status'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
    );

Map<String, dynamic> _$WorkRoomRequestToJson(WorkRoomRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requesterId': instance.requesterId,
      'recipientId': instance.recipientId,
      'workRoomId': instance.workRoomId,
      'recipientEmail': instance.recipientEmail,
      'status': instance.status,
      'sentAt': instance.sentAt.toIso8601String(),
      'respondedAt': instance.respondedAt?.toIso8601String(),
    };
