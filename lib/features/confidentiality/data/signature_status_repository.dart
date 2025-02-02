import 'dart:typed_data';
import 'package:legalfactfinder2025/features/confidentiality/data/signature_status_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignatureStatusRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 서명 업로드 메서드
  Future<String?> uploadSignature(String userId, String workRoomId, Uint8List data) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId$timestamp.png';
      final storagePath = '$workRoomId/$fileName';

      print('🔹 Uploading signature...');
      print('  User ID: $userId');
      print('  Work Room ID: $workRoomId');
      print('  File Name: $fileName');
      print('  Storage Path: $storagePath');

      final String? uploadedFilePath = await _supabase.storage
          .from('work_room_signatures')
          .uploadBinary(storagePath, data, fileOptions: const FileOptions(contentType: 'image/png'));

      if (uploadedFilePath == null) {
        print('❌ Upload failed');
        throw Exception('Upload failed');
      }

      print('✅ Signature uploaded to: $uploadedFilePath');
      return storagePath;
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }

  /// 서명 정보를 Supabase DB에 저장하는 메서드
  Future<void> saveSignatureToDatabase(String userId, String workRoomId, String storagePath) async {
    try {
      print('🔹 Saving signature to database...');
      print('  User ID: $userId');
      print('  Work Room ID: $workRoomId');
      print('  Storage Path: $storagePath');

      final response = await _supabase.functions.invoke(
        'put_signature',
        body: {
          "user_id": userId,
          "work_room_id": workRoomId,
          "image_file_storage_key": storagePath,
        },
      );

      if (response.data == null || (response.data is Map && response.data.containsKey('error'))) {
        print('❌ Failed to save signature: ${response.data?['error'] ?? 'Unknown error'}');
        throw Exception('Failed to save signature');
      }

      print('✅ Signature stored in database successfully.');
    } catch (e) {
      print('❌ DB error: $e');
    }
  }

  /// 작업방의 모든 참가자와 서명 정보를 가져오는 메서드
  Future<List<SignatureStatusModel>> fetchSignatureStatusForWorkRoom(String workRoomId) async {
    try {
      print('🔹 Fetching signature status for work room...');
      print('  Work Room ID: $workRoomId');

      final response = await _supabase.functions.invoke(
        'get_signatures_for_work_room',
        body: {
          "p_work_room_id": workRoomId,
        },
      );

      if (response.data == null) {
        print('❌ Response is null');
        throw Exception('Failed to fetch signatures: Response is null');
      }

      // Raw 데이터 로깅
      print('🟢 Raw Response Data: ${response.data}');

      // response.data['data']에 접근하여 리스트로 변환
      final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
      final List<dynamic> data = responseData['data'] as List<dynamic>;

      print('🔹 Parsing response data...');
      final signatures = data.map((item) {
        print('  Parsing item: $item');
        return SignatureStatusModel.fromJson(item as Map<String, dynamic>);
      }).toList();

      print('✅ Successfully fetched and parsed signatures.');
      return signatures;
    } catch (e) {
      print('❌ Error fetching signatures for work room: $e');
      return [];
    }
  }
}
