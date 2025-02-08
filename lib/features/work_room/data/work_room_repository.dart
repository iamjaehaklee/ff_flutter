import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_with_participants_model.dart';

class WorkRoomRepository {
  /// [WorkRoomRepository.getWorkRoomsWithParticipantsByUserId]
  /// Fetches a list of WorkRoomWithParticipants for the given userId.
  Future<List<WorkRoomWithParticipants>> getWorkRoomsWithParticipantsByUserId(String userId) async {
    final url = Uri.parse('$baseUrl/functions/v1/get_work_rooms_with_participants_by_user_id');
    print("🔵 [WorkRoomRepository.getWorkRoomsWithParticipantsByUserId] Called with userId: $userId, URL: $url");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'p_user_id': userId}),
      );
      print("🟢 [WorkRoomRepository.getWorkRoomsWithParticipantsByUserId] Response Status Code: ${response.statusCode}");
      print("🟢 [WorkRoomRepository.getWorkRoomsWithParticipantsByUserId] Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedResponse);
        print("🔹 [WorkRoomRepository.getWorkRoomsWithParticipantsByUserId] Parsed JSON (type: ${responseData.runtimeType}): $responseData");

        List<WorkRoomWithParticipants> result = [];

        // CASE 1: The top-level JSON is a List.
        if (responseData is List) {
          print("🔹 [WorkRoomRepository.getWorkRoomsWithParticipantsByUserId] Response is a List.");
          result = responseData.map((element) {
            print("🔍 [WorkRoomRepository.getWorkRoomsWithParticipantsByUserId] Processing element: $element");
            if (element is Map<String, dynamic> && element.containsKey("work_room_with_participants")) {
              final data = element["work_room_with_participants"];
              print("🔍 [WorkRoomRepository.getWorkRoomsWithParticipantsByUserId] Found key 'work_room_with_participants': $data");
              if (data is Map<String, dynamic>) {
                return WorkRoomWithParticipants.fromJson(data);
              } else {
                throw Exception("Unexpected type for work_room_with_participants: ${data.runtimeType}");
              }
            } else {
              print("🔴 [WorkRoomRepository.getWorkRoomsWithParticipantsByUserId] Element does not contain key 'work_room_with_participants'. Skipping.");
              return null;
            }
          }).where((element) => element != null).cast<WorkRoomWithParticipants>().toList();
        }
         else {
          print("🔴 [WorkRoomRepository.getWorkRoomsWithParticipantsByUserId] Unexpected JSON structure: ${responseData.runtimeType}");
          return [];
        }

        print("✅ [WorkRoomRepository.getWorkRoomsWithParticipantsByUserId] Successfully fetched ${result.length} workRoomWithParticipants.");
        return result;
      } else {
        print("❌ [WorkRoomRepository.getWorkRoomsWithParticipantsByUserId] Failed with response body: ${response.body}");
        throw Exception("Failed to fetch workRoomsWithParticipants: ${response.body}");
      }
    } catch (e, stackTrace) {
      print("🚨 [WorkRoomRepository.getWorkRoomsWithParticipantsByUserId] Exception: $e");
      print("🚨 [WorkRoomRepository.getWorkRoomsWithParticipantsByUserId] Stack Trace: $stackTrace");
      throw Exception("An unexpected error in getWorkRoomsWithParticipantsByUserId: $e");
    }
  } // end of getWorkRoomsWithParticipantsByUserIdof getWorkRoomsWithParticipantsByUserId

  /// [WorkRoomRepository.getWorkRoomWithParticipantsById]
  /// 지정된 workRoomId로 워크룸 상세 정보를 가져옵니다.
  Future<WorkRoomWithParticipants> getWorkRoomWithParticipantsById(String workRoomId) async {
    final url = Uri.parse('$baseUrl/functions/v1/get_work_room_with_participants_json');
    print("🔵 [WorkRoomRepository.getWorkRoomWithParticipantsById] Called with workRoomId: $workRoomId, URL: $url");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'p_work_room_id': workRoomId}),
      );
      print("🟢 [WorkRoomRepository.getWorkRoomWithParticipantsById] Response Status Code: ${response.statusCode}");
      print("🟢 [WorkRoomRepository.getWorkRoomWithParticipantsById] Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedResponse);
        print("🔹 [WorkRoomRepository.getWorkRoomWithParticipantsById] Parsed JSON: $responseData");

        if (responseData is! Map<String, dynamic> || !responseData.containsKey('work_room_with_participants')) {
          throw Exception("Unexpected response format: Missing 'work_room_with_participants' key.");
        }

        final workRoomWithParticipantsData = responseData['work_room_with_participants'];
        if (!workRoomWithParticipantsData.containsKey('work_room')) {
          throw Exception("Unexpected response format: Missing 'work_room' key.");
        }

        WorkRoomWithParticipants workRoomWithParticipants = WorkRoomWithParticipants.fromJson(workRoomWithParticipantsData);
        print("✅ [WorkRoomRepository.getWorkRoomWithParticipantsById] Successfully fetched WorkRoom details: ${workRoomWithParticipants.toJson()}");
        return workRoomWithParticipants;
      } else {
        print("❌ [WorkRoomRepository.getWorkRoomWithParticipantsById] Failed with response body: ${response.body}");
        throw Exception("Failed to fetch WorkRoom details: ${response.body}");
      }
    } catch (e, stackTrace) {
      print("🚨 [WorkRoomRepository.getWorkRoomWithParticipantsById] Exception: $e");
      print("🚨 [WorkRoomRepository.getWorkRoomWithParticipantsById] Stack Trace: $stackTrace");
      throw Exception("An unexpected error in getWorkRoomWithParticipantsById: $e");
    }
  } // end of getWorkRoomWithParticipantsById

  /// [WorkRoomRepository.createWorkRoom]
  /// 새 워크룸을 생성합니다.
  Future<void> createWorkRoom(String title, String description, String userId) async {
    final url = Uri.parse('$baseUrl/functions/v1/put_work_room');
    print("🔵 [WorkRoomRepository.createWorkRoom] Called with title: $title, description: $description, userId: $userId, URL: $url");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'user_id': userId,
      }),
    );
    print("🟢 [WorkRoomRepository.createWorkRoom] Response Status Code: ${response.statusCode}");
    print("🟢 [WorkRoomRepository.createWorkRoom] Raw Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to create WorkRoom: ${response.body}');
    }
  } // end of createWorkRoom

  /// [WorkRoomRepository.updateWorkRoom]
  /// 워크룸의 제목과/또는 설명을 업데이트합니다.
  Future<Map<String, dynamic>> updateWorkRoom(String workRoomId, {String? title, String? description}) async {
    final url = Uri.parse('$baseUrl/functions/v1/update_work_room');
    // payload 구성 시 null인 경우 키 자체를 제거하여 업데이트에서 제외합니다.
    final payload = <String, dynamic>{ 'p_work_room_id': workRoomId };
    if (title != null) payload['p_title'] = title;
    if (description != null) payload['p_description'] = description;

    print("🔵 [WorkRoomRepository.updateWorkRoom] Called with workRoomId: $workRoomId, title: $title, description: $description, URL: $url");
    print("🔵 [WorkRoomRepository.updateWorkRoom] Payload: ${jsonEncode(payload)}");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode(payload),
    );
    print("🟢 [WorkRoomRepository.updateWorkRoom] Response Status Code: ${response.statusCode}");
    print("🟢 [WorkRoomRepository.updateWorkRoom] Raw Body: ${response.body}");

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(decodedResponse);
      print("🔹 [WorkRoomRepository.updateWorkRoom] Parsed JSON: $jsonData");

      if (jsonData is Map<String, dynamic> && jsonData.containsKey('work_room')) {
        final workRoomList = jsonData['work_room'];
        if (workRoomList is List && workRoomList.isNotEmpty) {
          print("✅ [WorkRoomRepository.updateWorkRoom] Returning updated work room data: ${workRoomList.first}");
          return workRoomList.first as Map<String, dynamic>;
        } else {
          throw Exception("No work room returned in the list.");
        }
      } else {
        throw Exception("Unexpected response format: missing 'work_room' key.");
      }
    } else {
      throw Exception("Failed to update work room: ${response.body}");
    }
  } // end of updateWorkRoom
} // end of WorkRoomRepository
