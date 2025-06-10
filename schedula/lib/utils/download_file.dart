import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schedula/utils/all_dialouge.dart';
import 'dart:io';

import 'package:schedula/utils/toast_message.dart';

class DownloadFile extends StatefulWidget {
  const DownloadFile({
    super.key,
    required this.downloadURL,
  });
  final String downloadURL;

  @override
  State<DownloadFile> createState() => _DownloadFileState();
}

class _DownloadFileState extends State<DownloadFile> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String? _filePath;

  Future<void> downloadFile(String downloadURL) async {
    // Request storage permission
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      showToastMessageWarning('Storage permission denied');
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    // Show the downloading dialog
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Downloading"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Please wait while the file is downloading..."),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 8),
                Text("${(_progress * 100).toStringAsFixed(0)}%"),
              ],
            ),
          );
        },
      );
    });

    try {
      // Get the Downloads directory
      Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
      if (!downloadsDirectory.existsSync()) {
        downloadsDirectory =
            await getExternalStorageDirectory() ?? downloadsDirectory;
      }

      // Extract the file name and extension from the URL
      String fileName = downloadURL.split('/').last.split('?').first;
      String filePath = '${downloadsDirectory.path}/$fileName';

      // Download the file
      Dio dio = Dio();
      await dio.download(
        downloadURL,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      setState(() {
        _filePath = filePath;
      });

      showToastMessageNormal('File downloaded to $filePath');
    } catch (e) {
      showToastMessageWarning('Failed to download file: $e');
    } finally {
      setState(() {
        _isDownloading = false;
      });
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        downloadFile(widget.downloadURL);
      },
      child: const Text("Download File"),
    );
  }
}
