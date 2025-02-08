import 'package:json_annotation/json_annotation.dart';

part 'work_room_participants_model.g.dart';

@JsonSerializable()
class Participant {
  @JsonKey(name: 'user_id')
  final String userId; // work_room_participants 테이블의 "user_id" 컬럼

  @JsonKey(name: 'is_admin')
  final bool isAdmin; // work_room_participants 테이블의 "is_admin" 컬럼

  @JsonKey(name: 'username')
  final String username; // work_room_participants 테이블(또는 join된 users 테이블)의 "username" 컬럼

  // 필드명을 imageFileStorageKey로 변경하고, JSON 키는 "image_file_storage_key"로 매핑합니다.
  @JsonKey(name: 'image_file_storage_key')
  final String imageFileStorageKey;

  @JsonKey(name: 'is_lawyer')
  final bool isLawyer; // work_room_participants 테이블의 "is_lawyer" 컬럼

  Participant({
    required this.userId,
    required this.isAdmin,
    required this.username,
    required this.imageFileStorageKey,
    required this.isLawyer,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json['user_id'] as String? ?? '',
      isAdmin: json['is_admin'] as bool? ?? false,
      username: json['username'] as String? ?? '',
      imageFileStorageKey: json['image_file_storage_key'] as String? ?? '',
      isLawyer: json['is_lawyer'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$ParticipantToJson(this);
} // end of Participant
