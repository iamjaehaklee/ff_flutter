import 'package:get/get.dart';
 import 'package:legalfactfinder2025/features/confidentiality/data/signature_status_model.dart';
import 'package:legalfactfinder2025/features/confidentiality/data/signature_status_repository.dart';

class SignatureStatusController extends GetxController {
  final SignatureStatusRepository repository = SignatureStatusRepository();

  // 작업방 서명 상태를 저장하는 리스트
  var signatures = <SignatureStatusModel>[].obs;

  /// 작업방의 서명 상태를 로드하는 함수
  Future<void> loadSignatures(String workRoomId) async {
    try {
      final fetchedSignatures = await repository.fetchSignatureStatusForWorkRoom(workRoomId);
      signatures.value = fetchedSignatures;
      print('✅ Signatures loaded successfully for workRoomId: $workRoomId');
    } catch (e) {
      print('❌ Error loading signatures: $e');
    }
  }

  /// 서버에서 서명 상태를 다시 가져오는 함수
  Future<void> refreshSignatures(String workRoomId) async {
    print('🔄 Refreshing signatures...');
    await loadSignatures(workRoomId);
  }
}
