import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String username;
  final String? imageFileStorageKey; // ✅ 필드명 변경

  UserModel({
    required this.id,
    required this.username,
    this.imageFileStorageKey, // ✅ 변경된 필드 반영
  });

  /// JSON → 객체 변환 (fromJson)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? 'Unknown',
      imageFileStorageKey: json['image_file_storage_key'] as String?, // ✅ 변경된 필드 반영
    );
  }

  /// 객체 → JSON 변환 (toJson)
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
//flutter pub run build_runner build