import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_lib;
import '../constants/app_colors.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:el_arbol/featuers/placeholders.dart';

class PdfPoint {
  final double dx;
  final double dy;
  PdfPoint(this.dx, this.dy);
}

class DrawingPainter extends CustomPainter {
  final Map<int, List<List<PdfPoint>>> pageStrokes;
  final List<PdfPoint>? currentStroke;
  final int currentPage;

  DrawingPainter({
    required this.pageStrokes,
    required this.currentPage,
    this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    void draw(List<PdfPoint> stroke) {
      if (stroke.isEmpty) return;
      final path = Path();
      path.moveTo(stroke[0].dx * size.width, stroke[0].dy * size.height);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx * size.width, stroke[i].dy * size.height);
      }
      canvas.drawPath(path, paint);
    }

    if (pageStrokes.containsKey(currentPage)) {
      for (var stroke in pageStrokes[currentPage]!) {
        draw(stroke);
      }
    }
    if (currentStroke != null) draw(currentStroke!);
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}

class PdfTenantViewScreen extends StatefulWidget {
  final String? url;
  final Uint8List? pdfBytes;
  final int astId;
  final int propertyId;

  const PdfTenantViewScreen({
    super.key,
    required this.url,
    this.pdfBytes,
    required this.astId,
    required this.propertyId,
  });

  @override
  State<PdfTenantViewScreen> createState() => _PdfTenantViewScreenState();
}

