import 'package:flutter/foundation.dart';

import '../models/pixabay_image.dart';
import '../services/favorites_store.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider({FavoritesStore? store}) : _store = store ?? FavoritesStore() {
    _ready = _loadFromDisk();
  }

  final FavoritesStore _store;
  final Map<int, PixabayImage> _favorites = {};
  late final Future<void> _ready;

  // lets tests (and anything else) wait for the initial disk read
  Future<void> get ready => _ready;

  List<PixabayImage> get favorites => _favorites.values.toList();

  bool isFavorite(int id) => _favorites.containsKey(id);

  Future<void> _loadFromDisk() async {
    final saved = await _store.load();
    for (final img in saved) {
      _favorites[img.id] = img;
    }
    notifyListeners();
  }

  void toggle(PixabayImage image) {
    if (_favorites.containsKey(image.id)) {
      _favorites.remove(image.id);
    } else {
      _favorites[image.id] = image;
    }
    notifyListeners();
    _store.save(_favorites.values.toList());
  }
}
