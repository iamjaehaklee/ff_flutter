// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_annotation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentAnnotationModel _$DocumentAnnotationModelFromJson(
        Map<String, dynamic> json) =>
    DocumentAnnotationModel(
      id: json['id'] as String,
      documentId: json['documentId'] as String?,
      parentFileStorageKey: json['parentFileStorageKey'] as String,
      workRoomId: json['workRoomId'] as String?,
      annotationType: json['annotationType'] as String?,
      pageNumber: (json['pageNumber'] as num?)?.toInt(),
      startPosition: (json['startPosition'] as num?)?.toInt(),
      endPosition: (json['endPosition'] as num?)?.toInt(),
      x1: (json['x1'] as num?)?.toDouble(),
      y1: (json['y1'] as num?)?.toDouble(),
      x2: (json['x2'] as num?)?.toDouble(),
      y2: (json['y2'] as num?)?.toDouble(),
      imageFileStorageKey: json['imageFileStorageKey'] as String?,
      isOcr: json['isOcr'] as bool,
      ocrText: json['ocrText'] as String?,
      content: json['content'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DocumentAnnotationModelToJson(
        DocumentAnnotationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'documentId': instance.documentId,
      'parentFileStorageKey': instance.parentFileStorageKey,
      'workRoomId': instance.workRoomId,
      'annotationType': instance.annotationType,
      'pageNumber': instance.pageNumber,
      'startPosition': instance.startPosition,
      'endPosition': instance.endPosition,
      'x1': instance.x1,
      'y1': instance.y1,
      'x2': instance.x2,
      'y2': instance.y2,
      'imageFileStorageKey': instance.imageFileStorageKey,
      'isOcr': instance.isOcr,
      'ocrText': instance.ocrText,
      'content': instance.content,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
