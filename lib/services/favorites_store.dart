import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pixabay_image.dart';

// Simple shared_preferences backed store - favorites list is small enough
// that a sqlite table felt like overkill for this.
class FavoritesStore {
  static const _prefsKey = 'favorite_images';

  Future<List<PixabayImage>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? const [];
    return raw
        .map((s) => PixabayImage.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<PixabayImage> images) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = images.map((img) => jsonEncode(img.toJson())).toList();
    await prefs.setStringList(_prefsKey, raw);
  }
}
