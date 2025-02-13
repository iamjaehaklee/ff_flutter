// // lib/utils/annotation_thread_bottom_sheet.dart 🔶
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:legalfactfinder2025/features/document_annotation/data/document_annotation_model.dart';
// import 'package:legalfactfinder2025/features/document_annotation/presentation/annotation_thread_screen.dart';
//
// Future<void> showAnnotationThreadBottomSheet({
//   required BuildContext context,
//   required DocumentAnnotationModel annotation,
// }) async {
//   debugPrint(
//       '[showAnnotationThreadBottomSheet] Opening AnnotationThreadScreen with annotation: ${jsonEncode(annotation.toJson())}');
//   await showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.white,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (context) {
//       return DraggableScrollableSheet(
//         initialChildSize: 0.9,
//         maxChildSize: 0.9,
//         minChildSize: 0.4,
//         expand: false,
//         builder: (context, scrollController) {
//           return AnnotationThreadScreen(
//             annotation: annotation,
//             scrollController: scrollController,
//           );
//         },
//       );
//     },
//   );
// }
