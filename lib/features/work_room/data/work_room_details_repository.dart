import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_details_model.dart';

class WorkRoomDetailsRepository {
  Future<WorkRoomDetails> getWorkRoomDetails(String workRoomId) async {
    final url = Uri.parse('$baseUrl/functions/v1/get_work_room_details_json');

    print("🔵 [REQUEST] Starting getWorkRoomDetails for workRoomId: $workRoomId");
    print("🔵 [REQUEST] URL: $url");

    final requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken', // 주의: 실제 운영 시 토큰 노출 주의
    };
    print("🔵 [REQUEST] Headers: ${jsonEncode(requestHeaders)}");

    final requestBody = jsonEncode({'work_room_id': workRoomId});
    print("🔵 [REQUEST] Body: $requestBody");

    try {
      final response = await http.post(
        url,
        headers: requestHeaders,
        body: requestBody,
      );

      print("🟢 [RESPONSE] Received response.");
      print("🟢 [RESPONSE] Status Code: ${response.statusCode}");
      print("🟢 [RESPONSE] Response Headers: ${response.headers}");
      print("🟢 [RESPONSE] Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        print("🟢 [RESPONSE] Decoded Response Body: $decodedResponse");

        final dynamic responseData = jsonDecode(decodedResponse);
        print("🟢 [RESPONSE] Parsed JSON Data: $responseData");

        if (responseData is! Map<String, dynamic>) {
          print("❌ [ERROR] Parsed JSON is not a Map<String, dynamic>: $responseData");
          throw Exception("Unexpected response format: Expected a JSON object.");
        }

        if (!responseData.containsKey('work_room_details')) {
          print("❌ [ERROR] JSON missing 'work_room_details' key. Full JSON: $responseData");
          throw Exception("Unexpected response format: Missing 'work_room_details' key.");
        }

        final workRoomDetailsJson = responseData['work_room_details'];
        print("🟢 [RESPONSE] work_room_details JSON: $workRoomDetailsJson");

        final workRoomDetails = WorkRoomDetails.fromJson(workRoomDetailsJson);
        print("✅ [SUCCESS] WorkRoom details parsed successfully.");
        print("✅ [SUCCESS] WorkRoom details: ${workRoomDetails.toJson()}");

        return workRoomDetails;
      } else {
        print("❌ [ERROR] HTTP error. Status Code: ${response.statusCode}");
        print("❌ [ERROR] Response Body: ${response.body}");
        throw Exception("Failed to fetch WorkRoom details: ${response.body}");
      }
    } catch (e, stackTrace) {
      print("🚨 [EXCEPTION] Error occurred in getWorkRoomDetails:");
      print("🔴 Exception: $e");
      print("🔴 Stack Trace: $stackTrace");
      throw Exception("An unexpected error occurred: $e");
    }
  }
}
