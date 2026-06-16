import 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart';

class FileSaverHelper {
  static Future<void> saveBytes(List<int> bytes, String fileName, {String? shareText}) async {
    await saveFileBytes(bytes, fileName, shareText: shareText);
  }

  static Future<void> saveString(String content, String fileName, {String? shareText}) async {
    await saveFileString(content, fileName, shareText: shareText);
  }
}
