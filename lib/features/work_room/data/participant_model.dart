import 'package:json_annotation/json_annotation.dart';

part 'participant_model.g.dart';

@JsonSerializable()
class Participant {
  @JsonKey(name: 'user_id')
  final String userId; // work_room_participants 테이블의 "user_id"

  @JsonKey(name: 'is_admin', defaultValue: false)
  final bool isAdmin; // work_room_participants 테이블의 "is_admin"

  @JsonKey(name: 'username')
  final String username; // work_room_participants 또는 조인된 users 테이블의 "username"

  // 정확한 컬럼명인 image_file_storage_key를 사용 (기본값은 빈 문자열)
  @JsonKey(name: 'image_file_storage_key', defaultValue: '')
  final String imageFileStorageKey; // work_room_participants 테이블의 "image_file_storage_key"

  @JsonKey(name: 'is_lawyer', defaultValue: false)
  final bool isLawyer; // work_room_participants 테이블의 "is_lawyer"

  @JsonKey(name: 'joined_at')
  final DateTime joinedAt; // work_room_participants 테이블의 "joined_at"

  @JsonKey(name: 'last_seen')
  final DateTime lastSeen; // work_room_participants 테이블의 "last_seen"

  Participant({
    required this.userId,
    required this.isAdmin,
    required this.username,
    required this.imageFileStorageKey,
    required this.isLawyer,
    required this.joinedAt,
    required this.lastSeen,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    print("[Participant.fromJson] Received JSON: $json");

    // userId 파싱
    final userId = json['user_id'] as String? ?? "";
    print("[Participant.fromJson] userId: $userId (type: ${userId.runtimeType})");

    // isAdmin 파싱
    final isAdmin = json['is_admin'] as bool? ?? false;
    print("[Participant.fromJson] isAdmin: $isAdmin (type: ${isAdmin.runtimeType})");

    // username 파싱
    final username = json['username'] as String? ?? "";
    print("[Participant.fromJson] username: $username (type: ${username.runtimeType})");

    // image_file_storage_key 파싱
    final imageFileStorageKey = json['image_file_storage_key'] as String? ?? "";
    print("[Participant.fromJson] imageFileStorageKey: $imageFileStorageKey (type: ${imageFileStorageKey.runtimeType})");

    // isLawyer 파싱
    final isLawyer = json['is_lawyer'] as bool? ?? false;
    print("[Participant.fromJson] isLawyer: $isLawyer (type: ${isLawyer.runtimeType})");

    // joined_at 파싱
    final joinedAtStr = json['joined_at'] as String? ?? "";
    print("[Participant.fromJson] joined_at string: $joinedAtStr (type: ${joinedAtStr.runtimeType})");
    DateTime joinedAt;
    try {
      joinedAt = DateTime.parse(joinedAtStr);
    } catch (e) {
      print("[Participant.fromJson] Error parsing joined_at: $e");
      joinedAt = DateTime.now();
    }

    // last_seen 파싱
    final lastSeenStr = json['last_seen'] as String? ?? "";
    print("[Participant.fromJson] last_seen string: $lastSeenStr (type: ${lastSeenStr.runtimeType})");
    DateTime lastSeen;
    try {
      lastSeen = DateTime.parse(lastSeenStr);
    } catch (e) {
      print("[Participant.fromJson] Error parsing last_seen: $e");
      lastSeen = DateTime.now();
    }

    final participant = Participant(
      userId: userId,
      isAdmin: isAdmin,
      username: username,
      imageFileStorageKey: imageFileStorageKey,
      isLawyer: isLawyer,
      joinedAt: joinedAt,
      lastSeen: lastSeen,
    );
    print("[Participant.fromJson] Constructed Participant: ${participant.toJson()}");
    return participant;
  } // end of fromJson

  Map<String, dynamic> toJson() => _$ParticipantToJson(this);
} // end of Participant
