import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullTimelineScreen extends StatefulWidget {
  final String workRoomId;

  const FullTimelineScreen({Key? key, required this.workRoomId}) : super(key: key);

  @override
  State<FullTimelineScreen> createState() => _FullTimelineScreenState();
}

class _FullTimelineScreenState extends State<FullTimelineScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // TODO: 타임라인 데이터 로드
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '전체 타임라인',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: 10, // 임시 데이터
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.access_time),
                    ),
                    title: Text('이벤트 ${index + 1}'),
                    subtitle: Text('2025-02-08 ${index + 1}:00'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}