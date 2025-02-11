import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legalfactfinder2025/features/data_analysis/features/full_timeline/presentation/full_timeline_screen.dart';
import 'package:legalfactfinder2025/features/data_analysis/features/issue_timeline/presentation/issue_timeline_screen.dart';
import 'package:legalfactfinder2025/features/data_analysis/features/work_objective/presentation/work_objective_screen.dart';


class DataAnalysisLayoutScreen extends StatefulWidget {
  final String workRoomId;

  const DataAnalysisLayoutScreen({
    Key? key,
    required this.workRoomId,
  }) : super(key: key);

  @override
  State<DataAnalysisLayoutScreen> createState() => _DataAnalysisLayoutScreenState();
}

class _DataAnalysisLayoutScreenState extends State<DataAnalysisLayoutScreen> {
  int _selectedIndex = 0;
  late String workRoomId ;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    workRoomId = widget.workRoomId;  // Now widget is available.
     _screens = [
      FullTimelineScreen(workRoomId: workRoomId,),
      IssueTimelineScreen(workRoomId: workRoomId,),
      WorkObjectiveScreen(workRoomId: workRoomId,),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChip('Full Timeline', 0),
                _buildChip('Issue Timeline', 1),
                _buildChip('Work Objective', 2),
              ],
            ),
          ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, int index) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedIndex == index,
      onSelected: (bool selected) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}
