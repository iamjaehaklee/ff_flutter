import 'package:json_annotation/json_annotation.dart';

part 'friend_model.g.dart';


@JsonSerializable()
class Friend {
  final String username;
  final bool isLawyer;
  final String profilePictureUrl;
  final String id;

  Friend({
    required this.username,
    required this.isLawyer,
    required this.profilePictureUrl,
    required this.id,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);

  Map<String, dynamic> toJson() => _$FriendToJson(this);
}
//flutter pub run build_runner build