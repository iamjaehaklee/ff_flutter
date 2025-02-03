import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;

  const UserAvatar({Key? key, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: CircleAvatar(
        backgroundColor: Colors.blueGrey,
        radius: 12,
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
        child: imageUrl == null ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
      ),
    );
  }
}
