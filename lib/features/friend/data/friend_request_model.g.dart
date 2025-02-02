// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRequest _$FriendRequestFromJson(Map<String, dynamic> json) =>
    FriendRequest(
      id: json['id'] as String,
      requesterId: json['requesterId'] as String,
      recipientId: json['recipientId'] as String?,
      status: json['status'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
      recipientEmail: json['recipientEmail'] as String?,
    );

Map<String, dynamic> _$FriendRequestToJson(FriendRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requesterId': instance.requesterId,
      'recipientId': instance.recipientId,
      'status': instance.status,
      'sentAt': instance.sentAt.toIso8601String(),
      'respondedAt': instance.respondedAt?.toIso8601String(),
      'recipientEmail': instance.recipientEmail,
    };
