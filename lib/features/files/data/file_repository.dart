import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FileRepository {
  Future<File?> downloadFile({
    required String bucketName,
    required String filePath,
    required String fileName,
  }) async {
    try {
      print("Downloading file from: $bucketName/$filePath");

      // Download file from Supabase Storage
      final Uint8List response = await Supabase.instance.client.storage
          .from(bucketName)
          .download(filePath);

      // Save file locally
      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/$fileName';
      final file = File(localPath);
      await file.writeAsBytes(response);

      print("File saved locally: $localPath");
      return file;
    } catch (e) {
      print("Error downloading file: $e");
      return null;
    }
  }
}
