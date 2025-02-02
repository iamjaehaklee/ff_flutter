import 'package:flutter/material.dart';

class InputAnnotationBottomSheet extends StatelessWidget {
  final Function(String) onSave;

  const InputAnnotationBottomSheet({
    Key? key,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String annotationText = "";

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: "Enter annotation",
              border: OutlineInputBorder(),
            ),
            minLines: 3,
            maxLines: 8,
            onChanged: (value) => annotationText = value,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (annotationText.isNotEmpty) {
                onSave(annotationText);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
