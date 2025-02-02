// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkRoom _$WorkRoomFromJson(Map<String, dynamic> json) => WorkRoom(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => Participant.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkRoomToJson(WorkRoom instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'participants': instance.participants,
    };

Participant _$ParticipantFromJson(Map<String, dynamic> json) => Participant(
      userId: json['userId'] as String,
      isAdmin: json['isAdmin'] as bool,
      username: json['username'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String,
      isLawyer: json['isLawyer'] as bool,
    );

Map<String, dynamic> _$ParticipantToJson(Participant instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'isAdmin': instance.isAdmin,
      'username': instance.username,
      'profilePictureUrl': instance.profilePictureUrl,
      'isLawyer': instance.isLawyer,
    };
