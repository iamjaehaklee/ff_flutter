import 'dart:typed_data';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'folder_model.dart';

class FoldersRepository {
  final SupabaseClient _supabase;

  FoldersRepository([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  // Base64로 폴더명 인코딩
  String _encodeFolderName(String folderName) {
    return base64Url.encode(utf8.encode(folderName)).replaceAll('=', '');
  }

  // Base64로 인코딩된 폴더명 디코딩
  String _decodeFolderName(String encodedName) {
    try {
      // padding을 다시 추가
      final padding = '=' * ((4 - encodedName.length % 4) % 4);
      final paddedName = encodedName + padding;
      return utf8.decode(base64Url.decode(paddedName));
    } catch (e) {
      print("[FoldersRepository] Error decoding folder name: $e");
      return encodedName; // 디코딩 실패시 원래 이름 반환
    }
  }

  /// 폴더 생성
  Future<Folder> createFolder(
      String workRoomId, String currentPath, String folderName) async {
    try {
      print("[FoldersRepository] createFolder: Starting folder creation");
      print(
          "[FoldersRepository] createFolder: workRoomId=$workRoomId, currentPath=$currentPath, folderName=$folderName");

      // 전체 경로 구성
      final folderPath =
          currentPath.isEmpty ? folderName : '$currentPath/$folderName';

      // 1. DB에 폴더 정보 저장
      final response = await _supabase
          .from('folders')
          .insert({
            'work_room_id': workRoomId,
            'created_by': _supabase.auth.currentUser!.id,
            'folder_name': folderName,
            'folder_path': folderPath,
          })
          .select()
          .single();

      print("[FoldersRepository] createFolder: Folder created in DB");

      // 2. Storage에 .keep 파일 생성 (인코딩된 경로 사용)
      final encodedPath =
          folderPath.split('/').map(_encodeFolderName).join('/');
      final fullPath = '$workRoomId/$encodedPath/.keep';
      print(
          "[FoldersRepository] createFolder: Creating .keep file at $fullPath");

      await _supabase.storage.from('work_room_files').uploadBinary(
            fullPath,
            Uint8List(0),
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      print("[FoldersRepository] createFolder: Successfully created folder");
      return Folder.fromJson(response);
    } catch (e) {
      print("[FoldersRepository] createFolder: Error occurred: $e");
      print(
          "[FoldersRepository] createFolder: Stack trace: ${StackTrace.current}");
      rethrow;
    }
  }

  /// 폴더 존재 여부 확인
  Future<bool> folderExists(String workRoomId, String folderPath) async {
    try {
      print("[FoldersRepository] folderExists: Checking folder existence");
      print(
          "[FoldersRepository] folderExists: workRoomId=$workRoomId, path=$folderPath");

      final response = await _supabase
          .from('folders')
          .select('id')
          .eq('work_room_id', workRoomId)
          .eq('folder_path', folderPath)
          .filter('deleted_at', 'is', null)
          .maybeSingle();

      final exists = response != null;
      print("[FoldersRepository] folderExists: Folder exists? $exists");
      return exists;
    } catch (e) {
      print("[FoldersRepository] folderExists: Error occurred: $e");
      print(
          "[FoldersRepository] folderExists: Stack trace: ${StackTrace.current}");
      return false;
    }
  }

  /// 특정 경로의 폴더 목록 조회
  Future<List<Folder>> listFolders(String workRoomId,
      {String path = ''}) async {
    try {
      print("[FoldersRepository] listFolders: Starting to list folders");
      print(
          "[FoldersRepository] listFolders: workRoomId=$workRoomId, path=$path");

      final query = _supabase
          .from('folders')
          .select()
          .eq('work_room_id', workRoomId)
          .filter('deleted_at', 'is', null);

      if (path.isEmpty) {
        // 루트 레벨의 폴더만 조회 (folder_path에 '/'가 없는 경우)
        query.not('folder_path', 'ilike', '%/%');
      } else {
        // 현재 경로의 직계 하위 폴더만 조회
        final prefix = '$path/';
        query
            .ilike('folder_path', '$prefix%')
            .not('folder_path', 'ilike', '$prefix%/%');
      }

      final response = await query;
      final folders = response.map((json) => Folder.fromJson(json)).toList();

      print("[FoldersRepository] listFolders: Found ${folders.length} folders");
      print(
          "[FoldersRepository] listFolders: Folder names: ${folders.map((f) => f.folderName).join(', ')}");

      return folders;
    } catch (e) {
      print("[FoldersRepository] listFolders: Error occurred: $e");
      print(
          "[FoldersRepository] listFolders: Stack trace: ${StackTrace.current}");
      return [];
    }
  }

  /// 폴더 삭제 (soft delete)
  Future<void> deleteFolder(String folderId) async {
    try {
      print("[FoldersRepository] deleteFolder: Starting folder deletion");
      print("[FoldersRepository] deleteFolder: folderId=$folderId");

      await _supabase.from('folders').update(
          {'deleted_at': DateTime.now().toIso8601String()}).eq('id', folderId);

      print(
          "[FoldersRepository] deleteFolder: Successfully marked folder as deleted");
    } catch (e) {
      print("[FoldersRepository] deleteFolder: Error occurred: $e");
      print(
          "[FoldersRepository] deleteFolder: Stack trace: ${StackTrace.current}");
      rethrow;
    }
  }
}
