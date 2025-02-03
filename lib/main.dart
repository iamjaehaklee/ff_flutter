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
import 'package:legalfactfinder2025/features/files/file_view_controller.dart';
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

  // WorkRoomRepository 및 Controller 초기화
  Get.put(WorkRoomListController()); // WorkRoomController 등록
  Get.put(FriendListController()); // WorkRoomController 등록

  // ChatRepository 및 Controller 초기화
  final messageRepository = MessageRepository(
    getChatMessagesEdgeFunctionUrl: getChatMessagesEdgeFunctionUrl,
    putChatMessageEdgeFunctionUrl: putChatMessageEdgeFunctionUrl,
    jwtToken: jwtToken,
  );
  Get.put(MessageController(messageRepository)); // Register ChatController

  // ThreadRepository 및 Controller 초기화
  final threadRepository = ThreadRepository(
    getThreadsEdgeFunctionUrl: getThreadsEdgeFunctionUrl,
    jwtToken: jwtToken,
  );
  Get.put(ThreadController(threadRepository)); // Register ThreadController

  // ThreadMessageRepository 및 Controller 초기화
  final threadMessageRepository = ThreadMessageRepository(
    getParentMessageEdgeFunctionUrl: getParentMessageEdgeFunctionUrl,
    getThreadMessagesEdgeFunctionUrl: getThreadChatMessagesEdgeFunctionUrl,
    putThreadMessageEdgeFunctionUrl: putThreadChatMessageEdgeFunctionUrl,
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Legal FactFinder',
      theme: AppTheme.themeData,
      // home: MainLayout(), // BottomNavigationBar를 포함한 메인 화면
      initialRoute: initialRoute,
      // 로그인 화면을 기본 화면으로 설정
      getPages: AppRoutes.routes,
      // AppRoutes의 라우트 리스트 연결
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
