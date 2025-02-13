import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/constants.dart'; // BOTTOM_SHEET_TOP_MARGIN 정의된 파일

Future<T?> showCustomBottomSheet<T>({
  required Widget Function(StateSetter setModalState) titleBuilder,
  required BuildContext context,
  required Widget Function(BuildContext context) contentBuilder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: titleBuilder(setModalState),
              ),
              Container(
                height: MediaQuery.of(context).size.height -
                    (16 + 16 + 14 + BOTTOM_SHEET_TOP_MARGIN + BOTTOM_SHEET_TOP_MARGIN),
                child: contentBuilder(context),
              ),
            ],
          );
        },
      );
    },
  );
}
