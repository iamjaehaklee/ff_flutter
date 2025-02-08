import 'package:json_annotation/json_annotation.dart';

part 'work_room_model.g.dart';

@JsonSerializable()
class WorkRoom {
  @JsonKey(name: 'work_room_id')
  final String id; // API에서 반환되는 work_room_id

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  WorkRoom({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkRoom.fromJson(Map<String, dynamic> json) {
    print("[WorkRoom.fromJson] Received JSON: $json");

    // id 필드 파싱
    final id = json['work_room_id'] as String? ?? "";
    print("[WorkRoom.fromJson] Parsed id: $id (type: ${id.runtimeType})");

    // title 필드 파싱
    final title = json['title'] as String? ?? "";
    print("[WorkRoom.fromJson] Parsed title: $title (type: ${title.runtimeType})");

    // description 필드 파싱
    final description = json['description'] as String?;
    print("[WorkRoom.fromJson] Parsed description: $description (type: ${description?.runtimeType})");

    // created_at 필드 파싱
    final createdAtStr = json['created_at'] as String? ?? "";
    print("[WorkRoom.fromJson] Parsed created_at string: $createdAtStr (type: ${createdAtStr.runtimeType})");
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(createdAtStr);
    } catch (e) {
      print("[WorkRoom.fromJson] Error parsing created_at: $e");
      createdAt = DateTime.now();
    }

    // updated_at 필드 파싱
    final updatedAtStr = json['updated_at'] as String? ?? "";
    print("[WorkRoom.fromJson] Parsed updated_at string: $updatedAtStr (type: ${updatedAtStr.runtimeType})");
    DateTime updatedAt;
    try {
      updatedAt = DateTime.parse(updatedAtStr);
    } catch (e) {
      print("[WorkRoom.fromJson] Error parsing updated_at: $e");
      updatedAt = DateTime.now();
    }

    final workRoom = WorkRoom(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
    print("[WorkRoom.fromJson] Constructed WorkRoom object: ${workRoom.toJson()}");
    return workRoom;
  } // end of fromJson

  Map<String, dynamic> toJson() => _$WorkRoomToJson(this);
} // end of WorkRoom
