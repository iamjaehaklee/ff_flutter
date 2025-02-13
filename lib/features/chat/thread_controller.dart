import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/chat/data/thread_repository.dart';
import 'package:legalfactfinder2025/features/chat/data/thread_tile_model.dart';

class ThreadTileListController extends GetxController {
  final ThreadTileListRepository _threadTileListRepository;

  ThreadTileListController(this._threadTileListRepository);

  // Observable for threads
  RxList<ThreadTileModel> threadTileList = <ThreadTileModel>[].obs;
  RxBool isThreadTileListLoading = false.obs;

  Future<void> loadThreadTileList(String workRoomId) async {
    isThreadTileListLoading.value = true;
    try {
      final List<ThreadTileModel> fetchedThreads = await _threadTileListRepository.fetchThreads(workRoomId);
      threadTileList.assignAll(fetchedThreads);
    } catch (e) {
      print('Error loading threads: $e');
    } finally {
      isThreadTileListLoading.value = false;
    }
  }

  Future<void> refreshThreadTileList(String workRoomId) async {
    try {
      final List<ThreadTileModel> refreshedThreadTileList = await _threadTileListRepository.fetchThreads(workRoomId);
      threadTileList.assignAll(refreshedThreadTileList);
    } catch (e) {
      print('Error refreshing threadTileList: $e');
    }
  }
}
