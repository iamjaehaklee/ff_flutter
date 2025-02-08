import 'package:json_annotation/json_annotation.dart';
import 'work_room_model.dart';
import 'participant_model.dart';

part 'work_room_with_participants_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkRoomWithParticipants {
  final WorkRoom workRoom;
  final List<Participant> participants;

  WorkRoomWithParticipants({
    required this.workRoom,
    required this.participants,
  });

  factory WorkRoomWithParticipants.fromJson(Map<String, dynamic> json) {
    // 만약 최상위에 "work_room_with_participants" 키가 있으면 그 값을 사용합니다.
    final data = json.containsKey('work_room_with_participants')
        ? json['work_room_with_participants'] as Map<String, dynamic>
        : json;
    return WorkRoomWithParticipants(
      workRoom: WorkRoom.fromJson(data['work_room'] as Map<String, dynamic>),
      participants: (data['participants'] as List<dynamic>?)
          ?.map((e) => Participant.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  } // end of fromJson

  Map<String, dynamic> toJson() => _$WorkRoomWithParticipantsToJson(this);
} // end of WorkRoomWithParticipants
