// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Friend _$FriendFromJson(Map<String, dynamic> json) => Friend(
      username: json['username'] as String,
      isLawyer: json['isLawyer'] as bool,
      profilePictureUrl: json['profilePictureUrl'] as String,
      id: json['id'] as String,
    );

Map<String, dynamic> _$FriendToJson(Friend instance) => <String, dynamic>{
      'username': instance.username,
      'isLawyer': instance.isLawyer,
      'profilePictureUrl': instance.profilePictureUrl,
      'id': instance.id,
    };
