// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Thread _$ThreadFromJson(Map<String, dynamic> json) => Thread(
      parentMessage:
          Message.fromJson(json['parent_message'] as Map<String, dynamic>),
      childMessage:
          Message.fromJson(json['child_message'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ThreadToJson(Thread instance) => <String, dynamic>{
      'parent_message': instance.parentMessage,
      'child_message': instance.childMessage,
    };
