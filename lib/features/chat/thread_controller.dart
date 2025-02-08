import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/data/thread_model.dart';
import 'package:legalfactfinder2025/features/chat/data/thread_repository.dart';

class ThreadController extends GetxController {
  final ThreadRepository _threadRepository;

  ThreadController(this._threadRepository);

  // Observable for threads
  RxList<Thread> threads = <Thread>[].obs;
  RxBool isThreadsLoading = false.obs;

  Future<void> loadThreads(String workRoomId) async {
    isThreadsLoading.value = true;
    try {
      final List<Thread> fetchedThreads = await _threadRepository.fetchThreads(workRoomId);
      threads.assignAll(fetchedThreads);
    } catch (e) {
      print('Error loading threads: $e');
    } finally {
      isThreadsLoading.value = false;
    }
  }

  Future<void> refreshThreads(String workRoomId) async {
    try {
      final List<Thread> refreshedThreads = await _threadRepository.fetchThreads(workRoomId);
      threads.assignAll(refreshedThreads);
    } catch (e) {
      print('Error refreshing threads: $e');
    }
  }
}
