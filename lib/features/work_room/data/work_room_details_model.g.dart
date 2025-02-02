// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_room_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkRoom _$WorkRoomFromJson(Map<String, dynamic> json) => WorkRoom(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WorkRoomToJson(WorkRoom instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

WorkRoomParticipant _$WorkRoomParticipantFromJson(Map<String, dynamic> json) =>
    WorkRoomParticipant(
      id: json['id'] as String,
      workRoomId: json['workRoomId'] as String,
      userId: json['userId'] as String,
      isAdmin: json['isAdmin'] as bool,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastSeen: DateTime.parse(json['lastSeen'] as String),
    );

Map<String, dynamic> _$WorkRoomParticipantToJson(
        WorkRoomParticipant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workRoomId': instance.workRoomId,
      'userId': instance.userId,
      'isAdmin': instance.isAdmin,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'lastSeen': instance.lastSeen.toIso8601String(),
    };

WorkRoomParty _$WorkRoomPartyFromJson(Map<String, dynamic> json) =>
    WorkRoomParty(
      id: json['id'] as String,
      workRoomId: json['workRoomId'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WorkRoomPartyToJson(WorkRoomParty instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workRoomId': instance.workRoomId,
      'name': instance.name,
      'role': instance.role,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

WorkRoomDetails _$WorkRoomDetailsFromJson(Map<String, dynamic> json) =>
    WorkRoomDetails(
      workRoom: WorkRoom.fromJson(json['workRoom'] as Map<String, dynamic>),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => WorkRoomParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
      parties: (json['parties'] as List<dynamic>)
          .map((e) => WorkRoomParty.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkRoomDetailsToJson(WorkRoomDetails instance) =>
    <String, dynamic>{
      'workRoom': instance.workRoom,
      'participants': instance.participants,
      'parties': instance.parties,
    };
