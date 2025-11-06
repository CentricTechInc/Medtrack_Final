import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';

class ThumbnailCacheService extends GetxService {
  static ThumbnailCacheService get instance =>
      Get.find<ThumbnailCacheService>();

  late Directory _cacheDir;
  final RxMap<String, bool> _generatingThumbnails = <String, bool>{}.obs;
  final RxMap<String, bool> _failedThumbnails = <String, bool>{}.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeCacheDirectory();
  }

  Future<void> _initializeCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/video_thumbnails');

    if (!await _cacheDir.exists()) {
      await _cacheDir.create(recursive: true);
    }
  }

  /// Generate a unique filename for video URL
  String _getHashedFileName(String videoUrl) {
    final bytes = utf8.encode(videoUrl);
    final digest = sha256.convert(bytes);
    return 'thumbnail_${digest.toString()}.jpg';
  }

  /// Get cached thumbnail file path (returns null if doesn't exist)
  String? getCachedThumbnailPath(String videoUrl) {
    final fileName = _getHashedFileName(videoUrl);
    final file = File('${_cacheDir.path}/$fileName');

    if (file.existsSync()) {
      return file.path;
    }
    return null;
  }

  /// Check if thumbnail is currently being generated
  bool isGeneratingThumbnail(String videoUrl) {
    return _generatingThumbnails[videoUrl] == true;
  }

  /// Check if thumbnail generation previously failed
  bool hasThumbnailFailed(String videoUrl) {
    return _failedThumbnails[videoUrl] == true;
  }

  /// Generate and cache thumbnail
  Future<String?> generateAndCacheThumbnail(String videoUrl) async {
    // Check if already cached
    final existingPath = getCachedThumbnailPath(videoUrl);
    if (existingPath != null) {
      return existingPath;
    }

    // Check if already generating
    if (isGeneratingThumbnail(videoUrl)) {
      return null;
    }

    // Check if previously failed - don't retry failed thumbnails
    if (hasThumbnailFailed(videoUrl)) {
      return null;
    }

    _generatingThumbnails[videoUrl] = true;

    try {
      // Use VideoPlayerController for better handling
      VideoPlayerController? videoController;

      try {
        if (videoUrl.startsWith('http')) {
          videoController =
              VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        } else {
          videoController = VideoPlayerController.file(File(videoUrl));
        }

        await videoController.initialize();
        final videoDuration = videoController.value.duration.inMilliseconds;

        // Generate thumbnail at 10% of video duration or 3 seconds, whichever is less
        final timeMs = (videoDuration * 0.1).clamp(0, 3000).toInt();

        Uint8List? thumbnailBytes = await VideoThumbnail.thumbnailData(
          video: videoUrl,
          imageFormat: ImageFormat.JPEG,
          timeMs: timeMs,
          quality: 75,
        );

        if (thumbnailBytes != null) {
          final fileName = _getHashedFileName(videoUrl);
          final thumbnailFile = File('${_cacheDir.path}/$fileName');
          log("thumbnailFile $thumbnailFile");
          await thumbnailFile.writeAsBytes(thumbnailBytes);
          return thumbnailFile.path;
        }
      } finally {
        videoController?.dispose();
      }
    } catch (e) {
      print('Error generating thumbnail for $videoUrl: $e');
      // Mark this URL as failed to prevent repeated attempts
      _failedThumbnails[videoUrl] = true;
    } finally {
      _generatingThumbnails[videoUrl] = false;
    }

    return null;
  }

  /// Clear all cached thumbnails
  Future<void> clearCache() async {
    try {
      if (await _cacheDir.exists()) {
        await _cacheDir.delete(recursive: true);
        await _cacheDir.create(recursive: true);
      }
    } catch (e) {
      print('Error clearing thumbnail cache: $e');
    }
  }

  /// Clear failed thumbnail attempts (allows retrying)
  void clearFailedAttempts() {
    _failedThumbnails.clear();
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    int totalSize = 0;

    try {
      if (await _cacheDir.exists()) {
        await for (FileSystemEntity entity in _cacheDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      print('Error calculating cache size: $e');
    }

    return totalSize;
  }

  /// Clean old thumbnails (older than 30 days)
  Future<void> cleanOldCache() async {
    try {
      if (await _cacheDir.exists()) {
        final cutoffDate = DateTime.now().subtract(Duration(days: 30));

        await for (FileSystemEntity entity in _cacheDir.list()) {
          if (entity is File) {
            final stat = await entity.stat();
            if (stat.modified.isBefore(cutoffDate)) {
              await entity.delete();
            }
          }
        }
      }
    } catch (e) {
      print('Error cleaning old cache: $e');
    }
  }
}
