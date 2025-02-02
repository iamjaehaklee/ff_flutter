import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:path_provider/path_provider.dart';

Future<List<ui.Rect>> detectParagraphs(ui.Image image) async {
  try {



    // ✅ OpenCV로 이미지 로드
    debugPrint("[DEBUG] OpenCV에서 이미지 불러오기 시도...");
    cv.Mat? matImage = await convertUiImageToMat(image);

    if(matImage==null){
      debugPrint("matImage is null!");
      return [];
    }

    debugPrint("[cv.Mat] 불러온 이미지 정보 - channels: ${matImage.channels}, rows: ${matImage.rows}, cols: ${matImage.cols}");

    // ✅ 디코딩된 이미지가 비어있는지 확인
    if (matImage.rows == 0 || matImage.cols == 0) {
      debugPrint("[ERROR] 디코딩된 이미지가 비어 있습니다.");
      return [];
    }

    // ✅ Grayscale 변환
    debugPrint("[DEBUG] Grayscale 변환 중...");
    cv.Mat gray = await cv.cvtColor(matImage, cv.COLOR_BGR2GRAY);

    // ✅ 블러 추가 (노이즈 제거 및 병합)
    debugPrint("[DEBUG] Gaussian Blur 적용 중...");
    cv.Mat blurred = await cv.blur(gray, (1, 1));

// ✅ 강한 이진화 적용 (문단을 강조)
    debugPrint("[DEBUG] Otsu Thresholding 적용 중...");
    cv.Mat binary = await cv.threshold(
        blurred,
        0,
        255,
        cv.THRESH_BINARY_INV + cv.THRESH_OTSU
    ).$2;


// ✅ 형태학적 변환 (문단 블록을 강조)
    debugPrint("[DEBUG] Morphology Transform 적용 중...");
    cv.Mat kernel = await cv.getStructuringElement(cv.MORPH_RECT, (5, 5));
    cv.Mat morphed = await cv.morphologyEx(binary, cv.MORPH_CLOSE, kernel);

    // ✅ 외곽선 검출
    debugPrint("[DEBUG] 외곽선 검출 중...");
    final result = await cv.findContours(morphed, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);
    cv.Contours contours = result.$1;
    debugPrint("[DEBUG] 검출된 외곽선 개수: ${contours.length}");

    // ✅ 바운딩 박스 생성
    List<ui.Rect> detectedRects = [];

    // 컨투어 필터링: 너무 크거나 작은 박스 제거

    for (int i = 0; i < contours.length; i++) {
      cv.VecPoint contour = contours[i];
      cv.Rect boundingBox = await cv.boundingRect(contour);

      if (boundingBox.height > 20 && boundingBox.height < (gray.rows * 0.9)) {
        detectedRects.add(ui.Rect.fromLTWH(
          boundingBox.x.toDouble(),
          boundingBox.y.toDouble(),
          boundingBox.width.toDouble(),
          boundingBox.height.toDouble(),
        ));
      }
    }



    debugPrint("[DEBUG] 검출된 문단 영역 개수: ${detectedRects.length}");
    return detectedRects;
  } catch (e, stackTrace) {
    debugPrint("[ERROR] OpenCV Paragraph Detection 실패: $e");
    debugPrint("[STACKTRACE] $stackTrace");
    return [];
  }


}


Future<cv.Mat?> convertUiImageToMat(ui.Image image) async {
  try {
    debugPrint("[DEBUG] ui.Image → ByteData 변환 중...");



    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      debugPrint("[ERROR] ByteData 변환 실패");
      return null;
    }

    Uint8List pngBytes = byteData.buffer.asUint8List();
    debugPrint("[DEBUG] ByteData → Uint8List 변환 완료. 크기: ${pngBytes.length}");

    // Get.defaultDialog(title: "detectParagraphs", content :Image.memory(pngBytes) );

    // ✅ OpenCV에서 imdecode를 사용해 Mat 변환
    debugPrint("[DEBUG] OpenCV imdecode 실행 중...");
    cv.Mat mat = await cv.imdecode(pngBytes, cv.IMREAD_UNCHANGED);

    debugPrint("[DEBUG] ui.Image → cv.Mat 변환 성공 - 크기: ${mat.rows}x${mat.cols}, 채널: ${mat.channels}");
    return mat;
  } catch (e) {
    debugPrint("[ERROR] ui.Image → cv.Mat 변환 실패: $e");
    return null;
  }
}
