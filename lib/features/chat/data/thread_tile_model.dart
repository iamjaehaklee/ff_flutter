import 'package:json_annotation/json_annotation.dart';
import 'message_model.dart';

part 'thread_tile_model.g.dart';

@JsonSerializable()
class ThreadTileModel {
  @JsonKey(name: 'parent')
  final Message parent; // Message 타입으로 제한

  @JsonKey(name: 'child')
  final Message child;

  ThreadTileModel({
    required this.parent,
    required this.child,
  });

  factory ThreadTileModel.fromJson(Map<String, dynamic> json) =>
      _$ThreadTileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadTileModelToJson(this);
}
