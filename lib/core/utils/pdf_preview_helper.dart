import 'pdf_preview_stub.dart'
    if (dart.library.html) 'pdf_preview_web.dart';

/// Buka byte PDF sebagai preview:
/// - Web: blob URL → tab browser baru.
/// - Mobile/desktop: share sheet dengan file PDF.
class PdfPreviewHelper {
  static Future<void> open(List<int> bytes) async {
    await openPdfPreview(bytes);
  }
}
