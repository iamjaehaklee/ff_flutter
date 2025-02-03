import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:legalfactfinder2025/features/chat/data/latest_message_model.dart';

class WorkRoomLatestMessagesRepository {
  final String getWorkRoomLatestMessagesUrl;
  final String jwtToken;

  WorkRoomLatestMessagesRepository({
    required this.getWorkRoomLatestMessagesUrl,
    required this.jwtToken,
  });

  /// Work Room 별 최신 메시지를 가져오는 함수
  /// Work Room 별 최신 메시지를 가져오는 함수
  Future<List<LatestMessageModel>> fetchLatestMessages() async {
    final response = await http.get(
      Uri.parse(getWorkRoomLatestMessagesUrl),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(decodedResponse);
      return data.map((e) => LatestMessageModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception("Failed to fetch latest messages: ${response.body}");
    }
  }
}
