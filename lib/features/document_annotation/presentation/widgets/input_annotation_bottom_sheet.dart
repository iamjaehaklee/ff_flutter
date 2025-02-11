import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InputAnnotationBottomSheet extends StatelessWidget {
  final Function(String) onSave;
  final Uint8List? image;

  const InputAnnotationBottomSheet({
    Key? key,
    required this.onSave,    this.image,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String annotationText = "";

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          if (image != null) Image.memory(image!, height: 150),
          const SizedBox(height: 16),

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
          Row(
            mainAxisAlignment:MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 150,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
              SizedBox(width: 30,),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    if (annotationText.isNotEmpty) {
                      onSave(annotationText);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save comment"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
