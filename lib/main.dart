import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/app/app_routes.dart';
import 'package:legalfactfinder2025/app/app_theme.dart';
import 'package:legalfactfinder2025/app/main_layout.dart';
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/authentication/data/auth_repository.dart';
import 'package:legalfactfinder2025/features/chat/message_controller.dart';
import 'package:legalfactfinder2025/features/chat/data/message_repository.dart';
import 'package:legalfactfinder2025/features/chat/data/thread_repository.dart';
import 'package:legalfactfinder2025/features/chat/thread_controller.dart';
import 'package:legalfactfinder2025/features/chat/data/thread_message_repository.dart';
import 'package:legalfactfinder2025/features/chat/thread_message_controller.dart';
import 'package:legalfactfinder2025/features/document_annotation/annotation_controller.dart';
import 'package:legalfactfinder2025/features/document_annotation/data/annotation_repository.dart';
import 'package:legalfactfinder2025/features/files/data/file_repository.dart';
import 'package:legalfactfinder2025/features/files/data/folders_repository.dart';
import 'package:legalfactfinder2025/features/files/file_list_controller.dart';
import 'package:legalfactfinder2025/features/files/file_view_controller.dart';
import 'package:legalfactfinder2025/features/files/folders_controller.dart';
import 'package:legalfactfinder2025/features/friend/friend_list_controller.dart';
import 'package:legalfactfinder2025/features/notification/data/notification_repository.dart';
import 'package:legalfactfinder2025/features/notification/presentation/notification_list_controller.dart';
import 'package:legalfactfinder2025/features/users/data/users_repository.dart';
import 'package:legalfactfinder2025/features/users/users_controller.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_latest_messages_repository.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_repository.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_controller.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_latest_messages_controller.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_list_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv4;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// FCM 백그라운드 메시지 핸들러 (앱이 백그라운드/터미네이티드 상태일 때 호출됨)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  // 여기에 추가적인 메시지 처리 로직(예: 로컬 알림 표시)을 넣을 수 있습니다.
}

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: baseUrl, // constants.dart에서 가져온 baseUrl
    anonKey: anonKey, // constants.dart에서 가져온 anonKey
  );
}

late String initialRoute;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter framework 초기화
  print("OpenCV version: ${cv4.openCvVersion()}");

  await initSupabase(); // Supabase 초기화

  // Firebase 초기화
  await Firebase.initializeApp();

  // FCM 백그라운드 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // iOS 등에서 알림 권한 요청
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // FCM 토큰 확인 (디버깅 용도)
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token");

  // 터미네이티드 상태에서 알림에 의해 앱이 실행된 경우 처리
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    print("App opened from terminated state via notification: ${initialMessage.data}");
    // 예: initialMessage.data를 기반으로 특정 화면으로 네비게이션 처리 가능
  }


  Get.put(FoldersController());
  Get.put(FileListController());


  Get.put(UsersController(
    UsersRepository(
      getUsersByIdsUrl: getUsersByIdsUrl,
      jwtToken: jwtToken,
    ),
  ));

  Get.put(WorkRoomLatestMessagesController(
    WorkRoomLatestMessagesRepository(
      getWorkRoomLatestMessagesUrl: getWorkRoomLatestMessagesUrl,
      jwtToken: jwtToken,
    ),
  ));

  final authRepository = AuthRepository(Supabase.instance.client);
  final authController = AuthController(authRepository);
  Get.put(authController);

  final annotationController = AnnotationController();
  Get.put(annotationController);

  // NotificationRepository 및 Controller 초기화
  final notificationRepository = NotificationRepository(
    getUserNotificationsUrl: getUserNotificationsEdgeFunctionUrl,
    jwtToken: jwtToken,
  );
  Get.put(NotificationListController(
      notificationRepository: notificationRepository));

  // WorkRoomRepository 및 Controller 초기화
  final workRoomRepository = WorkRoomRepository();
  Get.put(WorkRoomController(workRoomRepository)); // WorkRoomController 등록

  Get.put(WorkRoomListController()); // WorkRoomController 등록

  // WorkRoomRepository 및 Controller 초기화
  Get.put(FriendListController()); // WorkRoomController 등록

  // ChatRepository 및 Controller 초기화
  final messageRepository = MessageRepository(
    getChatMessagesEdgeFunctionUrl: getChatMessages_EdgeFunctionUrl,
    putChatMessageEdgeFunctionUrl: putChatMessage_EdgeFunctionUrl,
    jwtToken: jwtToken,
  );
  Get.put(MessageController(messageRepository)); // Register ChatController

  // ThreadRepository 및 Controller 초기화
  final threadRepository = ThreadRepository(
    getThreadsEdgeFunctionUrl: getThreads_EdgeFunctionUrl,
    jwtToken: jwtToken,
  );
  Get.put(ThreadController(threadRepository)); // Register ThreadController

  // ThreadMessageRepository 및 Controller 초기화
  final threadMessageRepository = ThreadMessageRepository(
    getParentMessageEdgeFunctionUrl: getParentMessage_EdgeFunctionUrl,
    getThreadMessagesEdgeFunctionUrl: getThreadChatMessages_EdgeFunctionUrl,
    putThreadMessageEdgeFunctionUrl: putThreadChatMessage_EdgeFunctionUrl,
    updateThreadMessageEdgeFunctionUrl: updateThreadChatMessage_EdgeFunctionUrl,
    jwtToken: jwtToken,
  );
  Get.put(ThreadMessageController(
      threadMessageRepository)); // Register ThreadMessageController

  // FileViewController 등록
  Get.put(FileViewController(FileRepository()));

  // ✅ 초기 경로 결정: 로그인 여부 & 이메일 인증 상태 확인
  if (authController.currentUser.value == null) {
    initialRoute = '/login'; // 로그인하지 않은 경우 로그인 페이지로 이동
  } else if (!authController.isEmailConfirmed()) {
    initialRoute = '/verify-email'; // 로그인했지만 이메일 인증이 안 된 경우
  } else {
    initialRoute = '/main'; // 로그인 & 이메일 인증 완료된 경우
  }
  runApp(MyApp());

  // 로그인 상태 확인 후 초기 화면 설정
  Future.delayed(Duration.zero, () {
    if (authController.currentUser.value != null) {
      Get.offAllNamed('/main');
    } else {
      Get.offAllNamed('/login');
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FirebaseMessaging _messaging;

  @override
  void initState() {
    super.initState();
    _messaging = FirebaseMessaging.instance;

    // foreground 상태에서 알림 수신 시 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a foreground message: ${message.notification?.title}");
      // 필요에 따라 로컬 알림으로 표시하거나, UI 업데이트 등의 처리를 추가하세요.
    });

    // 앱이 백그라운드 상태였다가 알림 클릭으로 열렸을 때 처리
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification caused app to open: ${message.data}");
      // message.data에 따라 특정 화면으로 네비게이션할 수 있습니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Legal FactFinder',
      theme: AppTheme.themeData,
      initialRoute: initialRoute,
      getPages: AppRoutes.routes,
      unknownRoute: GetPage(
        name: '/not_found',
        page: () => Scaffold(
          body: Center(
            child: Text('Page not found'),
          ),
        ),
      ),
    );
  }
}
