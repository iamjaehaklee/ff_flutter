// lib/utils/image_utils.dart 🔶
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<Uint8List?> downloadImageFromSupabase(
    String storageKey, {
      String bucketName = 'work_room_annotations',
    }) async {
  try {
    final storage = Supabase.instance.client.storage.from(bucketName);
    // download()는 이제 Uint8List를 직접 반환합니다.
    final Uint8List data = await storage.download(storageKey);
    return data;
  } catch (e) {
    print("Error downloading image for key $storageKey: $e");
    return null;
  }
}
