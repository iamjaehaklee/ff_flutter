import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_details_model.dart';

class WorkRoomDetailsRepository {
  Future<WorkRoomDetails> getWorkRoomDetails(String workRoomId) async {
    final url = Uri.parse('$baseUrl/functions/v1/get_work_room_details_json');

    print("🔵 [REQUEST] Fetching WorkRoom details for ID: $workRoomId from $url");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'work_room_id': workRoomId}),
      );

      print("🟢 [RESPONSE] Status Code: ${response.statusCode}");
      print("🟢 Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedResponse);

        print("🔹 Parsed JSON: $responseData");

        if (responseData is! Map<String, dynamic> || !responseData.containsKey('work_room_details')) {
          throw Exception("Unexpected response format: Missing 'work_room_details' key.");
        }

        final workRoomDetails = WorkRoomDetails.fromJson(responseData['work_room_details']);

        print("✅ Successfully fetched WorkRoom details!");
        return workRoomDetails;
      } else {
        print("❌ [ERROR] Failed to fetch WorkRoom details: ${response.body}");
        throw Exception("Failed to fetch WorkRoom details: ${response.body}");
      }
    } catch (e, stackTrace) {
      print("🚨 [EXCEPTION] Error fetching WorkRoom details");
      print("🔴 Exception: $e");
      print("🔴 Stack Trace: $stackTrace");
      throw Exception("An unexpected error occurred: $e");
    }
  }
}
