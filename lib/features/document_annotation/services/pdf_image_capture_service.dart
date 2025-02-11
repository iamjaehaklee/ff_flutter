// File: lib/services/pdf_image_capture_service.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:legalfactfinder2025/features/files/pdf_constants.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfCaptureResult {
  final Uint8List image;
  final ui.Size size;
  PdfCaptureResult({required this.image, required this.size});
}

class PdfImageCaptureService {
  // 🟠 captureCurrentPageImage(): PdfDocument의 특정 페이지를 렌더링하여 PNG 이미지와 원본 크기를 반환
  static Future<PdfCaptureResult?> captureCurrentPageImage(String filePath, int currentPage) async {
    try {
      final doc = await PdfDocument.openFile(filePath);
      // currentPage는 1-based
      final page = doc.pages[currentPage - 1];
      double scale = kPdfRenderScale;
      final pdfImage = await page.render(
        fullWidth: page.width * scale,
        fullHeight: page.height * scale,
        backgroundColor: kPdfBackgroundColor,
        annotationRenderingMode: PdfAnnotationRenderingMode.annotationAndForms,
      );
      if (pdfImage == null) {
        return null;
      }
      final ui.Image renderedImage = await pdfImage.createImage();
      final ui.Size imageSize = ui.Size(renderedImage.width.toDouble(), renderedImage.height.toDouble());
      final ByteData? pngData = await renderedImage.toByteData(format: ui.ImageByteFormat.png);
      if (pngData == null) {
        return null;
      }
      pdfImage.dispose();
      await doc.dispose();
      return PdfCaptureResult(image: pngData.buffer.asUint8List(), size: imageSize);
    } catch (e) {
      return null;
    }
  } // End of captureCurrentPageImage() 🟠
}
