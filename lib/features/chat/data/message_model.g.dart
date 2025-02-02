// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String,
      workRoomId: json['workRoomId'] as String,
      senderId: json['senderId'] as String,
      parentMessageId: json['parentMessageId'] as String?,
      content: json['content'] as String,
      messageType: json['messageType'] as String,
      threadCount: (json['threadCount'] as num).toInt(),
      hasAttachments: json['hasAttachments'] as bool,
      attachmentFileStorageKey: json['attachmentFileStorageKey'] as String?,
      attachmentFileType: json['attachmentFileType'] as String?,
      highlight: json['highlight'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      annotationId: json['annotationId'] as String?,
      ocrText: json['ocrText'] as String?,
      annotationImageStorageKey: json['annotationImageStorageKey'] as String?,
      isSystem: json['isSystem'] as bool,
      systemEventType: json['systemEventType'] as String?,
      replyToMessageId: json['replyToMessageId'] as String?,
      replyToMessageContent: json['replyToMessageContent'] as String?,
      replyToMessageSenderId: json['replyToMessageSenderId'] as String?,
      replyToMessageCreatedAt: json['replyToMessageCreatedAt'] == null
          ? null
          : DateTime.parse(json['replyToMessageCreatedAt'] as String),
      imageFileId: json['imageFileId'] as String?,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'workRoomId': instance.workRoomId,
      'senderId': instance.senderId,
      'parentMessageId': instance.parentMessageId,
      'content': instance.content,
      'messageType': instance.messageType,
      'threadCount': instance.threadCount,
      'hasAttachments': instance.hasAttachments,
      'attachmentFileStorageKey': instance.attachmentFileStorageKey,
      'attachmentFileType': instance.attachmentFileType,
      'highlight': instance.highlight,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'annotationId': instance.annotationId,
      'ocrText': instance.ocrText,
      'annotationImageStorageKey': instance.annotationImageStorageKey,
      'isSystem': instance.isSystem,
      'systemEventType': instance.systemEventType,
      'replyToMessageId': instance.replyToMessageId,
      'replyToMessageContent': instance.replyToMessageContent,
      'replyToMessageSenderId': instance.replyToMessageSenderId,
      'replyToMessageCreatedAt':
          instance.replyToMessageCreatedAt?.toIso8601String(),
      'imageFileId': instance.imageFileId,
    };
