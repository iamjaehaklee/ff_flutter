import 'package:flutter/material.dart';

class AnnotationDialog extends StatelessWidget {
  final Function(String) onSave;

  const AnnotationDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return AlertDialog(
      title: const Text("Add Comment"),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: 3,
        decoration: const InputDecoration(hintText: "Enter your comment"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            onSave(controller.text);
            Navigator.of(context).pop();
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
