import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IssueTimelineScreen extends StatefulWidget {
  final String workRoomId;

  const IssueTimelineScreen({Key? key, required this.workRoomId}) : super(key: key);

  @override
  State<IssueTimelineScreen> createState() => _IssueTimelineScreenState();
}

class _IssueTimelineScreenState extends State<IssueTimelineScreen> {
  int _selectedIssueIndex = 0;
  final List<String> _issues = ['이슈 1', '이슈 2', '이슈 3', '이슈 4'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이슈별 타임라인',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _issues.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_issues[index]),
                    selected: _selectedIssueIndex == index,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedIssueIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.flag),
                    ),
                    title: Text('${_issues[_selectedIssueIndex]} 관련 이벤트 ${index + 1}'),
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