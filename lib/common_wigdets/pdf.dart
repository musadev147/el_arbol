import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:open_file/open_file.dart';

import '../constants/app_colors.dart';

class PdfAllDocViewScreen extends StatefulWidget {
  final String url;

  const PdfAllDocViewScreen({super.key, required this.url});

  @override
  State<PdfAllDocViewScreen> createState() => _PdfAllDocViewScreenState();
}

class _PdfAllDocViewScreenState extends State<PdfAllDocViewScreen> {
  bool isLoading = true;
  bool isDownloading = false;

  Future<void> downloadPdf() async {
    try {
      setState(() => isDownloading = true);

      final dir = await getApplicationDocumentsDirectory();

      final filePath =
          "${dir.path}/AST_${DateTime.now().millisecondsSinceEpoch}.pdf";

      final response = await Dio().get(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
      );

      final file = File(filePath);
      await file.writeAsBytes(response.data);

      setState(() => isDownloading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF Downloaded Successfully")),
      );

      await OpenFile.open(filePath);
    } catch (e) {
      setState(() => isDownloading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.c337FDD,
        title: const Text(
          "Document",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          isDownloading
              ? const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          )
              : IconButton(
            icon: const Icon(Icons.download),
            onPressed: downloadPdf,
          ),
        ],
      ),

      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.url,

            onDocumentLoaded: (details) {
              setState(() => isLoading = false);
            },

            onDocumentLoadFailed: (details) {
              setState(() => isLoading = false);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Failed to load PDF"),
                ),
              );
            },
          ),

          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}