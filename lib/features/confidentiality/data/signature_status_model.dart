class SignatureStatusModel {
  final String userId;
  final String workRoomId;
  final String username;
  final String? profilePictureUrl;
  final bool isLawyer;
  final DateTime? signedAt;
  final String? imageFileStorageKey;

  SignatureStatusModel({
    required this.userId,
    required this.workRoomId,
    required this.username,
    this.profilePictureUrl,
    required this.isLawyer,
    this.signedAt,
    this.imageFileStorageKey,
  });

  /// JSON 데이터를 SignatureStatusModel 객체로 변환
  factory SignatureStatusModel.fromJson(Map<String, dynamic> json) {
    return SignatureStatusModel(
      userId: json['user_id'] as String,
      workRoomId: json['work_room_id'] as String,
      username: json['username'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      isLawyer: json['is_lawyer'] as bool,
      signedAt: json['signed_at'] != null ? DateTime.parse(json['signed_at']) : null,
      imageFileStorageKey: json['image_file_storage_key'] as String?,
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'work_room_id': workRoomId,
      'username': username,
      'profile_picture_url': profilePictureUrl,
      'is_lawyer': isLawyer,
      'signed_at': signedAt?.toIso8601String(),
      'image_file_storage_key': imageFileStorageKey,
    };
  }
}
