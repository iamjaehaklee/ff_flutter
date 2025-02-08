import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/work_room/data/participant_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_with_participants_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_request_model.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/widgets/participant_tile.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/widgets/work_room_request_tile.dart';
import 'package:legalfactfinder2025/features/work_room/work_room_controller.dart';

class WorkRoomDetailScreen extends StatefulWidget {
  final WorkRoomWithParticipants workRoomWithParticipants;
  final List<WorkRoomRequest> pendingRequests;

  const WorkRoomDetailScreen({
    Key? key,
    required this.workRoomWithParticipants,
    required this.pendingRequests,
  }) : super(key: key);

  @override
  _WorkRoomDetailScreenState createState() => _WorkRoomDetailScreenState();
} // end of WorkRoomDetailScreen

class _WorkRoomDetailScreenState extends State<WorkRoomDetailScreen> {
  late String title;
  late String? description;
  late List<Participant> participants;
  late List<WorkRoomRequest> pendingRequests;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // 컨트롤러를 final 필드로 선언하여, 클래스 생성 시점에 Get.find()를 호출합니다.
  final WorkRoomController workRoomController = Get.find<WorkRoomController>();

  @override
  void initState() {
    super.initState();
    // 전달받은 데이터로 초기화합니다.
    title = widget.workRoomWithParticipants.workRoom.title;
    description = widget.workRoomWithParticipants.workRoom.description;
    participants = widget.workRoomWithParticipants.participants;
    pendingRequests = widget.pendingRequests;

    _titleController.text = title;
    _descriptionController.text = description ?? '';

    _logInitState();
  } // end of initState

  void _logInitState() {
    print("[WorkRoomDetailScreen] initState() called");
    print("[WorkRoomDetailScreen] workRoom.title: $title");
    print("[WorkRoomDetailScreen] workRoom.description: $description");
    print("[WorkRoomDetailScreen] workRoom.participants count: ${participants.length}");
    print("[WorkRoomDetailScreen] pendingRequests count: ${pendingRequests.length}");
    print("[WorkRoomDetailScreen] workRoom JSON: ${jsonEncode(widget.workRoomWithParticipants.toJson())}");
  } // end of _logInitState

  Future<void> _updateTitle() async {
    print("[WorkRoomDetailScreen] _updateTitle() called");
    final newTitle = await _showEditDialog("Edit Title", _titleController);
    if (newTitle != null && newTitle.trim().isNotEmpty) {
      try {
        // DB 업데이트를 위해 controller의 updateWorkRoom 메서드를 호출합니다.
        await workRoomController.updateWorkRoom(
          widget.workRoomWithParticipants.workRoom.id,
          title: newTitle,
        );
        // 업데이트 후, controller의 최신 데이터로 local title 업데이트
        setState(() {
          title = workRoomController.workRoomWithParticipants.value!.workRoom.title;
        });
        print("[WorkRoomDetailScreen] Title updated to: $title");
      } catch (e) {
        print("[WorkRoomDetailScreen] Failed to update title: $e");
      }
    }
  } // end of _updateTitle

  Future<void> _updateDescription() async {
    print("[WorkRoomDetailScreen] _updateDescription() called");
    final newDescription = await _showEditDialog("Edit Description", _descriptionController);
    if (newDescription != null && newDescription.trim().isNotEmpty) {
      try {
        // DB 업데이트를 위해 controller의 updateWorkRoom 메서드를 호출합니다.
        await workRoomController.updateWorkRoom(
          widget.workRoomWithParticipants.workRoom.id,
          description: newDescription,
        );
        // 업데이트 후, controller의 최신 데이터로 local description 업데이트
        setState(() {
          description = workRoomController.workRoomWithParticipants.value!.workRoom.description;
        });
        print("[WorkRoomDetailScreen] Description updated to: $description");
      } catch (e) {
        print("[WorkRoomDetailScreen] Failed to update description: $e");
      }
    }
  } // end of _updateDescription

  Future<String?> _showEditDialog(String title, TextEditingController controller) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: "New ${title.split(' ')[1]}"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text("Save"),
          ),
        ],
      ), // end of AlertDialog
    ); // end of showDialog
  } // end of _showEditDialog

  void _sendInvite() {
    print("[WorkRoomDetailScreen] _sendInvite() called");
    // TODO: Implement invite logic
  } // end of _sendInvite

  @override
  Widget build(BuildContext context) {
    _logBuild();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionWithEdit("Title", title, _updateTitle),
          const SizedBox(height: 20),
          Divider(color: Colors.black26), // end of Divider
          const SizedBox(height: 10),
          _buildSectionWithEdit("Description", description ?? '', _updateDescription),
          const SizedBox(height: 20),
          Divider(color: Colors.black26), // end of Divider
          const SizedBox(height: 10),
          _buildSection("Participants", _buildParticipantsList()),
          const SizedBox(height: 32),
          Divider(color: Colors.black26), // end of Divider
          const SizedBox(height: 10),
          _buildSection("Pending Invitations", _buildPendingInvitationsList()),
          const SizedBox(height: 32),
          _buildSendInviteButton(),
        ],
      ),
    );
  } // end of build

  Widget _buildSectionWithEdit(String label, String content, VoidCallback onEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
            ),
          ],
        ),
      ],
    );
  } // end of _buildSectionWithEdit

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  } // end of _buildSection

  Widget _buildParticipantsList() {
    return participants.isNotEmpty
        ? ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: participants.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, index) => ParticipantTile(participant: participants[index]),
    )
        : Text(
      "No participants.",
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
    );
  } // end of _buildParticipantsList

  Widget _buildPendingInvitationsList() {
    return pendingRequests.isNotEmpty
        ? ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendingRequests.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, index) => WorkRoomRequestTile(request: pendingRequests[index]),
    )
        : Text(
      "No pending invitations.",
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
    );
  } // end of _buildPendingInvitationsList

  Widget _buildSendInviteButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _sendInvite,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text("Send Invite", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  } // end of _buildSendInviteButton

  void _logBuild() {
    print("[WorkRoomDetailScreen] build() called");
    print("[WorkRoomDetailScreen] workRoom.title (current): $title");
    print("[WorkRoomDetailScreen] workRoom.description (current): $description");
    print("[WorkRoomDetailScreen] participants count: ${participants.length}");
    print("[WorkRoomDetailScreen] pendingRequests count: ${pendingRequests.length}");
    print("[WorkRoomDetailScreen] workRoom JSON: ${jsonEncode(widget.workRoomWithParticipants.toJson())}");
  } // end of _logBuild
} // end of _WorkRoomDetailScreenState
