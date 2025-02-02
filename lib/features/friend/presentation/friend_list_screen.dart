import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/friend/friend_list_controller.dart';
import 'package:legalfactfinder2025/features/friend/presentation/friend_request_page.dart';
import 'package:legalfactfinder2025/features/friend/presentation/friend_requests_page.dart';
import 'package:legalfactfinder2025/features/profile/presentation/profile_page.dart';

class FriendListScreen extends StatefulWidget {
  FriendListScreen({Key? key}) : super(key: key);

  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  late FriendListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<FriendListController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildFriendList(),
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              mini: true,
              onPressed: _navigateToFriendRequests,
              child: const Icon(
                Icons.person_add_alt_1,
                color: Colors.blue,
              ),
              tooltip: "View Friend Requests",
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToFriendRequests() {
    Get.to(() => FriendRequestsPage());
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String errorMessage) {
    return Center(
      child: Text(
        errorMessage,
        style: const TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/friend_placeholder.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            "아직 친구가 없습니다!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "친구를 추가하고 함께 법률 문제를 논의하세요.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => FriendRequestPage());
              },
              child: const Text("내 첫 친구 추가하기"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendList() {
    return Obx(() {
      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchFriends();
        },
        color: Theme.of(context).colorScheme.secondary,
        child: controller.isLoading.value
            ? Container(
          color: Colors.grey[400],
          child: ListView(
            children: const [
              SizedBox(height: 250),
              Center(child: CircularProgressIndicator()),
            ],
          ),
        )
            : controller.errorMessage.value.isNotEmpty
            ? _buildError(controller.errorMessage.value)
            : controller.friends.isEmpty
            ? _buildEmptyState()
            : Container(
          color: Colors.grey[400],
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 0),
            itemCount: controller.friends.length,
            separatorBuilder: (context, index) =>
            const Divider(thickness: 1, height: 1),
            itemBuilder: (context, index) {
              final friend = controller.friends[index];
              return FriendTile(friend: friend);
            },
          ),
        ),
      );
    });
  }
}

class FriendTile extends StatelessWidget {
  final dynamic friend;

  const FriendTile({Key? key, required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => ProfilePage(), arguments: friend.id);
      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(friend.profilePictureUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.username,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      friend.isLawyer ? 'Lawyer' : 'Not a Lawyer',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
