import 'package:json_annotation/json_annotation.dart';

part 'work_room_details_model.g.dart';

@JsonSerializable()
class WorkRoom {
  final String id;
  final String title; // 수정: name -> title
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkRoom({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkRoom.fromJson(Map<String, dynamic> json) {
    return WorkRoom(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '', // 수정된 컬럼명 반영
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => _$WorkRoomToJson(this);
}

@JsonSerializable()
class WorkRoomParticipant {
  final String id;
  final String workRoomId; // 수정: work_room_id 추가
  final String userId;
  final bool isAdmin;
  final DateTime joinedAt;
  final DateTime lastSeen;

  WorkRoomParticipant({
    required this.id,
    required this.workRoomId, // 추가된 필드
    required this.userId,
    required this.isAdmin,
    required this.joinedAt,
    required this.lastSeen,
  });

  factory WorkRoomParticipant.fromJson(Map<String, dynamic> json) {
    return WorkRoomParticipant(
      id: json['id'] as String? ?? '',
      workRoomId: json['work_room_id'] as String? ?? '', // 추가
      userId: json['user_id'] as String? ?? '',
      isAdmin: json['is_admin'] as bool? ?? false,
      joinedAt: DateTime.tryParse(json['joined_at'] as String? ?? '') ?? DateTime.now(),
      lastSeen: DateTime.tryParse(json['last_seen'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => _$WorkRoomParticipantToJson(this);
}

@JsonSerializable()
class WorkRoomParty {
  final String id;
  final String workRoomId;
  final String name;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkRoomParty({
    required this.id,
    required this.workRoomId,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkRoomParty.fromJson(Map<String, dynamic> json) {
    return WorkRoomParty(
      id: json['id'] as String? ?? '',
      workRoomId: json['work_room_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => _$WorkRoomPartyToJson(this);
}

@JsonSerializable()
class WorkRoomDetails {
  final WorkRoom workRoom;
  final List<WorkRoomParticipant> participants;
  final List<WorkRoomParty> parties;

  WorkRoomDetails({
    required this.workRoom,
    required this.participants,
    required this.parties,
  });

  factory WorkRoomDetails.fromJson(Map<String, dynamic> json) {
    return WorkRoomDetails(
      workRoom: WorkRoom.fromJson(json['work_room'] as Map<String, dynamic>? ?? {}),
      participants: (json['participants'] as List<dynamic>?)
          ?.map((participant) => WorkRoomParticipant.fromJson(participant))
          .toList() ??
          [],
      parties: (json['parties'] as List<dynamic>?)
          ?.map((party) => WorkRoomParty.fromJson(party))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => _$WorkRoomDetailsToJson(this);
}
