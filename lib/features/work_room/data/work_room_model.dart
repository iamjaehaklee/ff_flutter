import 'package:json_annotation/json_annotation.dart';

part 'work_room_model.g.dart';

@JsonSerializable()
class WorkRoom {
  final String id; // "id" 컬럼
  final String title; // "title" 컬럼
  final String description; // "description" 컬럼
  final DateTime createdAt; // "created_at" 컬럼
  final DateTime updatedAt; // "updated_at" 컬럼
  final List<Participant> participants;

  WorkRoom({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.participants,
  });

  // Null-safe factory method for JSON deserialization
  factory WorkRoom.fromJson(Map<String, dynamic> json) {
    return WorkRoom(
      id: json['work_room_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      participants: (json['participants'] as List<dynamic>?)
          ?.map((participantJson) => Participant.fromJson(participantJson))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => _$WorkRoomToJson(this);
}

@JsonSerializable()
class Participant {
  final String userId;
  final bool isAdmin;
  final String username;
  final String profilePictureUrl;
  final bool isLawyer;

  Participant({
    required this.userId,
    required this.isAdmin,
    required this.username,
    required this.profilePictureUrl,
    required this.isLawyer,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json['user_id'] as String? ?? '',
      isAdmin: json['is_admin'] as bool? ?? false,

      username: json['username'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String? ?? '',
      isLawyer: json['is_lawyer'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$ParticipantToJson(this);
}
