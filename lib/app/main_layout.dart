import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/app/widgets/main_layout_bottom_sheet_actions.dart';
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/audio_record/presentation/audio_recorder_page.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/friend/friend_list_controller.dart';
import 'package:legalfactfinder2025/features/friend/presentation/friend_request_page.dart';
import 'package:legalfactfinder2025/features/notification/presentation/notification_screen.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/work_room_list_screen.dart';
import 'package:legalfactfinder2025/features/friend/presentation/friend_list_screen.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/add_work_room_page.dart';
import 'package:legalfactfinder2025/core/setting/setting_screen.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_list_controller.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late AuthController authController;
  final WorkRoomListController workRoomListController =
      Get.find<WorkRoomListController>();
  final FriendListController friendListController =
      Get.find<FriendListController>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize the AuthController
    authController = Get.find<AuthController>();

    // Fetch userId and check authentication status
    print("Checking authentication status...");
    authController.refreshUser(); // Refresh user info

    if (authController.userId.value != null) {
      workRoomListController.fetchWorkRooms();
      friendListController.fetchFriends();
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final isRoundedDevice = Platform.isIOS && bottomPadding > 20;

    final List<Widget> screens = [
      WorkRoomListScreen(),
      FriendListScreen(),
      const Center(child: Text('Call History Page')),
      SettingScreen(),
    ];

    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Colors.black45,
          // ✅ 그림자 색상을 진하게 설정
          elevation: 1,
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              // Expanded(
              //   child: GestureDetector(
              //     onTap: () {
              //       print("Search tapped");
              //     },
              //     child: Container(
              //       height: 36,
              //       decoration: BoxDecoration(
              //         color: Colors.black.withOpacity(0.1),
              //         borderRadius: BorderRadius.circular(25),
              //       ),
              //       padding: const EdgeInsets.symmetric(horizontal: 12),
              //       alignment: Alignment.centerLeft,
              //       child: Row(
              //         children: const [
              //           Icon(Icons.search),
              //           SizedBox(width: 8),
              //           Text('Search...', style: TextStyle(fontSize: 14)),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              // const SizedBox(width: 16),
              Text('Legal FactFinder'),
              Expanded(child: Container()),
              GestureDetector(
                // onTap: () => showMainLayoutBottomSheet(context),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.search,
                    size: ICON_SIZE_AT_APPBAR,
                    color: Colors.grey,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => showMainLayoutBottomSheet(context),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.add_box,
                    size: ICON_SIZE_AT_APPBAR,
                    color: Colors.grey,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  print("Navigating to Notifications page...");
                  Get.to(() => NotificationPage());
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.notifications, size: ICON_SIZE_AT_APPBAR, color: Colors.grey,),
                ),
              ),
            ],
          ),
        ),
        body: screens[_selectedIndex], // ✅ 전체 Obx 제거
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 1,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room),
              label: "WorkRoom",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: "Friends",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "History",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
