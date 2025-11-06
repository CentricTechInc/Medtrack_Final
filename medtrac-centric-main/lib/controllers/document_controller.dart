import 'dart:io';
import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:medtrac/models/document_model.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/constants.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentController extends GetxController {

  final RxList<Document> documents = <Document>[].obs;

  void addDocument(Document document) {
    documents.add(document);
  }

  void removeDocument(Document document) {
    documents.remove(document);
  }

  List<Document> get allSharedDocument => dummyDocuments.where((doc) => doc.isShared).toList();
  List<Document> get allPerscriptionDocument => dummyDocuments.where((doc) => !doc.isShared).toList();


 final _flutterMediaDownloaderPlugin = MediaDownload();


  void downloadPrescriptionReport() async {
    const String title = "Prescription Report";
    const String description = "Downloading your prescription report...";

    try {
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

      await _flutterMediaDownloaderPlugin.downloadFile(
        "file://$filePath",
        title,
        description,
        filePath,
      );

    } catch (e) {
      print("Error downloading prescription report: $e");
    }
  }
  
}