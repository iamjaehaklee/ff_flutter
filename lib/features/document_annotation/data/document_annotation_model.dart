import 'package:flutter/painting.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_annotation_model.g.dart';

@JsonSerializable()
class DocumentAnnotationModel {
  final String id;
  final String? documentId; // Nullable
  final String parentFileStorageKey; // Required
  final String? workRoomId; // Nullable
  final String? annotationType;
  final int? pageNumber;
  final int? startPosition;
  final int? endPosition;
  final double? area_left;
  final double? area_top;
  final double? area_width;
  final double? area_height;
  final String? imageFileStorageKey;
  final bool isOcr; // Defaulted to false in fromJson
  final String? ocrText;
  final String? content; // Nullable
  final String createdBy; // Required
  final DateTime createdAt;
  final DateTime updatedAt;
  final int threadCount;
  final String? chatMessageId; // 새롭게 추가된 필드 (nullable)

  DocumentAnnotationModel({
    required this.id,
    required this.documentId,
    required this.parentFileStorageKey,
    this.workRoomId,
    this.annotationType,
    this.pageNumber,
    this.startPosition,
    this.endPosition,
    this.area_left,
    this.area_top,
    this.area_width,
    this.area_height,
    this.imageFileStorageKey,
    required this.isOcr,
    this.ocrText,
    this.content,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.threadCount,
    this.chatMessageId, // Nullable, 기본값 없음
  });

  factory DocumentAnnotationModel.fromJson(Map<String, dynamic> json) {
    print(json);
    if (json['id'] == null) throw Exception("Missing 'id' in annotation JSON");
    if (json['parent_file_storage_key'] == null) {
      throw Exception("Missing 'parentFileStorageKey' in annotation JSON");
    }

    return DocumentAnnotationModel(
      id: json['id'] as String,
      documentId: json['document_id'] as String?,
      parentFileStorageKey: json['parent_file_storage_key'] as String,
      workRoomId: json['work_room_id'] as String?,
      annotationType: json['annotation_type'] as String?,
      pageNumber: json['page_number'] as int?,
      startPosition: json['start_position'] as int?,
      endPosition: json['end_position'] as int?,
      area_left: (json['area_left'] as num?)?.toDouble(),
      area_top: (json['area_top'] as num?)?.toDouble(),
      area_width: (json['area_width'] as num?)?.toDouble(),
      area_height: (json['area_height'] as num?)?.toDouble(),
      imageFileStorageKey: json['image_file_storage_key'] as String?,
      isOcr: json['is_ocr'] as bool? ?? false,
      ocrText: json['ocr_text'] as String?,
      content: json['content'] as String?,
      createdBy: json['created_by'] as String? ?? 'Unknown',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      threadCount: json['thread_count'] as int,
      chatMessageId: json['chat_message_id'] as String?, // JSON에서 chatMessageId 반영
    );
  }

  Map<String, dynamic> toJson() => _$DocumentAnnotationModelToJson(this);

  static Map<String, dynamic> rectToJson(Rect rect) {
    return {
      'area_left': rect.left,
      'area_top': rect.top,
      'area_width': rect.right,
      'area_height': rect.bottom,
    };
  }

  static Rect jsonToRect(Map<String, dynamic> json) {
    return Rect.fromLTRB(
      (json['area_left'] as num?)?.toDouble() ?? 0.0,
      (json['area_top'] as num?)?.toDouble() ?? 0.0,
      (json['area_width'] as num?)?.toDouble() ?? 0.0,
      (json['area_height'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
