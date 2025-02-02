import 'package:json_annotation/json_annotation.dart';

part 'file_model.g.dart';

@JsonSerializable()
class FileData {
  final String id;
  final String storageKey;
  final String fileName;
  final String fileType;
  final int fileSize;
  final DateTime uploadedAt;
  final DateTime updatedAt;
  final String workRoomId;
  final String uploaderId;
  final String? description;
  final bool isDeleted;
  final DateTime? deletedAt;

  FileData({
    required this.id,
    required this.storageKey,
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

  factory FileData.fromJson(Map<String, dynamic> json) => _$FileDataFromJson(json);

  Map<String, dynamic> toJson() => _$FileDataToJson(this);
}
//flutter pub run build_runner build