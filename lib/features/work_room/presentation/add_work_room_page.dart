import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_controller.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_list_controller.dart';

class AddWorkRoomPage extends StatefulWidget {
  const AddWorkRoomPage({super.key});

  @override
  _AddWorkRoomPageState createState() => _AddWorkRoomPageState();
}

class _AddWorkRoomPageState extends State<AddWorkRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late AuthController authController;
  late WorkRoomController workRoomController;
  String? userId;

  @override
  void initState() {
    super.initState();

    // GetX 컨트롤러 가져오기
    authController = Get.find<AuthController>();
    workRoomController = Get.find<WorkRoomController>();

    // 로그인 상태 체크 후 userId 가져오기
    userId = authController.getUserId();

    // 로그인하지 않은 경우 로그인 페이지로 이동
    if (userId == null) {
      Future.delayed(Duration.zero, () => Get.offAllNamed('/login'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로그인하지 않은 경우, 로딩 화면을 표시 (Get.offAllNamed()가 실행될 때까지)
    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Work Room')),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // ✅ 전체 패딩 추가
        child: Obx(() {
          if (workRoomController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Work Room Title", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Enter title',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // ✅ 여백 추가
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                const Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3, // ✅ 입력 공간 확대
                  decoration: InputDecoration(
                    labelText: 'Enter description',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // ✅ 여백 추가
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // ✅ 버튼 디자인 개선 (너비 확장 + 패딩 추가)
                SizedBox(
                  width: double.infinity, // 버튼 너비 확장
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await workRoomController.addWorkRoom(
                          _titleController.text,
                          _descriptionController.text,
                          userId!, // 로그인한 사용자 ID 사용 (null이 될 가능성 없음)
                        );

                        if (workRoomController.successMessage.isNotEmpty) {
                          // ✅ 추가 후 WorkRoom 목록 새로고침
                          final listController = Get.find<WorkRoomController>();
                          listController.fetchWorkRoomWithParticipantsByWorkRoomId(userId!);

                          _showSuccessSnackbar(workRoomController.successMessage.value);
                          Navigator.pop(context);
                        } else if (workRoomController.errorMessage.isNotEmpty) {
                          _showErrorDialog(context, workRoomController.errorMessage.value);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14), // ✅ 버튼 내부 패딩 추가
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // ✅ 버튼 둥글기 조정
                    ),
                    child: const Text('Add Work Room', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ✅ 성공 시 화면 상단에 SnackBar 표시
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // ✅ 에러 발생 시 AlertDialog 표시
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
