import 'package:flutter/material.dart';

class InvitationPage extends StatelessWidget {
  const InvitationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitation'),
      ),
      body: const Center(
        child: Text('Invitation Page'),
      ),
    );
  }
}
