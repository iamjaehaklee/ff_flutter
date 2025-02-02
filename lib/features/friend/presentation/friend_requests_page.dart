import 'package:flutter/material.dart';
import 'recieved_friend_request_list_screen.dart';
import 'sent_friend_request_list_screen.dart';

class FriendRequestsPage extends StatelessWidget {
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

              title: const Text("Friend Requests"),
              bottom: const TabBar(
                tabs: [
                  Tab( text: "Received"),
                  Tab( text: "Sent"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                ReceivedFriendRequestListScreen(),
                SentFriendRequestListScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
