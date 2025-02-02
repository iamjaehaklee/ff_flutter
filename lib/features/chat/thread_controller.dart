import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/data/thread_model.dart';
import 'package:legalfactfinder2025/features/chat/data/thread_repository.dart';

class ThreadController extends GetxController {
  final ThreadRepository _threadRepository;

  ThreadController(this._threadRepository);

  // Observable for threads
  var threads = <Thread>[].obs;
  var isThreadsLoading = false.obs; // Loading state for threads

  // Fetch threads for a specific work room
  Future<void> loadThreads(String workRoomId) async {
    isThreadsLoading.value = true; // Start loading
    try {
      final fetchedThreads = await _threadRepository.fetchThreads(workRoomId);
      threads.value = fetchedThreads; // Update the observable list
    } catch (e) {
      print('Error loading threads: $e');
    } finally {
      isThreadsLoading.value = false; // End loading
    }
  }

  // Refresh threads for real-time updates
  Future<void> refreshThreads(String workRoomId) async {
    try {
      final refreshedThreads = await _threadRepository.fetchThreads(workRoomId);
      threads.value = refreshedThreads; // Update threads with refreshed data
    } catch (e) {
      print('Error refreshing threads: $e');
    }
  }
}
