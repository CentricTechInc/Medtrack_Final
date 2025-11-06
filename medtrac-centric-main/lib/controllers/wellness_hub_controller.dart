import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/api/models/wellness_hub_response.dart';
import 'package:medtrac/api/services/wellness_service.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/services/thumbnail_cache_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:async';

class WellnessHubController extends GetxController {
  final WellnessService _wellnessService = WellnessService();

  RxInt currentTabIndex = 0.obs;
  final TextEditingController searchController = TextEditingController();

  // Pagination
  int articlesPage = 1;
  int videosPage = 1;
  bool hasMoreArticles = true;
  bool hasMoreVideos = true;

  // Loading states
  RxBool isLoadingArticles = false.obs;
  RxBool isLoadingVideos = false.obs;
  RxBool isLoadingMoreArticles = false.obs;
  RxBool isLoadingMoreVideos = false.obs;
  RxBool isArticleDetailLoading = false.obs;
  WellnessHubItem? articleDetailData;

  // Data lists - Direct from API, no filtering
  RxList<WellnessHubItem> wellnessArticles = <WellnessHubItem>[].obs;
  RxList<WellnessHubItem> wellnessVideos = <WellnessHubItem>[].obs;

  // Thumbnail cache service
  final ThumbnailCacheService _thumbnailService =
      ThumbnailCacheService.instance;

  // Separate refresh controllers for each tab
  late RefreshController articlesRefreshController;
  late RefreshController videosRefreshController;

  // Search debounce
  Timer? _searchDebounceTimer;
  String _lastSearchQuery = '';

  @override
  void onInit() {
    super.onInit();

    // Initialize refresh controllers
    articlesRefreshController = RefreshController(initialRefresh: false);
    videosRefreshController = RefreshController(initialRefresh: false);

    // Load initial data for wellness hub
    loadWellnessHub();

    // No Worker debounce, use Timer-based debounce in onSearchChanged
  }

  Future<void> fetchArticleDetailsRx(int id) async {
    isArticleDetailLoading.value = true;
    try {
      final response = await _wellnessService.getWellnessDetails(id: id);
      if (response['status'] == true && response['data'] != null) {
        articleDetailData = WellnessHubItem.fromJson(response['data']);
      } else {
        SnackbarUtils.showError('Failed to load article details');
      }
    } catch (e) {
        SnackbarUtils.showError('Failed to load article details ${e.toString()}');
    } finally {
      isArticleDetailLoading.value = false;
    }
  }

  void loadWellnessHub() {
    loadArticles(isRefresh: true);
    loadVideos(isRefresh: true);
  }

  @override
  void onClose() {
    searchController.dispose();
    articlesRefreshController.dispose();
    videosRefreshController.dispose();
  _searchDebounceTimer?.cancel();
    super.onClose();
  }

  void onTabChanged(int currentTab) {
    currentTabIndex.value = currentTab;

    // Load data for the new tab if it's empty or search has changed
    if (currentTab == 0) {
      // Articles tab
      if (wellnessArticles.isEmpty ||
          _lastSearchQuery != searchController.text) {
        loadArticles(isRefresh: true);
      }
    } else {
      // Videos tab
      if (wellnessVideos.isEmpty || _lastSearchQuery != searchController.text) {
        loadVideos(isRefresh: true);
      }
    }
  }

