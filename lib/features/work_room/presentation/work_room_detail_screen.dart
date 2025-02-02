import 'package:flutter/material.dart';
import 'package:legalfactfinder2025/features/work_room/data/work_room_model.dart';

class WorkRoomDetailScreen extends StatelessWidget {
  final WorkRoom workRoom;

  const WorkRoomDetailScreen({Key? key, required this.workRoom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WorkRoom title
            Text(
              workRoom.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            // WorkRoom description
            Text(
              workRoom.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Participants section
            const Text(
              "Participants",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workRoom.participants.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final participant = workRoom.participants[index];
                return ParticipantTile(participant: participant);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ParticipantTile extends StatelessWidget {
  final Participant participant;

  const ParticipantTile({Key? key, required this.participant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile picture
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(participant.profilePictureUrl),
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(width: 12),
        // Participant details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                participant.username,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                participant.isLawyer ? "Lawyer" : "Participant",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        // Admin Badge
        if (participant.isAdmin)
          const Text(
            "Admin",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
      ],
    );
  }
}
