// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Folder _$FolderFromJson(Map<String, dynamic> json) => Folder(
      id: json['id'] as String,
      workRoomId: json['work_room_id'] as String,
      createdBy: json['created_by'] as String,
      folderName: json['folder_name'] as String,
      folderPath: json['folder_path'] as String,
      parentFolderId: json['parent_folder_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$FolderToJson(Folder instance) => <String, dynamic>{
      'id': instance.id,
      'work_room_id': instance.workRoomId,
      'created_by': instance.createdBy,
      'folder_name': instance.folderName,
      'folder_path': instance.folderPath,
      'parent_folder_id': instance.parentFolderId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
