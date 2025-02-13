// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:legalfactfinder2025/constants.dart';
// import 'package:legalfactfinder2025/features/document_annotation/data/annotation_thread_model.dart';
//
// class AnnotationThreadRepository {
//   AnnotationThreadRepository();
//
//   /// [fetchThreads] - 지정된 annotationId에 대한 모든 스레드 목록을 가져옵니다.
//   Future<List<AnnotationThreadModel>> fetchThreads(String annotationId) async {
//     print("[AnnotationThreadRepository.fetchThreads] Start. annotationId: $annotationId");
//
//     final url = Uri.parse(getAnnotationThreadsByAnnotationIdEdgeFunctionUrl);
//     print("[AnnotationThreadRepository.fetchThreads] URL: $url");
//     print("[AnnotationThreadRepository.fetchThreads] Headers: {'Authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json'}");
//     final requestBody = jsonEncode({'annotation_id': annotationId});
//     print("[AnnotationThreadRepository.fetchThreads] Request Body: $requestBody");
//
//     final response = await http.post(url,
//         headers: {
//           'Authorization': 'Bearer $jwtToken',
//           'Content-Type': 'application/json',
//         },
//         body: requestBody);
//
//     print("[AnnotationThreadRepository.fetchThreads] Response Status: ${response.statusCode}");
//     print("[AnnotationThreadRepository.fetchThreads] Response Body: ${response.body}");
//
//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       print("[AnnotationThreadRepository.fetchThreads] Parsed JSON Data: $data");
//       final threads = data.map((e) {
//         final thread = AnnotationThreadModel.fromJson(e);
//         print("[AnnotationThreadRepository.fetchThreads] Parsed Thread: ${jsonEncode(thread.toJson())}");
//         return thread;
//       }).toList();
//       print("[AnnotationThreadRepository.fetchThreads] Returning ${threads.length} threads.");
//       return threads;
//     } else {
//       print("[AnnotationThreadRepository.fetchThreads] Error: ${response.body}");
//       throw Exception("Failed to fetch annotation threads: ${response.body}");
//     }
//   }
//
//   /// [createThread] - 새로운 어노테이션 스레드를 생성합니다.
//   Future<AnnotationThreadModel> createThread(AnnotationThreadModel thread) async {
//     print("[AnnotationThreadRepository.createThread] Start. Thread Data: ${jsonEncode(thread.toJson())}");
//
//     final url = Uri.parse(putAnnotationThreadEdgeFunctionUrl);
//     print("[AnnotationThreadRepository.createThread] URL: $url");
//     final requestBody = jsonEncode(thread.toJson());
//     print("[AnnotationThreadRepository.createThread] Request Body: $requestBody");
//
//     final response = await http.post(url,
//         headers: {
//           'Authorization': 'Bearer $jwtToken',
//           'Content-Type': 'application/json',
//         },
//         body: requestBody);
//
//     print("[AnnotationThreadRepository.createThread] Response Status: ${response.statusCode}");
//     print("[AnnotationThreadRepository.createThread] Response Body: ${response.body}");
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final threadJson = jsonDecode(response.body);
//       print("[AnnotationThreadRepository.createThread] Parsed Thread JSON: $threadJson");
//       final createdThread = AnnotationThreadModel.fromJson(threadJson);
//       print("[AnnotationThreadRepository.createThread] Created Thread: ${jsonEncode(createdThread.toJson())}");
//       return createdThread;
//     } else {
//       print("[AnnotationThreadRepository.createThread] Error: ${response.body}");
//       throw Exception("Failed to create annotation thread: ${response.body}");
//     }
//   }
//
//   /// [updateThread] - 기존의 어노테이션 스레드를 업데이트합니다.
//   Future<AnnotationThreadModel> updateThread(AnnotationThreadModel thread) async {
//     print("[AnnotationThreadRepository.updateThread] Start. Thread Data: ${jsonEncode(thread.toJson())}");
//
//     final url = Uri.parse(updateAnnotationThreadEdgeFunctionUrl);
//     print("[AnnotationThreadRepository.updateThread] URL: $url");
//     final requestBody = jsonEncode(thread.toJson());
//     print("[AnnotationThreadRepository.updateThread] Request Body: $requestBody");
//
//     final response = await http.put(url,
//         headers: {
//           'Authorization': 'Bearer $jwtToken',
//           'Content-Type': 'application/json',
//         },
//         body: requestBody);
//
//     print("[AnnotationThreadRepository.updateThread] Response Status: ${response.statusCode}");
//     print("[AnnotationThreadRepository.updateThread] Response Body: ${response.body}");
//
//     if (response.statusCode == 200) {
//       final threadJson = jsonDecode(response.body);
//       print("[AnnotationThreadRepository.updateThread] Parsed Thread JSON: $threadJson");
//       final updatedThread = AnnotationThreadModel.fromJson(threadJson);
//       print("[AnnotationThreadRepository.updateThread] Updated Thread: ${jsonEncode(updatedThread.toJson())}");
//       return updatedThread;
//     } else {
//       print("[AnnotationThreadRepository.updateThread] Error: ${response.body}");
//       throw Exception("Failed to update annotation thread: ${response.body}");
//     }
//   }
//
//   /// [deleteThread] - 특정 어노테이션 스레드를 삭제합니다.
//   Future<void> deleteThread(String threadId) async {
//     print("[AnnotationThreadRepository.deleteThread] Start. threadId: $threadId");
//
//     final url = Uri.parse(deleteAnnotationThreadEdgeFunctionUrl);
//     print("[AnnotationThreadRepository.deleteThread] URL: $url");
//     final requestBody = jsonEncode({'id': threadId});
//     print("[AnnotationThreadRepository.deleteThread] Request Body: $requestBody");
//
//     final response = await http.delete(url,
//         headers: {
//           'Authorization': 'Bearer $jwtToken',
//           'Content-Type': 'application/json',
//         },
//         body: requestBody);
//
//     print("[AnnotationThreadRepository.deleteThread] Response Status: ${response.statusCode}");
//     print("[AnnotationThreadRepository.deleteThread] Response Body: ${response.body}");
//
//     if (response.statusCode != 200) {
//       print("[AnnotationThreadRepository.deleteThread] Error: ${response.body}");
//       throw Exception("Failed to delete annotation thread: ${response.body}");
//     } else {
//       print("[AnnotationThreadRepository.deleteThread] Thread deleted successfully.");
//     }
//   }
// }
