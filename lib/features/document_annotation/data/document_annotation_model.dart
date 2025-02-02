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
  final double? x1;
  final double? y1;
  final double? x2;
  final double? y2;
  final String? imageFileStorageKey;
  final bool isOcr; // Defaulted to false in fromJson
  final String? ocrText;
  final String? content; // Nullable
  final String createdBy; // Required
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentAnnotationModel({
    required this.id,
    required this.documentId,
    required this.parentFileStorageKey,
    this.workRoomId,
    this.annotationType,
    this.pageNumber,
    this.startPosition,
    this.endPosition,
    this.x1,
    this.y1,
    this.x2,
    this.y2,
    this.imageFileStorageKey,
    required this.isOcr,
    this.ocrText,
    this.content,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
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
      x1: (json['x1'] as num?)?.toDouble(),
      y1: (json['y1'] as num?)?.toDouble(),
      x2: (json['x2'] as num?)?.toDouble(),
      y2: (json['y2'] as num?)?.toDouble(),
      imageFileStorageKey: json['image_file_storage_key'] as String?,
      isOcr: json['is_ocr'] as bool? ?? false,
      ocrText: json['ocr_text'] as String?,
      content: json['content'] as String?,
      createdBy: json['created_by'] as String? ?? 'Unknown',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => _$DocumentAnnotationModelToJson(this);

  static Map<String, dynamic> rectToJson(Rect rect) {
    return {
      'x1': rect.left,
      'y1': rect.top,
      'x2': rect.right,
      'y2': rect.bottom,
    };
  }

  static Rect jsonToRect(Map<String, dynamic> json) {
    return Rect.fromLTRB(
      (json['x1'] as num?)?.toDouble() ?? 0.0,
      (json['y1'] as num?)?.toDouble() ?? 0.0,
      (json['x2'] as num?)?.toDouble() ?? 0.0,
      (json['y2'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
