import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:legalfactfinder2025/features/chat/data/thread_tile_model.dart';
import 'package:legalfactfinder2025/core/network/api_exception.dart';

class ThreadTileListRepository {
  final String getThreadsEdgeFunctionUrl;
  final String jwtToken;

  ThreadTileListRepository({
    required this.getThreadsEdgeFunctionUrl,
    required this.jwtToken,
  });

  Future<List<ThreadTileModel>> fetchThreads(String workRoomId) async {
    final uri = Uri.parse(getThreadsEdgeFunctionUrl);
    final requestBody = jsonEncode({"p_work_room_id": workRoomId});

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(decodedResponse);

        List<dynamic> threadsData;
        if (jsonData is List) {
          threadsData = jsonData;
        } else if (jsonData is Map<String, dynamic> && jsonData.containsKey('threads')) {
          threadsData = jsonData['threads'];
        } else {
          throw ApiException(
            "Unexpected response format: Expected a JSON array or a map with a 'threads' key.",
            response.statusCode,
          );
        }

        return threadsData
            .map((threadJson) => ThreadTileModel.fromJson(threadJson as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          "Failed to fetch threads",
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("An unexpected error occurred", 500, e.toString());
    }
  }
}
