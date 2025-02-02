import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/confidentiality/data/signature_status_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MySignatureController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  // 작업방의 서명 상태 목록을 저장할 상태 변수
  var signatureStatusList = <SignatureStatusModel>[].obs;
  /// **서명 정보를 Supabase DB에 저장하는 함수**
  Future<void> saveSignatureToDatabase(String userId, String workRoomId, String storagePath) async {
    try {
      final response = await _supabase.functions.invoke(
        'put_signature', // ✅ Supabase Edge Function 호출
        body: {
          "p_user_id": userId,
          "p_work_room_id": workRoomId,
          "p_image_file_storage_key": storagePath,
        },
      );

      // 응답 결과 확인
      if (response.data == null || (response.data is Map && response.data.containsKey('error'))) {
        throw Exception('Failed to save signature: ${response.data?['error'] ?? 'Unknown error'}');
      }

      print('✅ Signature stored in database successfully.');
    } catch (e) {
      print('❌ Error saving signature in database: $e');
    }
  }
  /// **작업방의 서명 상태를 로드하는 함수**
  Future<void> fetchSignaturesForWorkRoom(String workRoomId) async {
    try {
      final response = await _supabase.functions.invoke(
        'get_signatures_for_work_room', // ✅ Supabase Edge Function 호출
        body: {
          "p_work_room_id": workRoomId,
        },
      );

      if (response.data == null) {
        throw Exception('Failed to fetch signatures: Response is null');
      }

      // 응답 데이터를 모델 리스트로 변환하여 상태 업데이트
      final List<dynamic> data = response.data as List<dynamic>;
      signatureStatusList.value =
          data.map((item) => SignatureStatusModel.fromJson(item)).toList();

      print('✅ Signatures fetched successfully.');
    } catch (e) {
      print('❌ Error fetching signatures for work room: $e');
    }
  }
}
