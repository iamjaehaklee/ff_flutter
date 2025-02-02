import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageInput extends StatefulWidget {
  final String workRoomId;
  final String? parentMessageId; // Optional for threads
  final Future<void> Function({
  required String workRoomId,
  required String senderId,
  required String content,
  String? parentMessageId,
  List<File>? attachments,
  }) onSend;

  const MessageInput({
    Key? key,
    required this.workRoomId,
    this.parentMessageId,
    required this.onSend,
  }) : super(key: key);

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  List<File> _selectedFiles = [];
  bool _isUploading = false;

  /// Selects files for upload
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      dialogTitle: "파일을 선택하세요",

    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files.map((file) => File(file.path!)));
      });
    } else{
      // ✅ 파일 선택을 취소한 경우 SafeArea 다시 적용

      setState(() {

      });
    }

  }



  /// Removes a file from the selection
  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  /// Sends the message with optional attachments
  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty && _selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {

      AuthController authController = Get.find<AuthController>();
      String? myUserId = authController.getUserId();
      if (myUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User ID is null")),
        );
        Get.toNamed('/login');
        return;
      }


      await widget.onSend(
        workRoomId: widget.workRoomId,
        senderId: myUserId, // Replace with the current user's ID
        content: _controller.text.trim(),
        parentMessageId: widget.parentMessageId,
        attachments: _selectedFiles,
      );

      _controller.clear();
      setState(() {
        _selectedFiles.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send message: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(
          children: [
            if (_selectedFiles.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    final fileName = file.path.split('/').last;
      
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade300,
                            child: Center(
                              child: Text(
                                fileName.length > 10
                                    ? "${fileName.substring(0, 10)}..."
                                    : fileName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => _removeFile(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: _pickFiles,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                _isUploading
                    ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