  void onSearchChanged(String value) {
    searchController.text = value;
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: value.length),
    );
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      performSearch();
    });
  }

  void performSearch() {
    _lastSearchQuery = searchController.text;

    if (currentTabIndex.value == 0) {
      // Reset articles and search
      articlesPage = 1;
      hasMoreArticles = true;
      wellnessArticles.clear();
      loadArticles(isRefresh: true);
    } else {
      // Reset videos and search
      videosPage = 1;
      hasMoreVideos = true;
      wellnessVideos.clear();
      loadVideos(isRefresh: true);
    }
  }

  Future<void> loadArticles({bool isRefresh = false}) async {
    if (isRefresh) {
      articlesPage = 1;
      hasMoreArticles = true;
      isLoadingArticles.value = true;
    } else {
      if (!hasMoreArticles) {
        articlesRefreshController.loadNoData();
        return;
      }
      isLoadingMoreArticles.value = true;
    }

    try {
      final response = await _wellnessService.getWellnessHubListing(
        page: articlesPage,
        type: 'Article',
        search: searchController.text.isEmpty ? null : searchController.text,
      );

      if (response.status && response.data != null) {
        final items = response.data!.rows;
        if (isRefresh) {
          wellnessArticles.assignAll(items);
          articlesRefreshController.refreshCompleted();
        } else {
          wellnessArticles.addAll(items);
          articlesRefreshController.loadComplete();
        }

        // Check if there are more items
        if (items.isEmpty) {
          hasMoreArticles = false;
          articlesRefreshController.loadNoData();
        } else {
          articlesPage++;
        }
      } else {
        // Handle error
        if (response.errors != null && response.errors!.isNotEmpty) {
          SnackbarUtils.showError(response.errors!.first);
        }
        if (isRefresh) {
          articlesRefreshController.refreshFailed();
        } else {
          articlesRefreshController.loadFailed();
        }
      }
    } catch (e) {
      SnackbarUtils.showError('Failed to load articles: ${e.toString()}');
      if (isRefresh) {
        articlesRefreshController.refreshFailed();
      } else {
        articlesRefreshController.loadFailed();
      }
    } finally {
      isLoadingArticles.value = false;
      isLoadingMoreArticles.value = false;
    }
  }

  Future<void> loadVideos({bool isRefresh = false}) async {
    if (isRefresh) {
      videosPage = 1;
      hasMoreVideos = true;
      isLoadingVideos.value = true;
    } else {
      if (!hasMoreVideos) {
        videosRefreshController.loadNoData();
        return;
      }
      isLoadingMoreVideos.value = true;
    }

    try {
      final response = await _wellnessService.getWellnessHubListing(
        page: videosPage,
        type: 'Video',
        search: searchController.text.isEmpty ? null : searchController.text,
      );

      if (response.status && response.data != null) {
        final items = response.data!.rows;

        if (isRefresh) {
          wellnessVideos.assignAll(items);
          videosRefreshController.refreshCompleted();
        } else {
          wellnessVideos.addAll(items);
          videosRefreshController.loadComplete();
        }

        // Check if there are more items
        if (items.isEmpty) {
          hasMoreVideos = false;
          videosRefreshController.loadNoData();
        } else {
          videosPage++;
        }
      } else {
        // Handle error
        if (response.errors != null && response.errors!.isNotEmpty) {
          SnackbarUtils.showError(response.errors!.first);
        }
        if (isRefresh) {
          videosRefreshController.refreshFailed();
        } else {
          videosRefreshController.loadFailed();
        }
      }
    } catch (e) {
      SnackbarUtils.showError('Failed to load videos: ${e.toString()}');
      if (isRefresh) {
        videosRefreshController.refreshFailed();
      } else {
        videosRefreshController.loadFailed();
      }
    } finally {
      isLoadingVideos.value = false;
      isLoadingMoreVideos.value = false;
    }
  }

  void onRefresh() {
    if (currentTabIndex.value == 0) {
      loadArticles(isRefresh: true);
    } else {
      loadVideos(isRefresh: true);
    }
  }

  void onLoading() {
    if (currentTabIndex.value == 0) {
      loadArticles(isRefresh: false);
    } else {
      loadVideos(isRefresh: false);
    }
  }

  void onVideoTapped(WellnessHubItem video) {
    // Navigate to video player
    Get.toNamed(AppRoutes.videoPlayerScreen, arguments: {
      'url': video.assets,
      'title': video.title,
    });
  }

  Future<Map<String, dynamic>?> fetchArticleDetails(int id) async {
    try {
      final response = await _wellnessService.getWellnessDetails(id: id);
      if (response['status'] == true && response['data'] != null) {
        return response['data'];
      }
    } catch (e) {
      // Optionally handle error
    }
    return null;
  }

  // Getter for current list based on tab
  List<WellnessHubItem> get currentList {
    return currentTabIndex.value == 0 ? wellnessArticles : wellnessVideos;
  }

  // Getter for current loading state
  bool get isLoading {
    return currentTabIndex.value == 0
        ? isLoadingArticles.value
        : isLoadingVideos.value;
  }

  // Getter for current refresh controller
  RefreshController get currentRefreshController {
    return currentTabIndex.value == 0
        ? articlesRefreshController
        : videosRefreshController;
  }

  /// Generate thumbnail for video using the improved method
  Future<String?> generateThumbnail(String videoUrl) async {
    return await _thumbnailService.generateAndCacheThumbnail(videoUrl);
  }

  /// Get cached thumbnail or return null
  String? getCachedThumbnail(String videoUrl) {
    return _thumbnailService.getCachedThumbnailPath(videoUrl);
  }

  /// Check if thumbnail is currently being generated
  bool isGeneratingThumbnail(String videoUrl) {
    return _thumbnailService.isGeneratingThumbnail(videoUrl);
  }
}
