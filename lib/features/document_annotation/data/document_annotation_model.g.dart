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
      area_left: (json['area_left'] as num?)?.toDouble(),
      area_top: (json['area_top'] as num?)?.toDouble(),
      area_width: (json['area_width'] as num?)?.toDouble(),
      area_height: (json['area_height'] as num?)?.toDouble(),
      imageFileStorageKey: json['imageFileStorageKey'] as String?,
      isOcr: json['isOcr'] as bool,
      ocrText: json['ocrText'] as String?,
      content: json['content'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      threadCount: (json['threadCount'] as num).toInt(),
      chatMessageId: json['chatMessageId'] as String?,
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
      'area_left': instance.area_left,
      'area_top': instance.area_top,
      'area_width': instance.area_width,
      'area_height': instance.area_height,
      'imageFileStorageKey': instance.imageFileStorageKey,
      'isOcr': instance.isOcr,
      'ocrText': instance.ocrText,
      'content': instance.content,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'threadCount': instance.threadCount,
      'chatMessageId': instance.chatMessageId,
    };
