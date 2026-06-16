import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveFileBytes(List<int> bytes, String fileName, {String? shareText}) async {
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/$fileName');
  await tempFile.writeAsBytes(bytes);
  await Share.shareXFiles([XFile(tempFile.path)], text: shareText ?? fileName);
}

Future<void> saveFileString(String content, String fileName, {String? shareText}) async {
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/$fileName');
  await tempFile.writeAsString(content, encoding: utf8);
  await Share.shareXFiles([XFile(tempFile.path)], text: shareText ?? fileName);
}
