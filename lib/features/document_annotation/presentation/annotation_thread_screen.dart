// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:legalfactfinder2025/features/chat/message_controller.dart';
// import 'package:legalfactfinder2025/features/chat/presentation/widgets/message_input.dart';
// import 'package:legalfactfinder2025/features/chat/thread_controller.dart';
// import 'package:legalfactfinder2025/features/chat/thread_message_controller.dart';
// import 'package:legalfactfinder2025/features/document_annotation/annotation_controller.dart';
// import 'package:legalfactfinder2025/features/document_annotation/annotation_thread_controller.dart';
// import 'package:legalfactfinder2025/features/document_annotation/data/annotation_thread_model.dart';
// import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';
// import 'package:legalfactfinder2025/core/utils/image_utils.dart';
// import 'package:legalfactfinder2025/features/users/data/user_model.dart';
// import 'package:legalfactfinder2025/features/users/users_controller.dart';
// import 'package:get/get.dart';
// import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
//
// // Annotation 에 대한 ThreadScreen.   Annotation 모델은 로드할 필요 없고, Annotation Id 를 품고 있는 parent message 및 그에 대한 child message 들을 로드하면 됨.
//
// class AnnotationThreadScreen extends StatefulWidget {
//   final DocumentAnnotationModel annotation;
//
//   const AnnotationThreadScreen({
//     Key? key,
//     required this.annotation,
//   }) : super(key: key);
//
//   @override
//   State<AnnotationThreadScreen> createState() => _AnnotationThreadScreenState();
// }
//
// class _AnnotationThreadScreenState extends State<AnnotationThreadScreen> {
//
//   late UsersController usersController;
//   late ThreadMessageController threadMessageController;
//   final TextEditingController _threadInputController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     usersController = Get.find<UsersController>();
//     threadMessageController = Get.find<ThreadMessageController>();
//     threadMessageController
//         .loadParentMessageAndThreadMessageList(widget.annotation.id);
//   }
//
//   @override
//   void dispose() {
//     _threadInputController.dispose();
//     super.dispose();
//   }
//
//   /// 스레드 메시지 수정 다이얼로그 오픈
//   void _editThread(AnnotationThreadModel thread) {
//     _threadInputController.text = thread.content;
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Thread Message'),
//         content: TextField(
//           controller: _threadInputController,
//           decoration: const InputDecoration(hintText: "Edit message"),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _threadInputController.clear();
//             },
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               final updatedContent = _threadInputController.text.trim();
//               if (updatedContent.isNotEmpty) {
//                 final updatedThread = AnnotationThreadModel(
//                   id: thread.id,
//                   content: updatedContent,
//                   annotationId: thread.annotationId,
//                   createdBy: thread.createdBy,
//                   createdAt: thread.createdAt,
//                   updatedAt: DateTime.now(),
//                 );
//                 await threadController.updateThread(updatedThread);
//               }
//               Navigator.pop(context);
//               _threadInputController.clear();
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authController = Get.find<AuthController>();
//     final myUserId = authController.getUserId() ?? "";
//
//     return Column(
//       children: [
//         // 스크롤 영역: 부모 어노테이션과 스레드 댓글이 함께 스크롤됨
//         Expanded(
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16.0),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Colors.grey.shade500,
//                       width: 1.0,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       // 이미지 영역 (16:9 비율)
//                       AspectRatio(
//                         aspectRatio: 16 / 9,
//                         child: widget.annotation.imageFileStorageKey != null
//                             ? FutureBuilder<Uint8List?>(
//                                 future: downloadImageFromSupabase(
//                                   widget.annotation.imageFileStorageKey!,
//                                   bucketName: 'work_room_annotations',
//                                 ),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return Container(
//                                         color: Colors.grey.shade100);
//                                   }
//                                   if (snapshot.hasError ||
//                                       snapshot.data == null) {
//                                     return Container(
//                                       color: Colors.grey.shade300,
//                                       child: const Center(
//                                         child: Icon(Icons.broken_image,
//                                             color: Colors.white),
//                                       ),
//                                     );
//                                   }
//                                   return Image.memory(
//                                     snapshot.data!,
//                                     fit: BoxFit.cover,
//                                   );
//                                 },
//                               )
//                             : Container(color: Colors.grey.shade800),
//                       ),
//                       // 정보 영역: 아바타, 작성자 이름, 작성일시, 내용
//                       Container(
//                         color: Colors.white,
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           children: [
//                             widget.annotation.createdBy.isNotEmpty
//                                 ? CircleAvatar(
//                                     backgroundImage: NetworkImage(
//                                         widget.annotation.createdBy),
//                                   )
//                                 : const CircleAvatar(child: Icon(Icons.person)),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       FutureBuilder<UserModel?>(
//                                         future: usersController.getUserById(
//                                             widget.annotation.createdBy),
//                                         builder: (context, snapshot) {
//                                           if (snapshot.connectionState ==
//                                               ConnectionState.waiting) {
//                                             return const Text(
//                                               'Loading...',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold),
//                                             );
//                                           }
//                                           if (snapshot.hasData &&
//                                               snapshot.data != null) {
//                                             return Text(
//                                               snapshot.data!.username,
//                                               style: const TextStyle(
//                                                   fontWeight: FontWeight.bold),
//                                             );
//                                           }
//                                           return const Text(
//                                             'Unknown User',
//                                             style: TextStyle(
//                                                 fontWeight: FontWeight.bold),
//                                           );
//                                         },
//                                       ),
//                                       const Spacer(),
//                                       Text(
//                                         widget.annotation.createdAt != null
//                                             ? DateFormat('yyyy-MM-dd HH:mm')
//                                                 .format(widget
//                                                     .annotation.createdAt!)
//                                             : "",
//                                         style: const TextStyle(
//                                             fontSize: 12, color: Colors.grey),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(widget.annotation.content ??
//                                       "No Content"),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Divider(),
//                 // 스레드 댓글 영역: AnnotationThreadController의 스레드 리스트를 표시
//                 Obx(() {
//                   if (threadController.isLoading.value) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (threadController.errorMessage.isNotEmpty) {
//                     return Center(
//                         child: Text(threadController.errorMessage.value));
//                   }
//                   if (threadController.threadTileList.isEmpty) {
//                     return const Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: Text(
//                         "No thread messages yet.",
//                         style: TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                     );
//                   }
//                   return ListView.separated(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: threadController.threadTileList.length,
//                     separatorBuilder: (context, index) =>
//                         const Divider(height: 8),
//                     itemBuilder: (context, index) {
//                       final thread = threadController.threadTileList[index];
//                       return ListTile(
//                         title: Text(thread.content),
//                         subtitle: Text(
//                           thread.createdAt != null
//                               ? DateFormat('yyyy-MM-dd HH:mm')
//                                   .format(thread.createdAt!)
//                               : "",
//                         ),
//                         trailing: PopupMenuButton<String>(
//                           onSelected: (value) async {
//                             if (value == 'edit') {
//                               _editThread(thread);
//                             } else if (value == 'delete') {
//                               final confirmed = await showDialog<bool>(
//                                 context: context,
//                                 builder: (context) => AlertDialog(
//                                   title: const Text("Delete Thread Message"),
//                                   content: const Text(
//                                       "Are you sure you want to delete this thread message?"),
//                                   actions: [
//                                     TextButton(
//                                       onPressed: () =>
//                                           Navigator.pop(context, false),
//                                       child: const Text("Cancel"),
//                                     ),
//                                     TextButton(
//                                       onPressed: () =>
//                                           Navigator.pop(context, true),
//                                       child: const Text("Delete",
//                                           style: TextStyle(color: Colors.red)),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                               if (confirmed == true) {
//                                 await threadController.deleteThread(thread.id);
//                               }
//                             }
//                           },
//                           itemBuilder: (context) => [
//                             const PopupMenuItem(
//                                 value: 'edit', child: Text("Edit")),
//                             const PopupMenuItem(
//                                 value: 'delete', child: Text("Delete")),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 }),
//               ],
//             ),
//           ),
//         ),
//         // 하단 고정 영역: MessageInput 위젯 재사용하여 새로운 스레드 메시지 입력
//         Container(
//           color: Colors.white,
//           padding: const EdgeInsets.all(8.0),
//           child: MessageInput(
//             workRoomId: widget.annotation.workRoomId!, // workRoomId가 반드시 존재해야 함
//             annotation: widget.annotation,
//             onSend: ({
//               List<File>? attachments,
//               required String content,
//               String? editingMessageId,
//               String? parentMessageId,
//               required String senderId,
//               required String workRoomId,
//             }) async {
//               // 새로운 스레드 메시지 생성
// // 🟢 변경됨: AnnotationThreadModel 대신 Message 모델을 생성합니다.
//               final newMessage = Message(
//                 id: '',
//                 // 서버에서 생성 (빈 문자열 전달)
//                 workRoomId: workRoomId,
//                 senderId: senderId,
//                 // 🟢 parentMessageId가 제공되지 않으면 부모 어노테이션의 id를 사용합니다.
//                 parentMessageId: parentMessageId ?? widget.annotation.id,
//                 content: content,
//                 messageType: 'annotation_thread',
//                 threadCount: 0,
//                 hasAttachments: attachments != null && attachments.isNotEmpty,
//                 attachmentFileStorageKey: null,
//                 attachmentFileType: null,
//                 highlight: null,
//                 createdAt: DateTime.now(),
//                 updatedAt: DateTime.now(),
//                 // 🟢 annotationId 필드에 부모 어노테이션의 id를 설정하여, annotation thread임을 표시합니다.
//                 annotationId: widget.annotation.id,
//                 ocrText: null,
//                 annotationImageStorageKey: null,
//                 isSystem: false,
//                 systemEventType: null,
//                 replyToMessageId: null,
//                 replyToMessageContent: null,
//                 replyToMessageSenderId: null,
//                 replyToMessageCreatedAt: null,
//                 imageFileId: null,
//               );
//               // 🟢 threadController는 Message 타입의 스레드 생성을 처리하도록 업데이트되어야 합니다.
//               await threadController.createThread(newMessage);
//             },
//             onCancelEditingOrReplying: () {
//               print('Cancel editing or replying');
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
