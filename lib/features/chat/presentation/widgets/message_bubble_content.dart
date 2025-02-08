import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_bubble_actions.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_highlight_icon.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/parent_message_indicator.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/thread_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:legalfactfinder2025/features/files/presentation/file_page.dart';

class MessageBubbleContent extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;
  final VoidCallback onTap;
  final void Function(Message)? onThread;
  final void Function(String)? onShowParentMessage;

  const MessageBubbleContent({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    required this.onTap,
    this.onThread,
    this.onShowParentMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("[MessageBubbleContent] build: Building widget for message id: ${message.id}");
    final Color? bubbleColor = isCurrentUser ? Colors.blue : Colors.grey[300];
    final Color textColor = isCurrentUser ? Colors.white : Colors.black;
    final Color threadColor = isCurrentUser ? Colors.white : Colors.blueAccent;
    final Color? showParentMessageColor = isCurrentUser ? Colors.blue[100] : Colors.grey[200];

    return GestureDetector(
      onTap: () {
        print("[MessageBubbleContent] onTap: Message tapped, id: ${message.id}");
        onTap();
      },
      onLongPress: () {
        print("[MessageBubbleContent] onLongPress: Long pressed on message id: ${message.id}");
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset position = box.localToGlobal(Offset.zero);
        const double screenPadding = 16.0;
        const double menuHeight = 44.0;
        print("[MessageBubbleContent] onLongPress: Position: $position");
        showHighlightOptions(
          context,
          message,
          Offset(isCurrentUser ? position.dx : screenPadding, position.dy - menuHeight - 8),
          null,
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.parentMessageId != null)
                  ParentMessageIndicator(
                    backgroundColor: showParentMessageColor,
                    message: message,
                    onShowParentMessage: onShowParentMessage,
                  ),
                if (message.messageType?.startsWith('image') ?? false)
                  GestureDetector(
                    onTap: () {
                      print("[MessageBubbleContent] onTap (Image): Tapped image message id: ${message.id}");
                      showDialog(
                        context: context,
                        builder: (context) {
                          print("[MessageBubbleContent] onTap (Image): Building dialog for full image view");
                          print("message.attachmentFileStorageKey! : ${message.attachmentFileStorageKey!}");
                          return Dialog(
                            child: FutureBuilder<Uint8List>(
                              future: Supabase.instance.client.storage
                                  .from('work_room_files')
                                  .download(message.attachmentFileStorageKey!
                                  .replaceFirst("work_room_files/", "")),
                              builder: (context, snapshot) {
                                print("[MessageBubbleContent] FutureBuilder (Full Image): Connection state: ${snapshot.connectionState}");
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  print("[MessageBubbleContent] FutureBuilder (Full Image): Waiting for image data");
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError || !snapshot.hasData) {
                                  print("[MessageBubbleContent] FutureBuilder (Full Image): Error or no data. Error: ${snapshot.error}");
                                  return const Center(child: Text('이미지를 불러올 수 없습니다.'));
                                }
                                print("[MessageBubbleContent] FutureBuilder (Full Image): Image data received");
                                return Image.memory(snapshot.data!, fit: BoxFit.contain);
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: FutureBuilder<Uint8List>(
                      future: Supabase.instance.client.storage
                          .from('work_room_thumbnails')
                          .download('${message.workRoomId}/thumb_${message.attachmentFileStorageKey!.split('/').last}'),
                      builder: (context, snapshot) {
                        print("[MessageBubbleContent] FutureBuilder (Thumbnail): Connection state: ${snapshot.connectionState}");
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          print("[MessageBubbleContent] FutureBuilder (Thumbnail): Waiting for thumbnail data");
                          return const SizedBox(
                            width: 150,
                            height: 150,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          print("[MessageBubbleContent] FutureBuilder (Thumbnail): Error or no data. Error: ${snapshot.error}");
                          return const SizedBox(
                            width: 150,
                            height: 150,
                            child: Center(child: Text('Thumb 불러올 수 없습니다.')),
                          );
                        }
                        print("[MessageBubbleContent] FutureBuilder (Thumbnail): Thumbnail data received");
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            snapshot.data!,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  )
                else if (message.messageType == 'file'||message.messageType == '_file') // file 은 채팅첨부파일, _file 은 바로업로드한파일
                // 파일 메시지: 파일 아이콘과 파일 이름 표시, 탭 시 FilePage 이동
                  GestureDetector(
                    onTap: () {
                      print("[MessageBubbleContent] onTap (File): Tapped file message id: ${message.id}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilePage(
                            workRoomId: message.workRoomId,
                            fileName: message.attachmentFileStorageKey != null
                                ? message.attachmentFileStorageKey!.split('/').last
                                : '파일',
                            storageKey: message.attachmentFileStorageKey ?? '',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.insert_drive_file, size: 50, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            message.attachmentFileStorageKey != null
                                ? message.attachmentFileStorageKey!.split('/').last
                                : '파일',
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                // 기본 텍스트 메시지 또는 기타 경우
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MessageHighlightIcon(
                      highlight: message.highlight,
                      messageId: message.id,
                    ),
                    Flexible(
                      child: Text(
                        message.content,
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  ],
                ),
                if (message.threadCount > 0)
                  ThreadIndicator(
                    message: message,
                    color: threadColor,
                    onThread: onThread,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
