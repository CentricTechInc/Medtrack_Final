import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:get/get.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PatientPerscriptionReportController extends GetxController {
  final _flutterMediaDownloaderPlugin = MediaDownload();

  /// Downloads the local prescription report file
  void downloadPrescriptionReport() async {
    const String title = "Prescription Report";
    const String description = "Downloading your prescription report...";

    try {
      // Request storage permission (Android)
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          print('Storage permission denied');
          return;
        }
      }

      // Load the local asset file
      final ByteData byteData =
          await rootBundle.load(Assets.dummyFilePath);

      // Get the Downloads directory
      Directory downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      // Create a file in Downloads folder
      final String filePath = "${downloadsDir.path}/$title.pdf";
      final File file = File(filePath);

      // Write file
      await file.writeAsBytes(byteData.buffer.asUint8List());

      print('File saved to $filePath');

      // Simulate “download” with plugin notification (optional)
      await _flutterMediaDownloaderPlugin.downloadFile(
        "file://$filePath", // local file URI
        title,
        description,
        filePath,
      );

    } catch (e) {
      print("Error downloading prescription report: $e");
    }
  }
}
