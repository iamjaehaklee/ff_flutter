import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/chat/message_controller.dart';
import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
import 'package:legalfactfinder2025/features/chat/presentation/thread_screen.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_bubble.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_input.dart';
import 'package:legalfactfinder2025/features/chat/presentation/widgets/shakerble.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_with_participants_model.dart';

class ChatScreen extends StatefulWidget {
  final WorkRoomWithParticipants workRoomWithParticipants;
  final String myUserId;

  const ChatScreen(
      {Key? key,
      required this.workRoomWithParticipants,
      required this.myUserId})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageController _chatController = Get.find<MessageController>();
  final ScrollController _scrollController = ScrollController();

  // 각 메시지에 대한 GlobalKey를 ShakeableState 타입으로 저장
  final Map<String, GlobalKey<ShakeableState>> _messageKeys = {};

  // 현재 편집 또는 답장 중인 메시지를 추적하는 상태 변수
  Message? _editingMessage;
  Message? _replyingToMessage;

  @override
  void initState() {
    super.initState();
    _chatController
        .loadMessagesByWorkRoomId(widget.workRoomWithParticipants.workRoom.id);
  }

  // 해당 GlobalKey의 위젯이 화면 내에 완전히 보이는지 판단하는 헬퍼 함수
  bool _isWidgetVisible(GlobalKey key) {
    if (key.currentContext == null) return false;
    final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final double widgetTop = position.dy;
    final double widgetBottom = widgetTop + box.size.height;
    final double screenHeight = MediaQuery.of(context).size.height;
    // 위젯이 화면 상단(0)과 하단(screenHeight) 사이에 완전히 포함되어 있으면 보이는 것으로 간주
    return widgetTop >= 0 && widgetBottom <= screenHeight;
  }

  Future<void> _waitForContext(GlobalKey key,
      {Duration timeout = const Duration(seconds: 1)}) async {
    final int intervalMs = 100;
    final int maxAttempts = timeout.inMilliseconds ~/ intervalMs;
    int attempts = 0;
    while (key.currentContext == null && attempts < maxAttempts) {
      await Future.delayed(Duration(milliseconds: intervalMs));
      attempts++;
    }
  }

  void _scrollToMessage(String messageId) async {
    debugPrint("==== _scrollToMessage called. messageId: $messageId ====");
    debugPrint("Current _messageKeys: ${_messageKeys.keys.toList()}");

    GlobalKey<ShakeableState>? key = _messageKeys[messageId];

    if (key == null || key.currentContext == null) {
      debugPrint(
          "Message with ID $messageId not found in current list. Attempting to fetch and insert it.");
      try {
        Message missingMessage =
            await _chatController.getMessageById(messageId);
        debugPrint(
            "Fetched missing message: ID: ${missingMessage.id}, content: ${missingMessage.content}");
        bool exists =
            _chatController.messages.any((msg) => msg.id == messageId);
        if (!exists) {
          setState(() {
            _chatController.messages.add(missingMessage);
          });
        } else {
          debugPrint("Message with ID $messageId already exists in the list.");
        }
        // 새 GlobalKey 인스턴스를 생성하여 등록
        key = GlobalKey<ShakeableState>();
        _messageKeys[messageId] = key;
        await _waitForContext(key);
        if (key.currentContext != null) {
          await Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 300),
            alignment: 1.0, // reverse 리스트에서는 1.0이 위쪽 정렬 효과
          );
          key.currentState?.shake();
          debugPrint(
              "ensureVisible and shake completed for fetched messageId $messageId");
        } else {
          debugPrint(
              "After fetching, currentContext for key of messageId $messageId is still null even after waiting.");
        }
      } catch (e, s) {
        debugPrint("Error fetching missing message: $e");
        debugPrint("StackTrace: $s");
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _waitForContext(key!);
        if (key.currentContext != null) {
          try {
            debugPrint("Calling ensureVisible for messageId $messageId");
            await Scrollable.ensureVisible(
              key.currentContext!,
              duration: const Duration(milliseconds: 300),
              alignment: 1.0, // reverse 리스트에서는 1.0이 위쪽 정렬 효과
            );
            debugPrint("ensureVisible completed for messageId $messageId");
            key.currentState?.shake();
            debugPrint("Shake animation triggered for messageId $messageId");
          } catch (e, s) {
            debugPrint("Error in ensureVisible for messageId $messageId: $e");
            debugPrint("StackTrace: $s");
          }
        } else {
          debugPrint(
              "After post frame callback, currentContext for key of messageId $messageId is still null.");
        }
      });
    }
    debugPrint(
        "==== _scrollToMessage completed for messageId: $messageId ====");
  }

  @override
  Widget build(BuildContext context) {
    // 참가자 정보: senderId를 username으로 매핑
    final participantsMap = {
      for (var participant in widget.workRoomWithParticipants.participants)
        participant.userId: participant.username
    };

    return Obx(() {
      if (_chatController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final messages = _chatController.messages;

      return Column(
        children: [
          // 채팅 메시지 영역
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              cacheExtent: MediaQuery.of(context).size.height * 2,
              // 캐시 범위를 늘림

              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                // 각 메시지에 대해 GlobalKey<ShakeableState> 할당 (재사용)
                final messageKey = _messageKeys.putIfAbsent(
                    message.id, () => GlobalKey<ShakeableState>());

                return Shakeable(
                  key: messageKey,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 2),
                    child: MessageBubble(
                      myUserId: widget.myUserId,
                      message: message,
                      participantsMap: participantsMap,
                      isSelected: _editingMessage?.id == message.id ||
                          _replyingToMessage?.id == message.id,
                      onSelected: (selectedMessageId) {
                        setState(() {
                          if (_editingMessage?.id == selectedMessageId) {
                            _editingMessage = null;
                          } else {
                            _editingMessage = messages.firstWhere(
                                (msg) => msg.id == selectedMessageId);
                          }
                        });
                      },
                      onThread: (threadMessage) {
                        // 쓰레드 화면 표시
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (context) => Container(
                            height: MediaQuery.of(context).size.height - 40,
                            child: ThreadScreen(
                              participantList:
                                  widget.workRoomWithParticipants.participants,
                              workRoomId: threadMessage.workRoomId,
                            ),
                          ),
                        );
                      },
                      onReply: (replyMessage) {
                        setState(() {
                          _replyingToMessage = replyMessage;
                        });
                      },
                      onEdit: (editMessage) {
                        setState(() {
                          _editingMessage = editMessage;
                        });
                      },
                      // 부모 메시지 표시 요청 시 해당 메시지로 스크롤 또는 흔들기 실행
                      onShowParentMessage: (parentMessageId) {
                        _scrollToMessage(parentMessageId);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          // 메시지 입력 영역
          MessageInput(
            workRoomId: widget.workRoomWithParticipants.workRoom.id,
            editingMessage: _editingMessage,
            replyingToMessage: _replyingToMessage,
            onSend: ({
              required String workRoomId,
              required String senderId,
              required String content,
              String? parentMessageId,
              String? editingMessageId,
              List<File>? attachments,
            }) async {
              if (editingMessageId != null) {
                await _chatController.editMessage(editingMessageId, content);
              } else {
                await _chatController.sendMessage(
                  workRoomId: workRoomId,
                  senderId: senderId,
                  content: content,
                  attachments: attachments, // 첨부파일도 함께 전달
                );
              }
              setState(() {
                _editingMessage = null;
                _replyingToMessage = null;
              });
            },
            onCancelEditingOrReplying: () {
              setState(() {
                _editingMessage = null;
                _replyingToMessage = null;
              });
            },
          ),
        ],
      );
    });
  }
}
