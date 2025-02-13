import 'package:json_annotation/json_annotation.dart';

part 'file_model.g.dart';

@JsonSerializable()
class FileData {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'storage_key')
  final String storageKey;

  @JsonKey(name: 'storage_path')
  final String? storagePath;

  @JsonKey(name: 'file_name')
  final String fileName;

  @JsonKey(name: 'file_type')
  final String fileType;

  @JsonKey(name: 'file_size')
  final int fileSize;

  @JsonKey(name: 'uploaded_at')
  final DateTime uploadedAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @JsonKey(name: 'work_room_id')
  final String workRoomId;

  @JsonKey(name: 'uploader_id')
  final String uploaderId;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'is_deleted', defaultValue: false)
  final bool isDeleted;

  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  FileData({
    required this.id,
    required this.storageKey,
    this.storagePath,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.uploadedAt,
    required this.updatedAt,
    required this.workRoomId,
    required this.uploaderId,
    this.description,
    required this.isDeleted,
    this.deletedAt,
  });

  factory FileData.fromJson(Map<String, dynamic> json) {
    print("[FileData.fromJson] Received JSON: $json");

    // id 파싱
    final id = json['id'] as String? ?? "";
    print("[FileData.fromJson] id: $id");

    // storage_key 파싱
    final storageKey = json['storage_key'] as String? ?? "";
    print("[FileData.fromJson] storageKey: $storageKey");

    // storage_path 파싱
    final storagePath = json['storage_path'] as String?;
    print("[FileData.fromJson] storagePath: $storagePath");

    // file_name 파싱
    final fileName = json['file_name'] as String? ?? "";
    print("[FileData.fromJson] fileName: $fileName");

    // file_type 파싱
    final fileType = json['file_type'] as String? ?? "";
    print("[FileData.fromJson] fileType: $fileType");

    // file_size 파싱
    final fileSizeValue = json['file_size'];
    int fileSize;
    if (fileSizeValue is int) {
      fileSize = fileSizeValue;
    } else if (fileSizeValue is String) {
      fileSize = int.tryParse(fileSizeValue) ?? 0;
    } else {
      fileSize = 0;
    }
    print("[FileData.fromJson] fileSize: $fileSize");

    // uploaded_at 파싱
    final uploadedAtStr = json['uploaded_at'] as String? ?? "";
    DateTime uploadedAt;
    try {
      uploadedAt = DateTime.parse(uploadedAtStr);
    } catch (e) {
      print("[FileData.fromJson] Error parsing uploaded_at: $e");
      uploadedAt = DateTime.now();
    }
    print("[FileData.fromJson] uploadedAt: $uploadedAt");

    // updated_at 파싱
    final updatedAtStr = json['updated_at'] as String? ?? "";
    DateTime updatedAt;
    try {
      updatedAt = DateTime.parse(updatedAtStr);
    } catch (e) {
      print("[FileData.fromJson] Error parsing updated_at: $e");
      updatedAt = DateTime.now();
    }
    print("[FileData.fromJson] updatedAt: $updatedAt");

    // work_room_id 파싱
    final workRoomId = json['work_room_id'] as String? ?? "";
    print("[FileData.fromJson] workRoomId: $workRoomId");

    // uploader_id 파싱
    final uploaderId = json['uploader_id'] as String? ?? "";
    print("[FileData.fromJson] uploaderId: $uploaderId");

    // description 파싱
    final description = json['description'] as String?;
    print("[FileData.fromJson] description: $description");

    // is_deleted 파싱
    final isDeleted = json['is_deleted'] as bool? ?? false;
    print("[FileData.fromJson] isDeleted: $isDeleted");

    // deleted_at 파싱
    final deletedAtStr = json['deleted_at'] as String?;
    DateTime? deletedAt;
    if (deletedAtStr != null && deletedAtStr.isNotEmpty) {
      try {
        deletedAt = DateTime.parse(deletedAtStr);
      } catch (e) {
        print("[FileData.fromJson] Error parsing deleted_at: $e");
        deletedAt = null;
      }
    }
    print("[FileData.fromJson] deletedAt: $deletedAt");

    final fileData = FileData(
      id: id,
      storageKey: storageKey,
      storagePath: storagePath,
      fileName: fileName,
      fileType: fileType,
      fileSize: fileSize,
      uploadedAt: uploadedAt,
      updatedAt: updatedAt,
      workRoomId: workRoomId,
      uploaderId: uploaderId,
      description: description,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
    );
    print("[FileData.fromJson] Constructed FileData: ${fileData.toJson()}");
    return fileData;
  }

  Map<String, dynamic> toJson() => _$FileDataToJson(this);
}
