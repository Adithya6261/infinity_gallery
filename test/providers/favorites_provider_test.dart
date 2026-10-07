import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_gallery/models/pixabay_image.dart';
import 'package:infinity_gallery/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

PixabayImage _image(int id) => PixabayImage(
      id: id,
      previewUrl: 'preview$id.jpg',
      webUrl: 'web$id.jpg',
      largeImageUrl: 'large$id.jpg',
      tags: 'test',
      user: 'tester',
      userImageUrl: '',
      likes: 0,
      downloads: 0,
      views: 0,
      imageWidth: 100,
      imageHeight: 100,
      pageUrl: '',
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('starts with no favorites', () async {
    final provider = FavoritesProvider();
    await provider.ready;

    expect(provider.favorites, isEmpty);
    expect(provider.isFavorite(1), isFalse);
  });

  test('toggle adds then removes an image', () async {
    final provider = FavoritesProvider();
    await provider.ready;

    final image = _image(1);
    provider.toggle(image);
    expect(provider.isFavorite(1), isTrue);
    expect(provider.favorites, hasLength(1));

    provider.toggle(image);
    expect(provider.isFavorite(1), isFalse);
    expect(provider.favorites, isEmpty);
  });

  test('favorites persist across provider instances', () async {
    final first = FavoritesProvider();
    await first.ready;
    first.toggle(_image(7));

    // give the fire-and-forget save() a tick to finish writing
    await Future<void>.delayed(Duration.zero);

    final second = FavoritesProvider();
    await second.ready;

    expect(second.isFavorite(7), isTrue);
  });
}
