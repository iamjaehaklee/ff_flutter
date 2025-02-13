// import 'package:json_annotation/json_annotation.dart';
//
// part 'annotation_thread_model.g.dart';
//
// @JsonSerializable()
// class AnnotationThreadModel {
//   @JsonKey(name: 'id')
//   final String id;
//
//   @JsonKey(name: 'content')
//   final String content;
//
//   @JsonKey(name: 'annotation_id')
//   final String annotationId;
//
//   @JsonKey(name: 'created_by')
//   final String createdBy;
//
//   @JsonKey(name: 'created_at')
//   final DateTime? createdAt;
//
//   @JsonKey(name: 'updated_at')
//   final DateTime? updatedAt;
//
//   AnnotationThreadModel({
//     required this.id,
//     required this.content,
//     required this.annotationId,
//     required this.createdBy,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   factory AnnotationThreadModel.fromJson(Map<String, dynamic> json) {
//     print("[AnnotationThreadModel.fromJson] Received JSON: $json");
//
//     DateTime? parseDate(String? dateStr) {
//       if (dateStr == null || dateStr.isEmpty) return null;
//       try {
//         return DateTime.parse(dateStr);
//       } catch (e) {
//         print("[AnnotationThreadModel.fromJson] Error parsing date: $e");
//         return null;
//       }
//     }
//
//     final model = AnnotationThreadModel(
//       id: json['id'] as String,
//       content: json['content'] as String,
//       annotationId: json['annotation_id'] as String,
//       createdBy: json['created_by'] as String,
//       createdAt: parseDate(json['created_at'] as String?),
//       updatedAt: parseDate(json['updated_at'] as String?),
//     );
//     print("[AnnotationThreadModel.fromJson] Constructed Model: ${model.toJson()}");
//     return model;
//   }
//
//   Map<String, dynamic> toJson() => _$AnnotationThreadModelToJson(this);
// }
