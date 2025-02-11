// lib/features/files/presentation/widgets/annotation_controls.dart
import 'package:flutter/material.dart';

class AnnotationControls extends StatelessWidget {
  final bool isAnnotationMode;
  final Future<void> Function() onToggle;

  const AnnotationControls({
    Key? key,
    required this.isAnnotationMode,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isAnnotationMode
        ? Column(
      children: [
        // FloatingActionButton(
        //   heroTag: "Cancel",
        //   backgroundColor: Colors.red,
        //   onPressed: onToggle,
        //   child: const Icon(Icons.close, color: Colors.white),
        // ),
        // const SizedBox(height: 8),
        // FloatingActionButton(
        //   heroTag: "Confirm",
        //   backgroundColor: Colors.green,
        //   onPressed: () {
        //     // 확인 버튼 누르면 하단 다이얼로그 호출
        //     showModalBottomSheet(
        //       context: context,
        //       isScrollControlled: true,
        //       builder: (context) {
        //         return Container(
        //           padding: const EdgeInsets.all(16),
        //           child: const Text("Annotation 저장 처리 구현"),
        //         );
        //       },
        //     );
        //   },
        //   child: const Icon(Icons.check, color: Colors.white),
        // ),
      ],
    )
        : FloatingActionButton(
      heroTag: "ToggleAnnotation",
      onPressed: onToggle,
      backgroundColor: Colors.blue,
      child: const Icon(Icons.add_comment, color: Colors.white),
    );
  }
}
