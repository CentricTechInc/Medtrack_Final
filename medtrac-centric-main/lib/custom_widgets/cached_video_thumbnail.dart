import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/services/thumbnail_cache_service.dart';
import 'dart:io';

class CachedVideoThumbnail extends StatelessWidget {
  final String videoUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const CachedVideoThumbnail({
    super.key,
    required this.videoUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailService = ThumbnailCacheService.instance;

    return Obx(() {
      // Check if we have a cached thumbnail
      final cachedPath = thumbnailService.getCachedThumbnailPath(videoUrl);
      final isGenerating = thumbnailService.isGeneratingThumbnail(videoUrl);

      if (cachedPath != null) {
        // Show cached thumbnail using CachedNetworkImage for consistency
        return _buildImage(
          child: Image.file(
            File(cachedPath),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return errorWidget ??
                  Container(
                    width: width,
                    height: height,
                    color: Colors.grey[300],
                    child: Icon(Icons.error),
                  );
            },
          ),
        );
      } else if (isGenerating) {
        // Show loading indicator while generating
        return _buildImage(
          child: placeholder ??
              Container(
                width: width,
                height: height,
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
        );
      } else {
        // Start generating thumbnail and show placeholder
        // Use Future.microtask to avoid setState during build
        Future.microtask(
            () => thumbnailService.generateAndCacheThumbnail(videoUrl));

        // Try to show the video URL as an image (in case it's an image URL)
        if (videoUrl.startsWith('http')) {
          return _buildImage(
            child: Image.network(
              videoUrl,
              width: width,
              height: height,
              fit: fit,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return placeholder ??
                    Container(
                      width: width,
                      height: height,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
              },
              errorBuilder: (context, error, stackTrace) {
                // If image loading fails, show the placeholder while thumbnail generates
                return placeholder ??
                    Container(
                      width: width,
                      height: height,
                      color: Colors.grey[300],
                      child: Icon(Icons.video_library),
                    );
              },
            ),
          );
        } else {
          return _buildImage(
            child: placeholder ??
                Container(
                  width: width,
                  height: height,
                  color: Colors.grey[300],
                  child: Icon(Icons.video_library),
                ),
          );
        }
      }
    });
  }

  Widget _buildImage({required Widget child}) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }
}
