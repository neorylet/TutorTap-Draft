import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/utils/module_file_icon.dart';
import '../models/module_file.dart';
import 'screen_scaffold.dart';

class DocumentViewScreen extends StatefulWidget {
  const DocumentViewScreen({super.key, required this.file});

  final ModuleFile file;

  @override
  State<DocumentViewScreen> createState() => _DocumentViewScreenState();
}

class _DocumentViewScreenState extends State<DocumentViewScreen> {
  PdfController? _controller;
  String? _error;
  bool _loading = true;

  bool get _isPdf => widget.file.type.toLowerCase() == 'pdf';

  @override
  void initState() {
    super.initState();
    if (_isPdf) {
      _loadPdf();
    } else {
      _loading = false;
    }
  }

  Future<void> _loadPdf() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final http.Response response =
          await http.get(Uri.parse(widget.file.url));
      if (response.statusCode != 200) {
        throw Exception(
          'Could not download the file (HTTP ${response.statusCode}). '
          'If this is 401/403, enable "Allow delivery of PDF and ZIP '
          'files" in Cloudinary Settings > Security.',
        );
      }
      final Uint8List bytes = response.bodyBytes;
      setState(() {
        _controller = PdfController(
          document: PdfDocument.openData(Future<Uint8List>.value(bytes)),
        );
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: widget.file.name,
      showBack: true,
      body: _isPdf ? _buildPdf(context) : _buildUnsupported(context),
    );
  }

  Widget _buildPdf(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _buildError(context, _error!);
    }
    final PdfController controller = _controller!;
    return Column(
      children: <Widget>[
        Expanded(
          child: PdfView(
            controller: controller,
            onDocumentError: (Object error) {
              if (mounted) setState(() => _error = error.toString());
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => controller.previousPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: controller.pageListenable,
                    builder: (BuildContext context, int page, Widget? child) {
                      return Text(
                        'Page $page',
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => controller.nextPage(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'Open in browser',
                  onPressed: () => _openExternal(widget.file.url),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnsupported(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(iconForModuleFile(widget.file.type), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.file.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.file.type.toUpperCase()} files cannot be '
                  'rendered inside the app. Open it in the browser to '
                  'read it.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _openExternal(
                    _officeViewerUrl(widget.file.url),
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Open in browser'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _openExternal(widget.file.url),
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Download file'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadPdf,
              child: const Text('Retry'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _openExternal(widget.file.url),
              child: const Text('Open in browser instead'),
            ),
          ],
        ),
      ),
    );
  }

  String _officeViewerUrl(String url) {
    return 'https://view.officeapps.live.com/op/view.aspx?src='
        '${Uri.encodeComponent(url)}';
  }

  Future<void> _openExternal(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
