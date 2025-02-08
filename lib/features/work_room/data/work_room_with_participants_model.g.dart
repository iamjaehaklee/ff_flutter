// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_room_with_participants_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkRoomWithParticipants _$WorkRoomWithParticipantsFromJson(
        Map<String, dynamic> json) =>
    WorkRoomWithParticipants(
      workRoom: WorkRoom.fromJson(json['workRoom'] as Map<String, dynamic>),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => Participant.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkRoomWithParticipantsToJson(
        WorkRoomWithParticipants instance) =>
    <String, dynamic>{
      'workRoom': instance.workRoom.toJson(),
      'participants': instance.participants.map((e) => e.toJson()).toList(),
    };
