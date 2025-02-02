class SignatureModel {
  final String id; // 고유 ID (UUID)
  final String userId; // 사용자 ID (users 테이블 참조)
  final String workRoomId; // 작업 방 ID (work_rooms 테이블 참조)
  final DateTime? signedAt; // 서명 날짜 및 시간
  final String imageFileStorageKey; // 서명 이미지 파일 스토리지 키

  SignatureModel({
    required this.id,
    required this.userId,
    required this.workRoomId,
    this.signedAt,
    required this.imageFileStorageKey,
  });

  // JSON 데이터를 객체로 변환하는 메서드
  factory SignatureModel.fromJson(Map<String, dynamic> json) {
    return SignatureModel(
      id: json['id'],
      userId: json['user_id'],
      workRoomId: json['work_room_id'],
      signedAt: json['signed_at'] != null
          ? DateTime.parse(json['signed_at'])
          : null,
      imageFileStorageKey: json['image_file_storage_key'] ?? '',
    );
  }

  // 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'work_room_id': workRoomId,
      'signed_at': signedAt?.toIso8601String(),
      'image_file_storage_key': imageFileStorageKey,
    };
  }
}
