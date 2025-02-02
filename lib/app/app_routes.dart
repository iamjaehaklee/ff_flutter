import 'package:get/get.dart';
import 'package:legalfactfinder2025/app/main_layout.dart';
import 'package:legalfactfinder2025/features/authentication/presentation/login_page.dart';
import 'package:legalfactfinder2025/features/authentication/presentation/register_page.dart';
import 'package:legalfactfinder2025/features/authentication/presentation/reset_password_page.dart';
import 'package:legalfactfinder2025/features/authentication/presentation/verify_email_page.dart';
import 'package:legalfactfinder2025/features/notification/presentation/notification_screen.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/work_room_page.dart';
import 'package:legalfactfinder2025/features/chat/presentation/chat_screen.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/invitation_page.dart';
import 'package:legalfactfinder2025/features/friend/presentation/friend_list_screen.dart';
import 'package:legalfactfinder2025/features/friend/presentation/friend_request_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';

  static const String resetPW = '/reset-password';
  static const String verifyEmail = '/verify-email';


   static const String main = '/main';

  static const String workRoom = '/work_room/:workRoomId';
  static const String invitation = '/invitation';
  static const String friendRequest = '/friend_request';

  static const String userNotifications = '/user_notifications';

  static final List<GetPage> routes = [
    GetPage(name: login, page: () =>   LoginPage()),
    GetPage(name: register, page: () =>   RegisterPage()),
    GetPage(name: verifyEmail, page: () =>   VerifyEmailPage()),

    GetPage(name: resetPW, page: () =>   ResetPasswordPage()),
     GetPage(name: main, page: () =>   MainLayout()),
    GetPage(name: workRoom, page: () =>   WorkRoomPage()),
    GetPage(name: invitation, page: () => const InvitationPage()),
    GetPage(name: friendRequest, page: () =>   FriendRequestPage()),
    GetPage(name:userNotifications, page: () => NotificationPage()),
    GetPage(name: '/reset-password', page: () => ResetPasswordPage()),
  ];
}
