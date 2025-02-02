import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_model.dart';

class WorkRoomRepository {

  Future<List<WorkRoom>> getWorkRoomsByUserId(String userId) async {
    final url = Uri.parse('$baseUrl/functions/v1/get_work_rooms_by_user_id');

    print("🔵 [REQUEST] Fetching WorkRooms for userId: $userId from $url");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'p_user_id': userId}),
      );

      print("🟢 [RESPONSE] Status Code: ${response.statusCode}");
      print("🟢 Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedResponse);

        print("🔹 Parsed JSON: $responseData");

        // Check if 'work_rooms' is null or absent
        if (responseData is! Map<String, dynamic> || responseData['work_rooms'] == null) {
          print("🔴 No work rooms found or 'work_rooms' key is null.");
          return []; // Return an empty list if no work rooms are found
        }

        final workRooms = (responseData['work_rooms'] as List<dynamic>)
            .map((json) => WorkRoom.fromJson(json))
            .toList();

        print("✅ Successfully fetched ${workRooms.length} WorkRooms!");
        return workRooms;
      } else {
        print("❌ [ERROR] Failed to fetch WorkRooms: ${response.body}");
        throw Exception("Failed to fetch WorkRooms: ${response.body}");
      }
    } catch (e, stackTrace) {
      print("🚨 [EXCEPTION] Error fetching WorkRooms");
      print("🔴 Exception: $e");
      print("🔴 Stack Trace: $stackTrace");
      throw Exception("An unexpected error occurred: $e");
    }
  }



  Future<WorkRoom> getWorkRoomById(String workRoomId) async {
    final url = Uri.parse('$baseUrl/functions/v1/get_work_room_with_participants_json');

    print("🔵 [REQUEST] Fetching WorkRoom details for ID: $workRoomId from $url");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'p_work_room_id': workRoomId}),
      );

      print("🟢 [RESPONSE] Status Code: ${response.statusCode}");
      print("🟢 Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedResponse);

        print("🔹 Parsed JSON: $responseData");

        // Check for `work_room_with_participants` key
        if (responseData is! Map<String, dynamic> || !responseData.containsKey('work_room_with_participants')) {
          throw Exception("Unexpected response format: Missing 'work_room_with_participants' key.");
        }

        final workRoomWithParticipants = responseData['work_room_with_participants'];

        // Extract and parse `work_room`
        if (!workRoomWithParticipants.containsKey('work_room')) {
          throw Exception("Unexpected response format: Missing 'work_room' key.");
        }

        final workRoom = WorkRoom.fromJson(workRoomWithParticipants['work_room']);

        print("✅ Successfully fetched WorkRoom details!");
        return workRoom;
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



  // WorkRoom 생성
  Future<void> createWorkRoom(String title, String description, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/functions/v1/put_work_room'), // constants.dart에서 URL 사용
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken', // constants.dart에서 JWT Token 사용
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'user_id': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create WorkRoom: ${response.body}');
    }
  }
}
