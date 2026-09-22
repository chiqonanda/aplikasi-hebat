import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> openPdfPreview(List<int> bytes) async {
  final dir = await getTemporaryDirectory();
  final f = File('${dir.path}/preview_laporan.pdf');
  await f.writeAsBytes(bytes);
  await Share.shareXFiles(
    [XFile(f.path, mimeType: 'application/pdf')],
    text: 'Preview Laporan PDF',
  );
}
