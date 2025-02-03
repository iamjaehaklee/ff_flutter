// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latest_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatestMessageModel _$LatestMessageModelFromJson(Map<String, dynamic> json) =>
    LatestMessageModel(
      workRoomId: json['workRoomId'] as String,
      lastMessageId: json['lastMessageId'] as String,
      lastMessageContent: json['lastMessageContent'] as String,
      lastMessageSenderId: json['lastMessageSenderId'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
    );

Map<String, dynamic> _$LatestMessageModelToJson(LatestMessageModel instance) =>
    <String, dynamic>{
      'workRoomId': instance.workRoomId,
      'lastMessageId': instance.lastMessageId,
      'lastMessageContent': instance.lastMessageContent,
      'lastMessageSenderId': instance.lastMessageSenderId,
      'lastMessageTime': instance.lastMessageTime.toIso8601String(),
    };
