import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/confidentiality/signature_controller.dart';
import 'package:signature/signature.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignaturePage extends StatelessWidget {
  final String userId; // 사용자 ID
  final String workRoomId;

  // Signature 캔버스를 위한 컨트롤러
  final SignatureController _signatureCanvasController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // GetX 상태 관리용 컨트롤러 (수정됨)
  final MySignatureController mySignatureController = Get.put(MySignatureController());

  SignaturePage({Key? key, required this.userId, required this.workRoomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Confidentiality Agreement'),
      ),
      body: Column(
        children: [
          // 비밀유지서약 내용
          Expanded(
            flex: 2, // 전체 화면의 2/5 비율로 설정
            child: Container(
              color: Colors.grey[300], // 배경을 회색으로 설정
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // 내부 흰색 배경
                  border: Border.all(color: Colors.grey, width: 1), // 얇은 회색 테두리
                  borderRadius: BorderRadius.circular(4), // 라운드 코너 줄임
                ),
                padding: const EdgeInsets.all(16.0),
                child: Scrollbar(
                  thumbVisibility: true, // 스크롤바 항상 표시
                  radius: const Radius.circular(4), // 스크롤바 모서리 줄임
                  thickness: 3, // 스크롤바 두께
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confidentiality Agreement',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'This confidentiality agreement ensures that all sensitive information, files, and discussions within this workspace remain secure and private. '
                              'By signing this agreement, you agree to maintain strict confidentiality and not disclose any information to unauthorized parties. '
                              'Failure to comply may result in legal consequences. Please read this agreement thoroughly before proceeding to sign below.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'By signing, you also acknowledge that any breach of confidentiality may lead to disciplinary actions or termination of access to the workspace.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 서명 공간
          Expanded(
            flex: 3, // 전체 화면의 3/5 비율로 설정
            child: Container(
              color: Colors.grey[300], // 배경을 회색으로 설정
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 서명란
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white, // 서명란 배경 하얀색
                        border: Border.all(color: Colors.black, width: 1.0), // 테두리 강조
                        borderRadius: BorderRadius.circular(4), // 라운드 코너 줄임
                      ),
                      child: AspectRatio(
                        aspectRatio: 4 / 3, // 4:3 비율 설정
                        child: Stack(
                          children: [
                            // 배경 텍스트
                            Center(
                              child: Text(
                                'Draw Signature',
                                style: TextStyle(
                                  color: Colors.grey[400], // 연한 회색 텍스트
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // 서명 캔버스
                            Signature(
                              controller: _signatureCanvasController,
                              backgroundColor: Colors.transparent, // 투명 배경
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _signatureCanvasController.clear(),
                        child: const Text('Clear'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_signatureCanvasController.isNotEmpty) {
                            final Uint8List? data = await _signatureCanvasController.toPngBytes();
                            if (data != null) {
                              await _saveSignature(data);
                              Get.back(result: true); // 서명 완료 후 true 반환
                            }
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSignature(Uint8List data) async {
    try {
      // 파일 이름 생성
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId$timestamp.png';

      // 스토리지 경로
      final storagePath = '$workRoomId/$fileName';

      // Supabase 스토리지 업로드
      final String? uploadedFilePath = await Supabase.instance.client.storage
          .from('work_room_signatures')
          .uploadBinary(storagePath, data, fileOptions: const FileOptions(contentType: 'image/png'));

      if (uploadedFilePath == null) {
        throw Exception('Failed to upload signature: Upload returned null.');
      }

      print('Signature uploaded to: $storagePath');

      // ✅ 컨트롤러를 통해 DB에 서명 정보 저장
      await mySignatureController.saveSignatureToDatabase(userId, workRoomId, storagePath);

    } catch (e) {
      print('Error saving signature: $e');
    }
  }
}
