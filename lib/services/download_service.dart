import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  static Future<bool> downloadMeme(String url, String title) async {
    try {
      // Permission check
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          return false;
        }
      }

      // Get directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create MemeSwipe folder
      final savePath = '${directory!.path}/MemeSwipe';
      await Directory(savePath).create(recursive: true);

      // File name
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$savePath/$fileName';

      // Download
      await Dio().download(url, filePath);

      print('Meme saved: $filePath');
      return true;
    } catch (e) {
      print('Download error: $e');
      return false;
    }
  }
}
