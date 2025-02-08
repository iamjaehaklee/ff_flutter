import 'package:json_annotation/json_annotation.dart';
import 'message_model.dart';

part 'thread_model.g.dart';

@JsonSerializable()
class Thread {
  @JsonKey(name: 'parent_message')
  final Message parentMessage;

  @JsonKey(name: 'child_message')
  final Message childMessage;

  Thread({
    required this.parentMessage,
    required this.childMessage,
  });

  factory Thread.fromJson(Map<String, dynamic> json) =>
      _$ThreadFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadToJson(this);
}
