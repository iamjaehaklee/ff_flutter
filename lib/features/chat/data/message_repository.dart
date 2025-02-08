import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/core/utils/formatters.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/core/network/api_exception.dart';
import 'package:legalfactfinder2025/features/files/data/file_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class MessageRepository {
  final String getChatMessagesEdgeFunctionUrl;
  final String putChatMessageEdgeFunctionUrl;
  final String jwtToken;

  MessageRepository({
    required this.getChatMessagesEdgeFunctionUrl,
    required this.putChatMessageEdgeFunctionUrl,
    required this.jwtToken,
  });

  Future<List<Message>> fetchMessages(String workRoomId,
      {int limit = 20, int offset = 0}) async {
    print(
        "[MessageRepository] fetchMessages: Start fetching messages for workRoomId=$workRoomId, limit=$limit, offset=$offset");
    final uri = Uri.parse(
      '$getChatMessagesEdgeFunctionUrl?work_room_id=$workRoomId&limit=$limit&offset=$offset',
    );
    print("[MessageRepository] fetchMessages: Constructed URI: $uri");

    try {
      final response = await _makeRequest(
        uri,
        method: 'GET',
      );
      print(
          "[MessageRepository] fetchMessages: Received response with status ${response.statusCode}");

      final decodedBody = utf8.decode(response.bodyBytes);
      print(
          "[MessageRepository] fetchMessages: Decoded response body: $decodedBody");

      final List<dynamic> data = jsonDecode(decodedBody);
      print(
          "[MessageRepository] fetchMessages: Parsed JSON data with ${data.length} messages");
      final messages = data.map((messageJson) {
        print(
            "[MessageRepository] fetchMessages: Processing message: $messageJson");
        return Message.fromJson(messageJson);
      }).toList();
      print(
          "[MessageRepository] fetchMessages: Successfully converted JSON to Message objects");
      return messages;
    } catch (e) {
      print("[MessageRepository] fetchMessages: Error occurred: $e");
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch messages', 500, e.toString());
    }
  }

  Future<Message> sendMessage({
    required String workRoomId,
    required String senderId,
    required String content,
    List<File>? attachments,
  }) async {
    print("[MessageRepository] sendMessage: Start sending message");
    print("[MessageRepository] sendMessage: workRoomId=$workRoomId, senderId=$senderId, content=$content, attachments=${attachments?.length ?? 0}");

    // 첨부파일이 없으면 단순 메시지 전송
    if (attachments == null || attachments.isEmpty) {
      final uri = Uri.parse(putChatMessageEdgeFunctionUrl);
      print("[MessageRepository] sendMessage: No attachments found, sending text message only.");
      var request = http.MultipartRequest('POST', uri);
      request.fields['work_room_id'] = workRoomId;
      request.fields['sender_id'] = senderId;
      request.fields['content'] = content;
      request.fields['has_attachments'] = "false";
      request.fields['message_type'] = "text";
      request.headers['Authorization'] = 'Bearer $jwtToken';

      try {
        print("[MessageRepository] sendMessage: Sending text message request...");
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        print("[MessageRepository] sendMessage: Received response with status ${response.statusCode}");
        if (response.statusCode != 200) {
          print("[MessageRepository] sendMessage: Response status not 200, body: ${response.body}");
          throw ApiException('Failed to send message', response.statusCode, response.body);
        }
        final responseBody = utf8.decode(response.bodyBytes);
        print("[MessageRepository] sendMessage: Decoded response body: $responseBody");
        final responseData = jsonDecode(responseBody);
        Message message = Message.fromJson(responseData[0]);
        print("[MessageRepository] sendMessage: Successfully created Message object: $message");
        return message;
      } catch (e) {
        print("[MessageRepository] sendMessage: Exception occurred: $e");
        if (e is ApiException) rethrow;
        throw ApiException('Failed to send message', 500, e.toString());
      }
    }

    // 첨부파일이 있는 경우 (챗 메시지 첨부파일 업로드 흐름)
    final uri = Uri.parse(putChatMessageEdgeFunctionUrl);
    print("[MessageRepository] sendMessage: Constructed URI: $uri");

    var request = http.MultipartRequest('POST', uri);
    request.fields['work_room_id'] = workRoomId;
    request.fields['sender_id'] = senderId;
    request.fields['content'] = content;
    print("[MessageRepository] sendMessage: Set basic fields: work_room_id, sender_id, content");

    request.fields['has_attachments'] = "true";
    print("[MessageRepository] sendMessage: Attachments found, setting has_attachments=true");

    List<String> fileStorageKeys = [];
    List<String> fileTypes = [];
    List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];

    bool allImages = attachments.every((file) {
      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      return imageExtensions.contains(extension);
    });
    request.fields['message_type'] = allImages ? "image" : "file";
    print("[MessageRepository] sendMessage: Determined message_type=${request.fields['message_type']}");

    FileRepository fileRepository = FileRepository();
    AuthController authController = Get.find<AuthController>();
    String? userId = authController.getUserId();
    if (userId == null) {
      print("[MessageRepository] sendMessage: User not logged in");
      throw ApiException('User not logged in', 401, 'User not logged in');
    }
    print("[MessageRepository] sendMessage: Found userId=$userId for file upload");

    for (var file in attachments) {
      try {
        final originalFileName = file.path.split('/').last;
        final extension = originalFileName.split('.').last.toLowerCase();
        final timestampedFileName = generateTimestampedFileName(originalFileName);
        print("[MessageRepository] sendMessage: Uploading file: $timestampedFileName with extension: $extension");

        String storageKey = await fileRepository.uploadFileToStorage(
          path: file.path,
          timeStampedFileName: timestampedFileName,
          workRoomId: workRoomId,
          description: 'chat_attachment',
          uploaderId: userId,
        );
        print("[MessageRepository] sendMessage: File uploaded, storageKey: $storageKey");
        fileStorageKeys.add(storageKey);

        final fileType = imageExtensions.contains(extension) ? "image" : "file";
        fileTypes.add(fileType);
        print("[MessageRepository] sendMessage: File type determined: $fileType");

        // 이미지인 경우 썸네일 생성 및 업로드
        if (fileType == "image") {
          print("[MessageRepository] sendMessage: Generating thumbnail for image: $originalFileName");
          File thumbnailFile = await fileRepository.generateThumbnail(file);
          final thumbnailFileName = 'thumb_$timestampedFileName';
          final thumbnailStorageKey = '$workRoomId/$thumbnailFileName';
          print("[MessageRepository] sendMessage: Uploading thumbnail: $thumbnailFileName");

          await fileRepository.uploadFileToStorage(
            path: thumbnailFile.path,
            timeStampedFileName: thumbnailFileName,
            workRoomId: workRoomId,
            description: 'chat_attachment_thumbnail',
            uploaderId: userId,
            isThumbnail: true,
          );
          print("[MessageRepository] sendMessage: Thumbnail uploaded, storageKey: $thumbnailStorageKey");
          // 필요에 따라 thumbnailStorageKey도 추가할 수 있음
        }
      } catch (e) {
        print("[MessageRepository] sendMessage: Error processing attachment: ${e.toString()}");
        throw ApiException('Failed to upload file', 500, e.toString());
      }
    }
    request.fields['attachment_file_storage_key'] = fileStorageKeys.join(',');
    request.fields['attachment_file_type'] = fileTypes.join(',');
    print("[MessageRepository] sendMessage: Final attachment keys - storage: ${request.fields['attachment_file_storage_key']}, types: ${request.fields['attachment_file_type']}");

    request.headers['Authorization'] = 'Bearer $jwtToken';
    print("[MessageRepository] sendMessage: Headers set: ${request.headers}");

    try {
      print("[MessageRepository] sendMessage: Sending HTTP request...");
      final streamedResponse = await request.send();
      print("[MessageRepository] sendMessage: HTTP request sent, awaiting response...");
      final response = await http.Response.fromStream(streamedResponse);
      print("[MessageRepository] sendMessage: Received response with status ${response.statusCode}");

      if (response.statusCode != 200) {
        print("[MessageRepository] sendMessage: Response status not 200, body: ${response.body}");
        throw ApiException('Failed to send message', response.statusCode, response.body);
      }

      final responseBody = utf8.decode(response.bodyBytes);
      print("[MessageRepository] sendMessage: Decoded response body: $responseBody");

      final responseData = jsonDecode(responseBody);
      print("[MessageRepository] sendMessage: Parsed response data: $responseData");

      Message message = Message.fromJson(responseData[0]);
      print("[MessageRepository] sendMessage: Successfully created Message object: $message");
      return message;
    } catch (e) {
      print("[MessageRepository] sendMessage: Exception occurred: $e");
      if (e is ApiException) rethrow;
      throw ApiException('Failed to send message', 500, e.toString());
    }
  }

  Future<void> updateMessage(String messageId, String newContent) async {
    print(
        "[MessageRepository] updateMessage: Start updating messageId=$messageId with newContent=$newContent");
    final uri = Uri.parse(updateChatMessage_EdgeFunctionUrl);
    final requestBody = {
      'message_id': messageId,
      'new_content': newContent,
    };
    print("[MessageRepository] updateMessage: Request body: $requestBody");

    try {
      await _makeRequest(
        uri,
        method: 'POST',
        body: requestBody,
      );
      print("[MessageRepository] updateMessage: Message updated successfully");
    } catch (e) {
      print("[MessageRepository] updateMessage: Exception occurred: $e");
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update message', 500, e.toString());
    }
  }

  Future<void> deleteMessage(String messageId) async {
    print(
        "[MessageRepository] deleteMessage: Start deleting messageId=$messageId");
    final uri = Uri.parse(deleteChatMessage_EdgeFunctionUrl);
    final requestBody = {
      'message_id': messageId,
    };
    print("[MessageRepository] deleteMessage: Request body: $requestBody");

    try {
      await _makeRequest(
        uri,
        method: 'POST',
        body: requestBody,
      );
      print("[MessageRepository] deleteMessage: Message deleted successfully");
    } catch (e) {
      print("[MessageRepository] deleteMessage: Exception occurred: $e");
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete message', 500, e.toString());
    }
  }

  Future<void> updateHighlight(String messageId, String highlight) async {
    print(
        "[MessageRepository] updateHighlight: Start updating highlight for messageId=$messageId, highlight=$highlight");
    final uri =
        Uri.parse('$baseUrl/functions/v1/update_chat_message_highlight');
    final requestBody = {
      'message_id': messageId,
      'highlight': highlight,
    };
    print("[MessageRepository] updateHighlight: Request body: $requestBody");

    try {
      await _makeRequest(
        uri,
        method: 'POST',
        body: requestBody,
      );
      print(
          "[MessageRepository] updateHighlight: Highlight updated successfully");
    } catch (e) {
      print("[MessageRepository] updateHighlight: Exception occurred: $e");
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update highlight', 500, e.toString());
    }
  }

  Future<Message> fetchMessageById(String messageId) async {
    print(
        "[MessageRepository] fetchMessageById: Start fetching message by id: $messageId");
    final uri = Uri.parse('$baseUrl/functions/v1/get_chat_message_by_id');
    final requestBody = {
      'message_id': messageId,
    };
    print("[MessageRepository] fetchMessageById: Request body: $requestBody");

    try {
      final response = await _makeRequest(
        uri,
        method: 'POST',
        body: requestBody,
      );
      print(
          "[MessageRepository] fetchMessageById: Received response with status ${response.statusCode}");
      final responseBody = utf8.decode(response.bodyBytes);
      print(
          "[MessageRepository] fetchMessageById: Decoded response body: $responseBody");
      final responseData = jsonDecode(responseBody);
      print(
          "[MessageRepository] fetchMessageById: Parsed response data: $responseData");
      Message message = Message.fromJson(responseData);
      print(
          "[MessageRepository] fetchMessageById: Successfully created Message object: $message");
      return message;
    } catch (e) {
      print("[MessageRepository] fetchMessageById: Exception occurred: $e");
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch message', 500, e.toString());
    }
  }

  Future<http.Response> _makeRequest(
    Uri uri, {
    required String method,
    Map<String, dynamic>? body,
  }) async {
    print(
        "[MessageRepository] _makeRequest: Start making HTTP request. URI: $uri, method: $method, body: $body");
    final headers = {
      'Authorization': 'Bearer $jwtToken',
      'Content-Type': 'application/json; charset=utf-8',
    };
    print("[MessageRepository] _makeRequest: Headers: $headers");

    late http.Response response;
    try {
      if (method == 'GET') {
        print("[MessageRepository] _makeRequest: Sending GET request...");
        response = await http.get(uri, headers: headers);
      } else if (method == 'POST') {
        print(
            "[MessageRepository] _makeRequest: Sending POST request with body: ${jsonEncode(body)}");
        response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
      } else {
        print(
            "[MessageRepository] _makeRequest: Unsupported HTTP method: $method");
        throw ApiException('Unsupported HTTP method', 500);
      }

      print(
          "[MessageRepository] _makeRequest: Received response with status ${response.statusCode}");
      if (response.statusCode != 200) {
        print(
            "[MessageRepository] _makeRequest: Request failed with status ${response.statusCode} and body: ${response.body}");
        throw ApiException(
          'Request failed',
          response.statusCode,
          response.body,
        );
      }

      print("[MessageRepository] _makeRequest: Request succeeded");
      return response;
    } catch (e) {
      print("[MessageRepository] _makeRequest: Exception occurred: $e");
      if (e is ApiException) rethrow;
      throw ApiException('Network error', 500, e.toString());
    }
  }
}
