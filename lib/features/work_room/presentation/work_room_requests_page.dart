import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/recieved_work_room_request_list_screen.dart';
import 'package:legalfactfinder2025/features/work_room/presentation/sent_work_room_request_list_screen.dart';


class WorkRoomRequestsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
                surfaceTintColor : Colors.white,
              title: Text("Work Room Invitations"),
              bottom: TabBar(
                tabs: [
                  Tab( text: "Received"),
                  Tab( text: "Sent"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                RecievedWorkRoomRequestListScreen(),
                SentWorkRoomRequestListScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
