// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileData _$FileDataFromJson(Map<String, dynamic> json) => FileData(
      id: json['id'] as String,
      storageKey: json['storage_key'] as String,
      storagePath: json['storage_path'] as String?,
      fileName: json['file_name'] as String,
      fileType: json['file_type'] as String,
      fileSize: (json['file_size'] as num).toInt(),
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      workRoomId: json['work_room_id'] as String,
      uploaderId: json['uploader_id'] as String,
      description: json['description'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$FileDataToJson(FileData instance) => <String, dynamic>{
      'id': instance.id,
      'storage_key': instance.storageKey,
      'storage_path': instance.storagePath,
      'file_name': instance.fileName,
      'file_type': instance.fileType,
      'file_size': instance.fileSize,
      'uploaded_at': instance.uploadedAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'work_room_id': instance.workRoomId,
      'uploader_id': instance.uploaderId,
      'description': instance.description,
      'is_deleted': instance.isDeleted,
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
