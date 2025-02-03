import 'dart:convert';
import 'package:http/http.dart' as http;

class UsersRepository {
  final String getUsersByIdsUrl;
  final String jwtToken;

  UsersRepository({
    required this.getUsersByIdsUrl,
    required this.jwtToken,
  });

  /// 여러 명의 사용자 정보를 가져오는 함수
  Future<Map<String, dynamic>> fetchUsersByIds(List<String> userIds) async {
    final response = await http.post(
      Uri.parse(getUsersByIdsUrl),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode({'user_ids': userIds}),
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(decodedResponse);

      return {for (var user in data) user['id']: user};
    } else {
      throw Exception("Failed to fetch users: ${response.body}");
    }
  }
}
