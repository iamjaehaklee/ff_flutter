import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkObjectiveScreen extends StatefulWidget {
  final String workRoomId;
  
  const WorkObjectiveScreen({Key? key, required this.workRoomId}) : super(key: key);

  @override
  State<WorkObjectiveScreen> createState() => _WorkObjectiveScreenState();
}

class _WorkObjectiveScreenState extends State<WorkObjectiveScreen> {
  final List<Map<String, dynamic>> _objectives = [
    {'title': '목표 1', 'progress': 0.7},
    {'title': '목표 2', 'progress': 0.3},
    {'title': '목표 3', 'progress': 0.9},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '업무 목표',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _objectives.length,
              itemBuilder: (context, index) {
                final objective = _objectives[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          objective['title'],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: objective['progress'],
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(objective['progress'] * 100).toInt()}% 완료',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
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