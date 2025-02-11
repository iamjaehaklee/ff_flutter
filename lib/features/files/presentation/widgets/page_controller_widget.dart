import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PageControllerWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PdfViewerController? pdfViewController; // Nullable
  final double arrowSize; // 화살표 크기 조정 가능

  const PageControllerWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    this.pdfViewController, // Nullable
    this.arrowSize = 24.0, // 기본 화살표 크기 설정
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black.withOpacity(0.2), // 배경색 투명도 조정
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 이전 페이지 버튼
            IconButton(
              iconSize: arrowSize, // 화살표 크기 조정
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: pdfViewController != null && currentPage > 0
                  ? () {
                      pdfViewController!.goToPage(pageNumber: currentPage - 1);
                    }
                  : null, // 버튼 비활성화 조건
            ),
            // 현재 페이지 상태
            Text(
              "Page ${currentPage + 1} of $totalPages",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            // 다음 페이지 버튼
            IconButton(
              iconSize: arrowSize, // 화살표 크기 조정
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: pdfViewController != null &&
                      currentPage < totalPages - 1
                  ? () {
                      pdfViewController!.goToPage(pageNumber: currentPage + 1);
                    }
                  : null, // 버튼 비활성화 조건
            ),
          ],
        ),
      ),
    );
  }
}
