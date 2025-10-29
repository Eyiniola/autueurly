import 'package:flutter/material.dart';

import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String? description;
  const PdfViewerPage({super.key, required this.pdfUrl, this.description});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  // You might need to download the file first to get a local path
  String? localPath;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Example: Download file (implement download logic)
    // downloadFile(widget.pdfUrl).then((path) {
    //   if (mounted) setState(() { localPath = path; isLoading = false; });
    // }).catchError((e) {
    //   if (mounted) setState(() { errorMessage = e.toString(); isLoading = false; });
    // });
    // For now, let's assume URL works directly if package supports it (check docs)
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.description ?? "Document"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Text(
                "Error loading PDF: $errorMessage",
                style: TextStyle(color: Colors.red),
              ),
            )
          : PDFView(
              filePath:
                  localPath, // Or maybe remote URL works? Check package docs
              // Add PDFView options here
            ),
    );
  }
}
