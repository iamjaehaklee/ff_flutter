import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:legalfactfinder2025/features/confidentiality/presentation/signature_page.dart';
import 'package:legalfactfinder2025/features/confidentiality/signature_status_controller.dart';

class SignatureStatusScreen extends StatelessWidget {
  final String workRoomId; // 작업 방 ID

  final SignatureStatusController controller =
  Get.put(SignatureStatusController());

  final SupabaseClient supabaseClient = Supabase.instance.client; // Supabase 클라이언트

  SignatureStatusScreen({Key? key, required this.workRoomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 작업방의 서명 정보를 불러옵니다.
    controller.loadSignatures(workRoomId);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 서약 내용
          Text(
            'Confidentiality Agreement',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'This work room contains sensitive information. All participating lawyers must sign the confidentiality agreement to ensure that the information, files, and discussions remain secure.',
          ),
          const SizedBox(height: 16),

          // 서명 상태 표시
          Expanded(
            child: Obx(() {
              if (controller.signatures.isEmpty) {
                return const Center(
                  child: Text('No signatures available'),
                );
              }
              return ListView.builder(
                itemCount: controller.signatures.length,
                itemBuilder: (context, index) {
                  final signature = controller.signatures[index];
                  final imageUrl = signature.imageFileStorageKey != null
                      ? supabaseClient.storage
                      .from('work_room_signatures')
                      .getPublicUrl(signature.imageFileStorageKey!)
                       : null;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(signature.profilePictureUrl ?? ''),
                      onBackgroundImageError: (_, __) => const Icon(Icons.person),
                    ),
                    title: Text(signature.username),
                    subtitle: Text(
                      signature.signedAt != null
                          ? 'Signed on ${signature.signedAt?.toLocal()}'
                          : 'Not signed yet',
                      style: TextStyle(
                        color: signature.signedAt != null ? Colors.green : Colors.red,
                      ),
                    ),
                    trailing: signature.signedAt != null
                        ? GestureDetector(
                      onTap: () {
                        _showSignatureImage(context, imageUrl);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 서명 이미지 (반투명 처리)
                          imageUrl != null
                              ? Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.scaleDown,
                            color: Colors.white.withOpacity(0.3),
                            colorBlendMode: BlendMode.darken,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                          )
                              : const Icon(Icons.broken_image),
                          // "SIGN" 텍스트
                          const Text(
                            'SIGN',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        _navigateToSignaturePage(context, signature.userId);
                      },
                      child: const Text('SIGN'),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showSignatureImage(BuildContext context, String? imageUrl) {
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No signature image available')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Signature Image'),
          ),
          body: Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSignaturePage(BuildContext context, String userId) {
    Get.to(() => SignaturePage(userId: userId, workRoomId: workRoomId))!.then((result) {
      if (result == true) {
        // 서명을 완료한 경우 상태를 업데이트
        controller.refreshSignatures(workRoomId);
      }
    });
  }
}
