import 'package:json_annotation/json_annotation.dart';

part 'folder_model.g.dart';

@JsonSerializable()
class Folder {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'work_room_id')
  final String workRoomId;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'folder_name')
  final String folderName;

  @JsonKey(name: 'folder_path')
  final String folderPath;

  @JsonKey(name: 'parent_folder_id')
  final String? parentFolderId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  const Folder({
    required this.id,
    required this.workRoomId,
    required this.createdBy,
    required this.folderName,
    required this.folderPath,
    this.parentFolderId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Folder.fromJson(Map<String, dynamic> json) => _$FolderFromJson(json);

  Map<String, dynamic> toJson() => _$FolderToJson(this);

  Folder copyWith({
    String? id,
    String? workRoomId,
    String? createdBy,
    String? folderName,
    String? folderPath,
    String? parentFolderId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      workRoomId: workRoomId ?? this.workRoomId,
      createdBy: createdBy ?? this.createdBy,
      folderName: folderName ?? this.folderName,
      folderPath: folderPath ?? this.folderPath,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() {
    return 'Folder(id: $id, workRoomId: $workRoomId, folderName: $folderName, folderPath: $folderPath)';
  }
}