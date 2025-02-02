import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String workRoomId;
  final String senderId;
  final String? parentMessageId;
  final String content;
  final String messageType;
  final int threadCount;
  final bool hasAttachments;
  final String? attachmentFileStorageKey;
  final String? attachmentFileType;
  final String? highlight;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? annotationId;
  final String? ocrText;
  final String? annotationImageStorageKey;
  final bool isSystem;
  final String? systemEventType;
  final String? replyToMessageId;
  final String? replyToMessageContent;
  final String? replyToMessageSenderId;
  final DateTime? replyToMessageCreatedAt;
  final String? imageFileId;

  Message({
    required this.id,
    required this.workRoomId,
    required this.senderId,
    this.parentMessageId,
    required this.content,
    required this.messageType,
    required this.threadCount,
    required this.hasAttachments,
    this.attachmentFileStorageKey,
    this.attachmentFileType,
    this.highlight,
    required this.createdAt,
    required this.updatedAt,
    this.annotationId,
    this.ocrText,
    this.annotationImageStorageKey,
    required this.isSystem,
    this.systemEventType,
    this.replyToMessageId,
    this.replyToMessageContent,
    this.replyToMessageSenderId,
    this.replyToMessageCreatedAt,
    this.imageFileId,
  });

  // Null-safe factory method for JSON deserialization
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String? ?? '', // Default to empty string if null
      workRoomId: json['work_room_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      parentMessageId: json['parent_message_id'] as String?,
      content: json['content'] as String? ?? '',
      messageType: json['message_type'] as String? ?? 'text',
      threadCount: json['thread_count'] as int? ?? 0,
      hasAttachments: json['has_attachments'] as bool? ?? false,
      attachmentFileStorageKey: json['attachment_file_storage_key'] as String?,
      attachmentFileType: json['attachment_file_type'] as String?,
      highlight: json['highlight'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      annotationId: json['annotation_id'] as String?,
      ocrText: json['ocr_text'] as String?,
      annotationImageStorageKey: json['annotation_image_file_storage_key'] as String?,
      isSystem: json['is_system'] as bool? ?? false,
      systemEventType: json['system_event_type'] as String?,
      replyToMessageId: json['reply_to_message_id'] as String?,
      replyToMessageContent: json['reply_to_message_content'] as String?,
      replyToMessageSenderId: json['reply_to_message_sender_id'] as String?,
      replyToMessageCreatedAt: json['reply_to_message_created_at'] == null
          ? null
          : DateTime.parse(json['reply_to_message_created_at'] as String),
      imageFileId: json['image_file_storage_key'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
