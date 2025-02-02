import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/chat/presentation/chat_screen.dart';
import 'package:legalfactfinder2025/features/confidentiality/presentation/signature_status_screen.dart';
import 'package:legalfactfinder2025/features/files/presentation/files_screen.dart';
import 'package:legalfactfinder2025/features/calendar/presentation/calendar_screen.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_repository.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/work_room_detail_screen.dart';
import 'package:legalfactfinder2025/features/chat/presentation/thread_list_screen.dart';
import 'package:legalfactfinder2025/features/audio_record/presentation/audio_recorder_page.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/work_room_request_page.dart';

class WorkRoomPage extends StatefulWidget {
  const WorkRoomPage({Key? key}) : super(key: key);

  @override
  _WorkRoomPageState createState() => _WorkRoomPageState();
}

class _WorkRoomPageState extends State<WorkRoomPage> {
  late AuthController authController;
  late WorkRoomRepository workRoomRepository;
  String? workRoomId;
  String? userId;
  WorkRoom? workRoom;
  bool isLoading = true;
  String? errorMessage;
  final bool isRoundedScreen = Platform.isIOS;

  @override
  void initState() {
    super.initState();

    authController = Get.find<AuthController>();
    workRoomRepository = WorkRoomRepository();

    userId = authController.getUserId();
    if (userId == null) {
      Future.delayed(Duration.zero, () => Get.offAllNamed('/login'));
      return;
    }

    workRoomId = Get.parameters['workRoomId'];
    if (workRoomId == null) {
      errorMessage = 'Invalid workRoomId: null';
      return;
    }

    _fetchWorkRoom();
  }

  Future<void> _fetchWorkRoom() async {
    try {
      final fetchedWorkRoom =
          await workRoomRepository.getWorkRoomById(workRoomId!);
      setState(() {
        workRoom = fetchedWorkRoom;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null || workRoomId == null) {
      return _buildError('Invalid user or work room ID.');
    }

    if (isLoading) {
      return _buildLoading();
    }

    if (errorMessage != null) {
      return _buildError(errorMessage!);
    }

    if (workRoom == null) {
      return _buildError('Work room not found.');
    }

    return _buildWorkRoomUI(context, workRoom!);
  }

  Widget _buildLoading() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(String message) {
    return Scaffold(
      body: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildWorkRoomUI(BuildContext context, WorkRoom workRoom) {
    final participantsMap = {
      for (var participant in workRoom.participants)
        participant.userId: participant.username,
    };

    return DefaultTabController(
      length: 5,
      child: Container(
        color: Colors.white, // 노치 및 홈 인디케이터 영역도 흰색 적용

        child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,

            backgroundColor: Colors.white,
            appBar: AppBar(

              shadowColor: Colors.black45,
              surfaceTintColor: Colors.white,
              elevation: 1,
              title: Text(
                workRoom.title,
                style: TextStyle(fontSize: 18),
              ),
              actions: [
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
                  onTap: () => _showBottomSheet(context),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 24.0, left: 8, top: 8, bottom: 8),
                    child: Icon(
                      Icons.add_box,
                      size: ICON_SIZE_AT_APPBAR,
                      color: Colors.grey,
                    ),
                  ),
                ),
                // IconButton(
                //   padding: EdgeInsets.only(right: 16.0), // 왼쪽으로 4px 이동
                //
                //   icon: const Icon(
                //     Icons.add_box,
                //     color: Colors.grey,
                //     size: ICON_SIZE_AT_APPBAR,
                //   ),
                //   onPressed: () => _showBottomSheet(context),
                // ),
              ],
              bottom: const TabBar(
                labelColor: Colors.lightBlue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.transparent,

                tabs: [
                  Tab(icon: Icon(Icons.chat, size: ICON_SIZE_AT_APPBAR)),
                  Tab(icon: Icon(Icons.attach_file, size: ICON_SIZE_AT_APPBAR)),
                  Tab(
                      icon: Icon(Icons.calendar_today,
                          size: ICON_SIZE_AT_APPBAR)),
                  Tab(icon: Icon(Icons.info, size: ICON_SIZE_AT_APPBAR)),
                  Tab(icon: Icon(Icons.lock, size: ICON_SIZE_AT_APPBAR)),
                ],
              ),
            ),
            body: Stack(
              children: [
                TabBarView(
                  children: [
                    ChatScreen(workRoom: workRoom, myUserId: userId!),
                    FilesScreen(workRoomId: workRoom.id),
                    CalendarScreen(),
                    WorkRoomDetailScreen(workRoom: workRoom),
                    SignatureStatusScreen(workRoomId: workRoom.id),
                  ],
                ),
                Positioned(
                  top: isRoundedScreen ? 32 : 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) => ThreadListScreen(
                          workRoomId: workRoom.id,
                          participantsMap: participantsMap,
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.view_list,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('친구 초대'),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => WorkRoomRequestPage(workRoomId: workRoomId!));
                },
              ),
              ListTile(
                leading: const Icon(Icons.note_add),
                title: const Text('회의록 생성'),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => AudioRecorderPage());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
