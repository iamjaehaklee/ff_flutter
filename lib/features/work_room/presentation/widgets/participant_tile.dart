import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/work_room/data/participant_model.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_with_participants_model.dart';

class ParticipantTile extends StatelessWidget {
  final Participant participant;

  const ParticipantTile({Key? key, required this.participant})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(
        "[ParticipantTile] build() called for participant: ${participant.username}");
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(participant.imageFileStorageKey),
        backgroundColor: Colors.grey[300],
      ),
      title: Text(participant.username,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(participant.isLawyer ? "Lawyer" : "Participant"),
      trailing: participant.isAdmin
          ? const Chip(
              label: Text("Admin"),
              backgroundColor: Colors.blue,
              labelStyle: TextStyle(color: Colors.white, fontSize: 12),
            )
          : null,
    );
  } // end of build in ParticipantTile
} // end of ParticipantTile
