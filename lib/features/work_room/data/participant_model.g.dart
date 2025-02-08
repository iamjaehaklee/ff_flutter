// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Participant _$ParticipantFromJson(Map<String, dynamic> json) => Participant(
      userId: json['user_id'] as String,
      isAdmin: json['is_admin'] as bool? ?? false,
      username: json['username'] as String,
      imageFileStorageKey: json['image_file_storage_key'] as String? ?? '',
      isLawyer: json['is_lawyer'] as bool? ?? false,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      lastSeen: DateTime.parse(json['last_seen'] as String),
    );

Map<String, dynamic> _$ParticipantToJson(Participant instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'is_admin': instance.isAdmin,
      'username': instance.username,
      'image_file_storage_key': instance.imageFileStorageKey,
      'is_lawyer': instance.isLawyer,
      'joined_at': instance.joinedAt.toIso8601String(),
      'last_seen': instance.lastSeen.toIso8601String(),
    };
