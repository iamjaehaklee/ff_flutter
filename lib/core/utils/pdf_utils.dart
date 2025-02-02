import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pdfrx/pdfrx.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PdfUtils {
  /// PDF 페이지를 이미지(Uint8List)로 변환
  static Future<ui.Image?> convertPdfPageToImage(String pdfPath, int pageNumber,
      {double scaleFactor = 1}) async {
    debugPrint(
        "[PdfUtils] convertPdfPageToImage() 시작 - pdfPath: $pdfPath, pageNumber: $pageNumber, scaleFactor: $scaleFactor");

    PdfDocument? doc;
    try {
      if (pdfPath.isEmpty) {
        throw ArgumentError("pdfPath가 비어 있습니다.");
      }
      if (pageNumber < 1) {
        throw ArgumentError("pageNumber는 1 이상이어야 합니다.");
      }

      // PDF 문서 열기
      debugPrint("[PdfUtils] PDF 문서 로드 중... (경로: $pdfPath)");
      doc = await PdfDocument.openFile(pdfPath);
      debugPrint("[PdfUtils] PDF 문서 로드 완료 (총 ${doc.pages.length} 페이지)");

      if (pageNumber > doc.pages.length) {
        throw ArgumentError(
            "pageNumber가 문서의 총 페이지 수를 초과합니다. (총 ${doc.pages.length} 페이지)");
      }

      // PDF 페이지 가져오기
      debugPrint("[PdfUtils] 페이지 가져오는 중... (pageNumber: $pageNumber)");
      final page = await doc.pages[pageNumber - 1];
      if (page == null) {
        debugPrint("[PdfUtils] 페이지 가져오기 실패 (null 반환됨)");
        return null;
      }
      debugPrint(
          "[PdfUtils] 페이지 가져오기 완료. (크기: ${page.width} x ${page.height})");

      // 페이지를 이미지로 렌더링
      debugPrint("[PdfUtils] 페이지 렌더링 시작... (scaleFactor: $scaleFactor)");
      PdfImage? pdfImage = await page.render(
        width: (page.width * scaleFactor).toInt(),
        height: (page.height * scaleFactor).toInt(),
      );
      debugPrint("[PdfUtils] 페이지 렌더링 완료.");

      if (pdfImage == null || pdfImage.pixels.isEmpty) {
        debugPrint("[PdfUtils] 페이지 렌더링 실패 (이미지 데이터가 없습니다)");
        return null;
      }

      debugPrint(
          "[PdfUtils] PDF 페이지 변환 성공! (이미지 크기: ${pdfImage.pixels.length} bytes)");
      ui.Image finalImage = await pdfImage.createImage();

      // //For Test (Start)
      // ByteData? byteData =
      //     await finalImage.toByteData(format: ui.ImageByteFormat.png);
      // if (byteData == null) {
      //   throw Exception("Failed to convert ui.Image to ByteData");
      // }
      // Uint8List pngBytes = byteData.buffer.asUint8List();
      // Get.defaultDialog(title: "renderPDF", content: Container(
      //     decoration: BoxDecoration(
      //       border: Border.all(color: Colors.red, width: 3), // 빨간색 테두리
      //     ),
      //     child: Image.memory(pngBytes)));
      // //Test End

      return finalImage;
    } catch (e, stackTrace) {
      debugPrint("[PdfUtils] PDF 변환 오류: $e\n$stackTrace");
      return null;
    } finally {
      debugPrint("[PdfUtils] 리소스 정리 중...");
      await doc?.dispose();
      debugPrint("[PdfUtils] 리소스 정리 완료.");
    }
  }
}