class _PdfTenantViewScreenState extends State<PdfTenantViewScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();

  int currentPage = 1;
  bool isEditMode = false;
  final Map<int, Size> _pageSizesPoints = {};
  Map<int, List<List<PdfPoint>>> pageStrokes = {};
  List<PdfPoint> _currentStroke = [];

  Uint8List? _pdfBytes;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    if (widget.pdfBytes != null) {
      _pdfBytes = widget.pdfBytes;
      _processPdfBytes(_pdfBytes!);
    } else if (widget.url != null && widget.url!.isNotEmpty) {
      _downloadPdf(widget.url!);
    }
  }

  Future<void> _downloadPdf(String url) async {
    try {
      setState(() => _isDownloading = true);
      final response = await dio_lib.Dio().get(
        url,
        options: dio_lib.Options(responseType: dio_lib.ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        final bytes = Uint8List.fromList(response.data);
        _processPdfBytes(bytes);
        if (mounted) {
          setState(() {
            _pdfBytes = bytes;
            _isDownloading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        debugPrint("Download error: $e");
        Get.snackbar("Error", "Failed to load PDF for signing");
      }
    }
  }

  void _processPdfBytes(Uint8List bytes) {
    try {
      final document = PdfDocument(inputBytes: bytes);
      for (int i = 0; i < document.pages.count; i++) {
        _pageSizesPoints[i + 1] = document.pages[i].size;
      }
      document.dispose();
    } catch (e) {
      debugPrint("Error processing PDF: $e");
    }
  }

  Rect _getActualPdfPageRect() {
    if (_pdfViewerKey.currentContext == null ||
        !_pageSizesPoints.containsKey(currentPage)) {
      return Rect.zero;
    }
    final RenderBox box =
        _pdfViewerKey.currentContext!.findRenderObject() as RenderBox;
    final Size viewSize = box.size;
    final Size pageSize = _pageSizesPoints[currentPage]!;

    double pdfAR = pageSize.width / pageSize.height;
    double viewAR = viewSize.width / viewSize.height;

    double renderedW, renderedH, offsetX, offsetY;
    if (viewAR > pdfAR) {
      renderedH = viewSize.height;
      renderedW = renderedH * pdfAR;
      offsetX = (viewSize.width - renderedW) / 2;
      offsetY = 0;
    } else {
      renderedW = viewSize.width;
      renderedH = renderedW / pdfAR;
      offsetX = 0;
      offsetY = (viewSize.height - renderedH) / 2;
    }
    return Rect.fromLTWH(offsetX, offsetY, renderedW, renderedH);
  }

  Future<String?> _exportPdf() async {
    try {
      if (pageStrokes.isEmpty || _pdfBytes == null) return null;

      final document = PdfDocument(inputBytes: _pdfBytes!);

      for (var pageNum in pageStrokes.keys) {
        final strokes = pageStrokes[pageNum];
        if (strokes == null || strokes.isEmpty) continue;

        final page = document.pages[pageNum - 1];
        final pageSize = page.size;

        for (final stroke in strokes) {
          if (stroke.length < 2) continue;

          for (int j = 0; j < stroke.length - 1; j++) {
            page.graphics.drawLine(
              PdfPen(PdfColor(0, 0, 0), width: 2.5),
              Offset(
                stroke[j].dx * pageSize.width,
                stroke[j].dy * pageSize.height,
              ),
              Offset(
                stroke[j + 1].dx * pageSize.width,
                stroke[j + 1].dy * pageSize.height,
              ),
            );
          }
        }
      }

      final bytes = await document.save();
      final dir = await getApplicationDocumentsDirectory();

      final file = File(
        "${dir.path}/signed_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );

      await file.writeAsBytes(bytes);
      document.dispose();

      return file.path;
    } catch (e) {
      debugPrint("Export Error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_pdfBytes == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(
          child: Text("Unable to load PDF. Please try again."),
        ),
      );
    }

    final Rect pageRect = _getActualPdfPageRect();

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: AppColors.c337FDD,
        title: const Text("Document Editor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () =>
                setState(() => pageStrokes[currentPage]?.removeLast()),
          ),
          TextButton(
            onPressed: () async {
              EasyLoading.show(status: "Generating PDF...");
              final filePath = await _exportPdf();
              EasyLoading.dismiss();

              if (filePath != null) {
                final file = File(filePath);
                if (await file.exists()) {
                  Get.to(
                    () => MyAppsScreen(
                      pdfPath: filePath,
                      astId: widget.astId,
                      propertyId: widget.propertyId,
                    ),
                  );
                } else {
                  Get.snackbar("Error", "Exported file not found");
                }
              } else {
                Get.snackbar("Error", "Failed to generate signed document");
              }
            },
            child: const Text(
              "SAVE",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  "Page $currentPage",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => setState(() {
                    isEditMode = !isEditMode;
                    if (isEditMode) _pdfController.zoomLevel = 1.0;
                  }),
                  icon: Icon(isEditMode ? Icons.check : Icons.edit),
                  label: Text(isEditMode ? "Done" : "Draw Signature"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEditMode
                        ? Colors.green
                        : AppColors.c337FDD,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                SfPdfViewer.memory(
                  _pdfBytes!,
                  key: _pdfViewerKey,
                  controller: _pdfController,
                  pageSpacing: 0,
                  pageLayoutMode: isEditMode
                      ? PdfPageLayoutMode.single
                      : PdfPageLayoutMode.continuous,
                  enableDoubleTapZooming: !isEditMode,
                  onPageChanged: (details) =>
                      setState(() => currentPage = details.newPageNumber),
                ),
                if (isEditMode && pageRect != Rect.zero)
                  Positioned.fromRect(
                    rect: pageRect,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) => setState(
                        () => _currentStroke = [
                          PdfPoint(
                            details.localPosition.dx / pageRect.width,
                            details.localPosition.dy / pageRect.height,
                          ),
                        ],
                      ),
                      onPanUpdate: (details) => setState(
                        () => _currentStroke.add(
                          PdfPoint(
                            details.localPosition.dx / pageRect.width,
                            details.localPosition.dy / pageRect.height,
                          ),
                        ),
                      ),
                      onPanEnd: (_) => setState(() {
                        pageStrokes
                            .putIfAbsent(currentPage, () => [])
                            .add(List.from(_currentStroke));
                        _currentStroke.clear();
                      }),
                      child: CustomPaint(
                        painter: DrawingPainter(
                          pageStrokes: pageStrokes,
                          currentPage: currentPage,
                          currentStroke: _currentStroke,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
