import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';

class DownloadResult {
  DownloadResult(this.success, this.message);
  final bool success;
  final String message;
}

class DownloadService {
  final Dio _dio = Dio();

  Future<DownloadResult> downloadAndSave(
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          return DownloadResult(false, 'Permission denied - cannot save to gallery.');
        }
      }

      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      final bytes = Uint8List.fromList(response.data!);
      await Gal.putImageBytes(
        bytes,
        name: 'infinity_gallery_${DateTime.now().millisecondsSinceEpoch}',
      );
      return DownloadResult(true, 'Saved to gallery');
    } on GalException catch (e) {
      return DownloadResult(false, e.type.message);
    } catch (_) {
      return DownloadResult(false, 'Download failed, please try again.');
    }
  }
}
