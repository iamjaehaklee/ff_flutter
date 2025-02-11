import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/audio_record/presentation/audio_recorder_page.dart';
import 'package:legalfactfinder2025/features/authentication/auth_controller.dart';
import 'package:legalfactfinder2025/features/work_room/data/participant_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_with_participants_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_request_model.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/widgets/work_room_ui.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/widgets/work_room_loading_error.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/work_room_request_page.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_request_controller.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_controller.dart';

class WorkRoomPage extends StatefulWidget {
  const WorkRoomPage({Key? key}) : super(key: key);

  @override
  _WorkRoomPageState createState() => _WorkRoomPageState();
}

class _WorkRoomPageState extends State<WorkRoomPage> {
  late AuthController authController;
  late WorkRoomController workRoomController;
  late WorkRoomRequestController requestController;
  String? workRoomId;
  String? userId;
  WorkRoomWithParticipants? workRoomWithParticipants;
  // 초대 요청은 이제 WorkRoomDetailScreen에서 로드하므로, 여기선 빈 리스트를 전달합니다.
  List<WorkRoomRequest> pendingRequests = [];
  bool isLoading = true;
  String? errorMessage;
  final bool isRoundedScreen = Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    authController = Get.find<AuthController>();
    workRoomController = Get.find<WorkRoomController>();
    requestController = Get.put(WorkRoomRequestController());

    userId = authController.getUserId();
    if (userId == null) {
      Future.delayed(Duration.zero, () => Get.offAllNamed('/login'));
      return;
    }

    workRoomId = Get.parameters['workRoomId'];
    if (workRoomId == null) {
      setState(() {
        errorMessage = 'Invalid workRoomId: null';
        isLoading = false;
      });
      return;
    }

    _loadWorkRoomWithParticipants();
  }

  Future<void> _loadWorkRoomWithParticipants() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      // 워크룸 정보만 로드합니다. (초대 요청 데이터는 여기서 로드하지 않음)
      await workRoomController
          .fetchWorkRoomWithParticipantsByWorkRoomId(workRoomId!);
      setState(() {
        workRoomWithParticipants =
            workRoomController.workRoomWithParticipants.value;
        // pendingRequests는 빈 리스트를 전달합니다.
        pendingRequests = [];
        isLoading = false;
      });
      print(
          "[WorkRoomPage] Fetched workRoomWithParticipants: ${workRoomWithParticipants!.toJson()}");
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      print("[WorkRoomPage] Error fetching workRoomWithParticipants: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null || workRoomId == null) {
      return WorkRoomLoadingError(
        isLoading: false,
        errorMessage: 'Invalid user or work room ID.',
      );
    }

    if (isLoading || errorMessage != null) {
      return WorkRoomLoadingError(
        isLoading: isLoading,
        errorMessage: errorMessage,
      );
    }

    if (workRoomWithParticipants == null) {
      return const WorkRoomLoadingError(
        isLoading: false,
        errorMessage: 'Work room not found.',
      );
    }

    // return WorkRoomUI(
    //   workRoomWithParticipants: workRoom!,
    //   pendingRequests: pendingRequests, // 빈 리스트 전달
    //   isRoundedScreen: isRoundedScreen,
    //   participantsMap: {
    //     for (Participant participant in workRoom!.participants)
    //       participant.userId: participant.username,
    //   },
    //   workRoomId: workRoomId!,
    //   userId: userId!,
    // );

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          shadowColor: Colors.black45,
          surfaceTintColor: Colors.white,
          elevation: 1,
          // AppBar의 title만 Obx로 감싸서 workRoomController의 workRoom 값이 변경되면 제목이 자동 갱신됨
          title: Obx(() {
            if (workRoomController.isLoading.value) {
              print(
                  "[WorkRoomPage] workRoomController.isLoading is true, displaying 'Loading Work Room...'");
              return const Text("Loading Work Room...");
            }
            if (workRoomController.errorMessage.isNotEmpty) {
              print(
                  "[WorkRoomPage] workRoomController.errorMessage is not empty: ${workRoomController.errorMessage.value}, displaying 'Error'");
              return const Text("Error");
            }
            if (workRoomController.workRoomWithParticipants.value == null) {
              print(
                  "[WorkRoomPage] workRoomWithParticipants is null, displaying 'Work Room'");
              return const Text("Work Room");
            }
            final updatedTitle = workRoomController
                .workRoomWithParticipants.value!.workRoom.title;
            print("[WorkRoomPage] Updated AppBar title: $updatedTitle");
            return Text(updatedTitle);
          }),
          actions: [
            // 필요한 액션 버튼 추가 가능
            GestureDetector(
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
                padding:
                    EdgeInsets.only(right: 24.0, left: 8, top: 8, bottom: 8),
                child: Icon(
                  Icons.add_box,
                  size: ICON_SIZE_AT_APPBAR,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.lightBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(icon: Icon(Icons.chat, size: ICON_SIZE_AT_APPBAR)),
              Tab(icon: Icon(Icons.attach_file, size: ICON_SIZE_AT_APPBAR)),
              Tab(icon: Icon(Icons.data_object, size: ICON_SIZE_AT_APPBAR)),

              Tab(icon: Icon(Icons.calendar_today, size: ICON_SIZE_AT_APPBAR)),
              Tab(icon: Icon(Icons.info, size: ICON_SIZE_AT_APPBAR)),
              Tab(icon: Icon(Icons.lock, size: ICON_SIZE_AT_APPBAR)),
            ],
          ),
        ), // end of AppBar
        // WorkRoomUI는 Scaffold나 DefaultTabController를 포함하지 않음
        body: WorkRoomUI(
          workRoomWithParticipants: workRoomWithParticipants!,
          pendingRequests: pendingRequests,
          isRoundedScreen: isRoundedScreen,
          participantsMap: {
            for (Participant participant
                in workRoomWithParticipants!.participants)
              participant.userId: participant.username,
          },
          workRoomId: workRoomId!,
          userId: userId!,
        ),
      ),
    );
  } // end of build end of build

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
