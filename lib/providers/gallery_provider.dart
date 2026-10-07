import 'package:flutter/foundation.dart';

import '../models/pixabay_image.dart';
import '../services/pixabay_api.dart';

enum GalleryStatus { initial, loading, loadingMore, loaded, error }

class GalleryProvider extends ChangeNotifier {
  GalleryProvider({PixabayApi? api, bool autoLoad = true}) : _api = api ?? PixabayApi() {
    if (autoLoad) {
      loadFirstPage();
    }
  }

  final PixabayApi _api;
  final List<PixabayImage> _images = [];

  GalleryStatus status = GalleryStatus.initial;
  String? errorMessage;

  String _query = '';
  String _category = '';
  int _page = 1;
  bool _hasMore = true;

  List<PixabayImage> get images => _images;
  bool get hasMore => _hasMore;
  String get currentQuery => _query;

  Future<void> loadFirstPage() async {
    status = GalleryStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      _page = 1;
      final results = await _api.search(query: _query, page: _page, category: _category);
      _images
        ..clear()
        ..addAll(results);
      _hasMore = results.length == PixabayApi.perPage;
      status = GalleryStatus.loaded;
    } catch (e) {
      status = GalleryStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (status == GalleryStatus.loadingMore || !_hasMore) return;
    if (status != GalleryStatus.loaded) return;

    status = GalleryStatus.loadingMore;
    notifyListeners();

    try {
      final nextPage = _page + 1;
      final results = await _api.search(query: _query, page: nextPage, category: _category);
      _page = nextPage;
      _images.addAll(results);
      _hasMore = results.length == PixabayApi.perPage;
      status = GalleryStatus.loaded;
    } catch (_) {
      // already have images on screen, just stop trying to paginate further
      status = GalleryStatus.loaded;
      _hasMore = false;
    }
    notifyListeners();
  }

  Future<void> search(String query) async {
    _query = query.trim();
    await loadFirstPage();
  }

  Future<void> setCategory(String category) async {
    _category = category;
    await loadFirstPage();
  }
}
