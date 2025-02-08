import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/chat/message_controller.dart';

void showMessageOptions(
    BuildContext context,
    Message message,
    void Function(Message)? onThread,
    void Function(Message)? onReply,
    void Function(Message)? onEdit,
    void Function(Message)? onDelete,
    void Function(Message)? onMarkImportant,
    ) {
  final MessageController messageController = Get.find<MessageController>();
  final AuthController authController = Get.find<AuthController>();
  String? userId = authController.getUserId();
  final bool isCurrentUser = message.senderId == userId;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              context,
              Icons.comment,
              "Thread",
                  () {
                Navigator.pop(context);
                if (onThread != null) {
                  onThread(message);
                } else {
                  messageController.openThread(message);
                }
              },
            ),
            // _buildActionButton(
            //   context,
            //   Icons.reply,
            //   "Reply",
            //       () {
            //     Navigator.pop(context);
            //     if (onReply != null) {
            //       onReply(message);
            //     } else {
            //       messageController.replyToMessage(message);
            //     }
            //   },
            // ),
            if (isCurrentUser)
              _buildActionButton(
                context,
                Icons.edit,
                "Edit",
                    () {
                  Navigator.pop(context);
                  if (onEdit != null) {
                    onEdit(message);
                  } else {
                    messageController.editMessage(message.id, message.content);
                  }
                },
              ),
            if (isCurrentUser)
              _buildActionButton(
                context,
                Icons.delete,
                "Delete",
                    () {
                  Navigator.pop(context);
                  if (onDelete != null) {
                    onDelete(message);
                  } else {
                    messageController.deleteMessage(message.id);
                  }
                },
              ),
            _buildActionButton(
              context,
              Icons.bookmark,
              "Mark message",
                  () {
                Navigator.pop(context);
                
                // 화면 좌우 패딩 (챗버블과 동일하게 16px)
                const double screenPadding = 16.0;
                
                // 약간의 지연을 주어 bottom sheet가 완전히 닫힌 후 팝업이 표시되도록 함
                Future.delayed(const Duration(milliseconds: 100), () {
                  // 메시지 ID를 기반으로 해당 메시지의 MessageBubbleContent를 찾음
                  Element? messageBubbleElement;
                  context.findRootAncestorStateOfType<NavigatorState>()?.context
                      .visitChildElements((element) {
                    if (element.widget.toString().contains('MessageBubbleContent')) {
                      final widget = element.widget as dynamic;
                      if (widget.message?.id == message.id) {
                        messageBubbleElement = element;
                      }
                    }
                  });

                  if (messageBubbleElement != null) {
                    final RenderBox? messageBox = messageBubbleElement?.findRenderObject() as RenderBox?;
                    if (messageBox != null) {
                      final position = messageBox.localToGlobal(Offset.zero);
                      final size = messageBox.size;
                      
                      // 팝업 메뉴의 높이 (아이콘 32px + 상하 패딩 12px)
                      const double menuHeight = 44.0;
                      
                      showHighlightOptions(
                        context,
                        message,
                        Offset(
                          isCurrentUser 
                              ? position.dx  // 오른쪽 정렬일 때 챗버블과 동일한 위치
                              : screenPadding,  // 왼쪽 정렬일 때 화면 왼쪽에서 16px
                          position.dy - menuHeight - 8,  // 챗버블 위로 메뉴 높이 + 8px 간격
                        ),
                        onMarkImportant,
                      );
                    }
                  }
                });
              },
            ),
            SizedBox(height: 20,)
          ],
        ),
      );
    },
  );
}

void showHighlightOptions(
    BuildContext context,
    Message message,
    Offset position,
    void Function(Message)? onMarkImportant,
) {
  final MessageController messageController = Get.find<MessageController>();
  
  final List<Map<String, dynamic>> highlightOptions = [
    {
      'type': 'important',
      'icon': Icons.priority_high_rounded,
      'color': const Color(0xFFFFB74D),
    },
    {
      'type': 'warning',
      'icon': Icons.warning_rounded,
      'color': const Color(0xFFEF5350),
    },
    {
      'type': 'thumb',
      'icon': Icons.thumb_up_rounded,
      'color': const Color(0xFF42A5F5),
    },
    {
      'type': 'smile',
      'icon': Icons.mood_rounded,
      'color': const Color(0xFF66BB6A),
    },
    {
      'type': 'check',
      'icon': Icons.task_alt_rounded,
      'color': const Color(0xFF26A69A),
    },
  ];

  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) {
      return Stack(
        children: [
          Positioned(
            left: position.dx,
            top: position.dy - 46, // 버블 상단에 더 가깝게 배치
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: IntrinsicWidth(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: highlightOptions.map((option) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.pop(context);
                              if (onMarkImportant != null) {
                                onMarkImportant(message);
                              } else {
                                messageController.updateHighlight(message.id, option['type'] as String);
                              }
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: (option['color'] as Color).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                option['icon'] as IconData,
                                color: option['color'] as Color,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
    ) {
  return ListTile(
    leading: Icon(icon, color: Colors.grey[700]),
    title: Text(
      label,
      style: const TextStyle(fontSize: 16, color: Colors.black),
    ),
    onTap: onTap,
  );
}
