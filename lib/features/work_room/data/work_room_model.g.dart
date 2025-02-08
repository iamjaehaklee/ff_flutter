// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkRoom _$WorkRoomFromJson(Map<String, dynamic> json) => WorkRoom(
      id: json['work_room_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$WorkRoomToJson(WorkRoom instance) => <String, dynamic>{
      'work_room_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
