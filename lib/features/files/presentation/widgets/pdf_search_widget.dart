import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PDFSearchWidget extends StatefulWidget {
  final PdfTextSearcher pdfTextSearcher;
  final PdfViewerController pdfViewerController;

  const PDFSearchWidget({
    Key? key,
    required this.pdfTextSearcher,
    required this.pdfViewerController,
  }) : super(key: key);

  @override
  State<PDFSearchWidget> createState() => _PDFSearchWidgetState();
}

class _PDFSearchWidgetState extends State<PDFSearchWidget> {
  bool _isSearchVisible = false;
  String _searchQuery = '';
  int _searchMatchCount = 0;
  int _currentSearchIndex = -1;


  @override
  void initState() {
    super.initState();
    widget.pdfTextSearcher.addListener(_updateSearch);
  }

  @override
  void dispose() {
    widget.pdfTextSearcher.removeListener(_updateSearch);
    super.dispose();
  }
  void _updateSearch() {
    setState(() {
      _searchMatchCount = widget.pdfTextSearcher.matches.length;
      _currentSearchIndex = widget.pdfTextSearcher.currentIndex ?? -1;
    });
  }
  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchQuery = '';
        widget.pdfTextSearcher.resetTextSearch();
        _searchMatchCount = 0;
        _currentSearchIndex = -1;
      }
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      widget.pdfTextSearcher.resetTextSearch();
      setState(() {
        _searchQuery = '';
        _searchMatchCount = 0;
        _currentSearchIndex = -1;
      });
      return;
    }

    setState(() {
      _searchQuery = query;
    });

    widget.pdfTextSearcher.startTextSearch(
      query,
      caseInsensitive: true,
      goToFirstMatch: true,
    );
  }
  void _navigateSearch(bool forward) async {
    if (_searchMatchCount == 0) return;

    int newIndex = forward
        ? await widget.pdfTextSearcher.goToNextMatch()
        : await widget.pdfTextSearcher.goToPrevMatch();

    if (newIndex != -1) {
      setState(() {
        _currentSearchIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isSearchVisible ? 300 : 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
            ),
            if (_isSearchVisible) ...[
              Expanded(
                child: TextField(
                  onChanged: _performSearch,
                  decoration: const InputDecoration(
                    hintText: 'Enter search query',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              if (_searchMatchCount > 0) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () => _navigateSearch(false),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: () => _navigateSearch(true),
                ),
                Container(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${_currentSearchIndex + 1}/$_searchMatchCount',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}