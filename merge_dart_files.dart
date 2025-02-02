import 'dart:io';

void main() async {
  final String targetDirectory = "./lib"; // 여기에 원하는 폴더 경로를 설정하세요.
  final String outputFileName = "merged_dart_files.txt";

  final File outputFile = File(outputFileName);
  if (outputFile.existsSync()) {
    outputFile.deleteSync();
  }
  outputFile.createSync();

  final IOSink sink = outputFile.openWrite();
  await mergeDartFiles(Directory(targetDirectory), sink);
  await sink.close();

  print("Dart files merged successfully into $outputFileName");
}

Future<void> mergeDartFiles(Directory directory, IOSink sink) async {
  await for (var entity in directory.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      sink.writeln("\n// ===== FILE: ${entity.path} =====\n");
      sink.writeln(await entity.readAsString());
    }
  }
}
