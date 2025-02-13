// import 'package:get/get.dart';
// import 'package:legalfactfinder2025/features/document_annotation/data/annotation_thread_model.dart';
// import 'package:legalfactfinder2025/features/document_annotation/data/annotation_thread_repository.dart';
//
// class AnnotationThreadController extends GetxController {
//   final AnnotationThreadRepository repository;
//
//   AnnotationThreadController({required this.repository});
//
//   // 스레드 목록을 observable로 관리
//   var threads = <AnnotationThreadModel>[].obs;
//   var isLoading = false.obs;
//   var errorMessage = ''.obs;
//
//   /// [fetchThreads] - 특정 annotationId에 대한 모든 스레드를 로드합니다.
//   Future<void> fetchThreads(String annotationId) async {
//     print("[AnnotationThreadController.fetchThreads] Start. annotationId: $annotationId");
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//       final fetchedThreads = await repository.fetchThreads(annotationId);
//       print("[AnnotationThreadController.fetchThreads] Fetched Threads Count: ${fetchedThreads.length}");
//       // 각 스레드 객체 내용 로그 출력
//       for (var thread in fetchedThreads) {
//         print("[AnnotationThreadController.fetchThreads] Thread: ${thread.toJson()}");
//       }
//       threads.assignAll(fetchedThreads);
//       print("[AnnotationThreadController.fetchThreads] Updated threads observable.");
//     } catch (e, stackTrace) {
//       errorMessage.value = 'Failed to fetch threads: $e';
//       print("[AnnotationThreadController.fetchThreads] Error: $e");
//       print("[AnnotationThreadController.fetchThreads] StackTrace: $stackTrace");
//     } finally {
//       isLoading.value = false;
//       print("[AnnotationThreadController.fetchThreads] End. isLoading set to false.");
//     }
//   }
//
//   /// [createThread] - 새로운 스레드를 생성하고 목록에 추가합니다.
//   Future<bool> createThread(AnnotationThreadModel thread) async {
//     print("[AnnotationThreadController.createThread] Start. Input Thread: ${thread.toJson()}");
//     try {
//       isLoading.value = true;
//       final createdThread = await repository.createThread(thread);
//       print("[AnnotationThreadController.createThread] Created Thread: ${createdThread.toJson()}");
//       threads.add(createdThread);
//       print("[AnnotationThreadController.createThread] Added created thread to observable list.");
//       return true;
//     } catch (e, stackTrace) {
//       errorMessage.value = 'Failed to create thread: $e';
//       print("[AnnotationThreadController.createThread] Error: $e");
//       print("[AnnotationThreadController.createThread] StackTrace: $stackTrace");
//       return false;
//     } finally {
//       isLoading.value = false;
//       print("[AnnotationThreadController.createThread] End. isLoading set to false.");
//     }
//   }
//
//   /// [updateThread] - 기존 스레드를 업데이트하고 목록을 갱신합니다.
//   Future<bool> updateThread(AnnotationThreadModel thread) async {
//     print("[AnnotationThreadController.updateThread] Start. Input Thread: ${thread.toJson()}");
//     try {
//       isLoading.value = true;
//       final updatedThread = await repository.updateThread(thread);
//       print("[AnnotationThreadController.updateThread] Updated Thread: ${updatedThread.toJson()}");
//       final index = threads.indexWhere((t) => t.id == updatedThread.id);
//       if (index != -1) {
//         threads[index] = updatedThread;
//         print("[AnnotationThreadController.updateThread] Replaced thread at index $index in observable list.");
//       } else {
//         print("[AnnotationThreadController.updateThread] Updated thread not found in observable list.");
//       }
//       return true;
//     } catch (e, stackTrace) {
//       errorMessage.value = 'Failed to update thread: $e';
//       print("[AnnotationThreadController.updateThread] Error: $e");
//       print("[AnnotationThreadController.updateThread] StackTrace: $stackTrace");
//       return false;
//     } finally {
//       isLoading.value = false;
//       print("[AnnotationThreadController.updateThread] End. isLoading set to false.");
//     }
//   }
//
//   /// [deleteThread] - 특정 스레드를 삭제하고 목록에서 제거합니다.
//   Future<bool> deleteThread(String threadId) async {
//     print("[AnnotationThreadController.deleteThread] Start. threadId: $threadId");
//     try {
//       isLoading.value = true;
//       await repository.deleteThread(threadId);
//       threads.removeWhere((t) => t.id == threadId);
//       print("[AnnotationThreadController.deleteThread] Removed thread with id $threadId from observable list.");
//       return true;
//     } catch (e, stackTrace) {
//       errorMessage.value = 'Failed to delete thread: $e';
//       print("[AnnotationThreadController.deleteThread] Error: $e");
//       print("[AnnotationThreadController.deleteThread] StackTrace: $stackTrace");
//       return false;
//     } finally {
//       isLoading.value = false;
//       print("[AnnotationThreadController.deleteThread] End. isLoading set to false.");
//     }
//   }
// }
