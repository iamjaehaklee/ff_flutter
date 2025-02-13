// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:legalfactfinder2025/app/widgets/custom_bottom_sheet.dart';
// import 'package:legalfactfinder2025/constants.dart';
// import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
// import 'package:legalfactfinder2025/features/chat/presentation/thread_screen.dart';
//
// import 'package:flutter/material.dart';
// import 'package:legalfactfinder2025/features/chat/data/message_model.dart';
//
// Widget buildThreadLink(BuildContext context, Message message,
//     Map<String, String> participantsMap, String myUserId) {
//   if (message.threadCount == 0) return SizedBox.shrink(); // ✅ Hide if no thread
//
//   final bool isCurrentUser = message.senderId == myUserId;
//   final Color iconColor = isCurrentUser ? Colors.white : Colors.blueAccent;
//
//   return GestureDetector(
//     onTap: () => _showThreadBottomSheet(context, message, participantsMap),
//     child: Padding(
//       padding: const EdgeInsets.only(top: 4),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.comment, size: 14, color: iconColor),
//           // ✅ Small comment icon
//           const SizedBox(width: 4),
//           Text(
//             message.threadCount.toString(),
//             style: TextStyle(
//               color: iconColor,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// // 기존 Message 클래스와 ThreadScreen 위젯을 그대로 사용한다고 가정합니다.
// void _showThreadBottomSheet(BuildContext context, Message message,
//     Map<String, String> participantsMap) {
//   // _showThreadBottomSheet 메서드 로그 (JSON 형태로 객체 정보 출력)
//   debugPrint('[_showThreadBottomSheet] 호출됨: ${jsonEncode({
//         'messageId': message.id,
//         'workRoomId': message.workRoomId,
//         'participantsMap': participantsMap,
//       })}');
//
//   showCustomBottomSheet(
//     titleBuilder: (setModalState) => Text(
//       'Thread',
//       style: Theme.of(context).textTheme.titleMedium,
//     ),
//     context: context,
//     contentBuilder: (context) {
//       // ThreadScreen 빌더 로그
//       debugPrint('[ThreadScreen] 빌더 호출됨: ' +
//           jsonEncode({
//             'parentMessageId': message.id,
//             'workRoomId': message.workRoomId,
//           }));
//       return ThreadScreen(
//          workRoomId: message.workRoomId,
//         participantList: participantsMap,
//       );
//     },
//   );
//
// }
