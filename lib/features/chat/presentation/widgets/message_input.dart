import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';

class MessageInput extends StatefulWidget {
  final String workRoomId;
  final String? parentMessageId; // 일반적인 thread의 부모 메시지 id
  final Message? editingMessage;
  final Message? replyingToMessage;
  // 추가: annotation thread 댓글 입력용, 전달된 경우 annotation의 id를 부모로 사용
  final DocumentAnnotationModel? annotation;
  final Future<void> Function({
  required String workRoomId,
  required String senderId,
  required String content,
  String? parentMessageId,
  String? editingMessageId,
  List<File>? attachments,
  }) onSend;
  final VoidCallback onCancelEditingOrReplying;

  const MessageInput({
    Key? key,
    required this.workRoomId,
    this.parentMessageId,
    this.editingMessage,
    this.replyingToMessage,
    this.annotation,
    required this.onSend,
    required this.onCancelEditingOrReplying,
  }) : super(key: key);

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  List<File> _selectedFiles = [];
  bool _isUploading = false;

  @override
  void dispose() {
    _controller.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.editingMessage != null) {
      _controller.text = widget.editingMessage!.content;
      print("[MessageInput] initState: Editing message loaded with content: ${widget.editingMessage!.content}");
    } else {
      print("[MessageInput] initState: No editing message provided");
    }
  }

  @override
  void didUpdateWidget(MessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editingMessage != null && oldWidget.editingMessage != widget.editingMessage) {
      _controller.text = widget.editingMessage!.content;
      print("[MessageInput] didUpdateWidget: Switched to editing message: ${widget.editingMessage!.content}");
    } else if (widget.replyingToMessage != null && oldWidget.replyingToMessage != widget.replyingToMessage) {
      _controller.clear();
      print("[MessageInput] didUpdateWidget: Switched to replying to message: ${widget.replyingToMessage!.content}");
    }
  }

  /// 파일 선택 함수
  Future<void> _pickFiles() async {
    print("[MessageInput] _pickFiles: Initiating file picking");
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      dialogTitle: "파일을 선택하세요",
      lockParentWindow: true,
    );

    if (result != null) {
      List<File> pickedFiles = result.files.map((file) => File(file.path!)).toList();
      print("[MessageInput] _pickFiles: Files picked: ${pickedFiles.map((f) => f.path.split('/').last).toList()}");
      setState(() {
        _selectedFiles.addAll(pickedFiles);
      });
    } else {
      print("[MessageInput] _pickFiles: No files selected");
    }
  }

  /// 파일 제거 함수
  void _removeFile(int index) {
    String removedFile = _selectedFiles[index].path.split('/').last;
    print("[MessageInput] _removeFile: Removing file: $removedFile at index: $index");
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  /// 메시지 전송 함수 (일반 메시지 및 thread 댓글 모두 지원)
  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty && _selectedFiles.isEmpty) {
      print("[MessageInput] _sendMessage: Empty message and no files selected, aborting send");
      return;
    }

    print("[MessageInput] _sendMessage: Sending message with text: '${_controller.text.trim()}' and files: ${_selectedFiles.map((f) => f.path.split('/').last).toList()}");
    setState(() {
      _isUploading = true;
    });

    try {
      AuthController authController = Get.find<AuthController>();
      String? myUserId = authController.getUserId();
      print("[MessageInput] _sendMessage: Retrieved user ID: $myUserId");
      if (myUserId == null) {
        print("[MessageInput] _sendMessage: User ID is null, redirecting to login");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User ID is null")),
        );
        Get.toNamed('/login');
        return;
      }

      // parentMessageId 우선순위: replyingToMessage.id > widget.parentMessageId > widget.annotation?.id
      final parentId = widget.replyingToMessage?.id ?? widget.parentMessageId ?? widget.annotation?.id;

      await widget.onSend(
        workRoomId: widget.workRoomId,
        senderId: myUserId,
        content: _controller.text.trim(),
        parentMessageId: parentId,
        editingMessageId: widget.editingMessage?.id,
        attachments: _selectedFiles,
      );

      print("[MessageInput] _sendMessage: Message sent successfully");

      // 전송 후 상태 리셋
      _controller.clear();
      setState(() {
        _selectedFiles.clear();
      });

      widget.onCancelEditingOrReplying();
    } catch (e) {
      print("[MessageInput] _sendMessage: Error occurred while sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send message: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
      print("[MessageInput] _sendMessage: Upload finished, _isUploading set to false");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("[MessageInput] build: Building widget with _isUploading: $_isUploading and ${_selectedFiles.length} selected files");
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(
          children: [
            // Replying/Editing 상태 표시
            if (widget.replyingToMessage != null || widget.editingMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.editingMessage != null
                            ? "Editing: ${widget.editingMessage!.content}"
                            : "Replying to: ${widget.replyingToMessage!.content}",
                        style: const TextStyle(color: Colors.black54, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        print("[MessageInput] build: Cancel editing/replying triggered");
                        widget.onCancelEditingOrReplying();
                      },
                    ),
                  ],
                ),
              ),
            // 선택된 파일 미리보기 영역
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
                                fileName.length > 10 ? "${fileName.substring(0, 10)}..." : fileName,
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
            // 입력창과 첨부 파일, 전송 버튼
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: _pickFiles,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: "Type your message..."),
                  ),
                ),
                _isUploading
                    ? const CircularProgressIndicator(strokeWidth: 2)
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
