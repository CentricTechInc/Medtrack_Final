import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    Key? key,
    required this.pdfUrl,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _buildPdfViewer(),
    );
  }

  Widget _buildPdfViewer() {
    if (pdfUrl.startsWith('http://') || pdfUrl.startsWith('https://')) {
      // Network PDF
      return SfPdfViewer.network(
        pdfUrl,
        canShowScrollStatus: true,
        canShowPaginationDialog: true,
      );
    } else {
      // Asset PDF
      return SfPdfViewer.asset(
        pdfUrl,
        canShowScrollStatus: true,
        canShowPaginationDialog: true,
      );
    }
  }
}
