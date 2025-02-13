import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/constants.dart';
import 'package:legalfactfinder2025/features/chat/presentation/thread_list_screen.dart';
import 'package:legalfactfinder2025/features/audio_record/presentation/audio_recorder_page.dart';
import 'package:legalfactfinder2025/features/data_analysis/presentation/data_analysis_layout_screen.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/work_room_request_page.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_with_participants_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_request_model.dart';
import 'package:legalfactfinder2025/features/chat/presentation/chat_screen.dart';
import 'package:legalfactfinder2025/features/files/presentation/files_screen.dart';
import 'package:legalfactfinder2025/features/calendar/presentation/calendar_screen.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/work_room_detail_screen.dart';
import 'package:legalfactfinder2025/features/confidentiality/presentation/signature_status_screen.dart';

class WorkRoomUI extends StatefulWidget {
  final WorkRoomWithParticipants workRoomWithParticipants;
  final List<WorkRoomRequest> pendingRequests;
  final bool isRoundedScreen;
  final Map<String, String> participantsMap;
  final String workRoomId;
  final String userId;

  const WorkRoomUI({
    Key? key,
    required this.workRoomWithParticipants,
    required this.pendingRequests,
    required this.isRoundedScreen,
    required this.participantsMap,
    required this.workRoomId,
    required this.userId,
  }) : super(key: key);

  @override
  _WorkRoomUIState createState() => _WorkRoomUIState();
}

class _WorkRoomUIState extends State<WorkRoomUI> {
  late Offset _buttonPosition;
  Offset? _dragOffset; // 드래그 시작 시 버튼과 손가락의 차이를 저장

  @override
  void initState() {
    super.initState();
    // 기본 위치를 좌측 16, 상단은 isRoundedScreen에 따라 32 또는 16으로 설정
    _buttonPosition = Offset(16, widget.isRoundedScreen ? 32 : 16);
  } // end of initState

  @override
  Widget build(BuildContext context) {
    // WorkRoomUI는 Scaffold나 DefaultTabController 없이, 상위에서 제공하는 컨트롤러를 그대로 사용합니다.

    return Stack(
      children: [
        TabBarView(
          physics: const NeverScrollableScrollPhysics(), // 스와이프 비활성화
          children: [
            ChatScreen(
                workRoomWithParticipants: widget.workRoomWithParticipants,
                myUserId: widget.userId),
            FilesScreen(
                workRoomId: widget.workRoomId),
            DataAnalysisLayoutScreen(workRoomId: widget.workRoomId),
            CalendarScreen(),
            WorkRoomDetailScreen(
                workRoomWithParticipants: widget.workRoomWithParticipants,
                pendingRequests: widget.pendingRequests),
            SignatureStatusScreen(
                workRoomId: widget.workRoomId),
          ],
        ),
        // 드래그 및 터치가 가능한 버튼 (위치가 사용자의 손동작에 정확히 따라오도록 구현)
        Positioned(
          top: _buttonPosition.dy,
          left: _buttonPosition.dx,
          child: GestureDetector(
            onPanStart: (details) {
              // 드래그 시작 시, 손가락과 버튼의 위치 차이를 계산
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              _dragOffset = localPosition - _buttonPosition;
            }, // end of onPanStart
            onPanUpdate: (details) {
              // 현재 손가락 위치에서 시작 오프셋을 빼서 버튼의 위치를 설정
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              setState(() {
                _buttonPosition = localPosition - (_dragOffset ?? Offset.zero);
              });
            }, // end of onPanUpdate
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => ThreadListScreen(
                  workRoomId: widget.workRoomWithParticipants.workRoom.id,
                  participantList: widget.workRoomWithParticipants.participants,
                ),
              );
            }, // end of onTap
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
              child: const Icon(Icons.view_list, color: Colors.white, size: 20),
            ), // end of Container
          ), // end of GestureDetector
        ), // end of Positioned
      ],
    );
  }
}
