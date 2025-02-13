import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:legalfactfinder2025/constants.dart';

class OcrKrNaverClovaService {
  /// 이미지 데이터를 Edge Function으로 전송하여 OCR 결과를 가져오는 함수
  static Future<String?> performOcr(Uint8List imageBytes) async {
    final DateTime startTime = DateTime.now();
    print("⏳ [OcrKrNaverClovaService] OCR 요청 시작 at $startTime");

    try {
      final String base64Image = base64Encode(imageBytes);
      print("🖼️ [OcrKrNaverClovaService] Base64 인코딩된 이미지 크기: ${base64Image.length} bytes");

      if (base64Image.length > 1000000) { // Base64 크기 제한 (1MB)
        print("❌ [OcrKrNaverClovaService] 이미지 크기가 너무 큼. OCR 요청 취소.");
        return "이미지 크기가 너무 큽니다.";
      }

      final response = await http.post(
        Uri.parse(ocrkrNaverClovaEdgeFunctionUrl),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({"image": base64Image}),
      );

      final DateTime endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print("⏳ [OcrKrNaverClovaService] OCR 요청 완료 at $endTime (소요 시간: ${duration.inMilliseconds}ms)");

      if (response.statusCode == 200) {
             // ✅ UTF-8로 올바르게 디코딩하여 JSON 변환
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        print("✅ [OcrKrNaverClovaService] OCR API 응답 수신 성공!");
        print("📝 [OcrKrNaverClovaService] OCR 원본 결과: ${jsonResponse}");

        // ✅ fields 배열에서 모든 inferText를 결합하여 반환
        final String ocrText = _extractOcrText(jsonResponse);
        print("🔎 [OcrKrNaverClovaService] OCR 추출된 텍스트: $ocrText");
        return ocrText.isNotEmpty ? ocrText : "OCR 인식 실패";
      } else {
        print("❌ [OcrKrNaverClovaService] OCR 요청 실패! HTTP 상태 코드: ${response.statusCode}");
        print("📄 [OcrKrNaverClovaService] 응답 본문: ${response.body}");
        return null;
      }
    } catch (e, stacktrace) {
      print("❌ [OcrKrNaverClovaService] OCR 요청 중 오류 발생!");
      print("⚠️ 오류 메시지: $e");
      print("📌 Stacktrace: $stacktrace");
      return null;
    }
  }

  /// OCR API 응답에서 `fields` 배열의 `inferText` 값을 결합하여 반환하는 함수
  static String _extractOcrText(Map<String, dynamic> jsonResponse) {
    try {
      final List<dynamic> fields = jsonResponse['images'][0]['fields'];
      return fields.map((field) => field['inferText']).join(" ");
    } catch (e) {
      print("❌ [OcrKrNaverClovaService] OCR 응답 처리 중 오류 발생: $e");
      return "OCR 인식 실패";
    }
  }
}
