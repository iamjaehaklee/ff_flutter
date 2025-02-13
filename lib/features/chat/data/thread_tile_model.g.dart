// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_tile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadTileModel _$ThreadTileModelFromJson(Map<String, dynamic> json) =>
    ThreadTileModel(
      parent: Message.fromJson(json['parent'] as Map<String, dynamic>),
      child: Message.fromJson(json['child'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ThreadTileModelToJson(ThreadTileModel instance) =>
    <String, dynamic>{
      'parent': instance.parent,
      'child': instance.child,
    };
