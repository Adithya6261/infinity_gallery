import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_gallery/models/pixabay_image.dart';

void main() {
  final sampleJson = {
    'id': 195893,
    'previewURL': 'https://cdn.pixabay.com/preview.jpg',
    'webformatURL': 'https://cdn.pixabay.com/web.jpg',
    'largeImageURL': 'https://cdn.pixabay.com/large.jpg',
    'tags': 'blossom, bloom, flower',
    'user': 'Josch13',
    'userImageURL': 'https://cdn.pixabay.com/user.jpg',
    'likes': 90,
    'downloads': 12000,
    'views': 300000,
    'imageWidth': 4000,
    'imageHeight': 3000,
    'pageURL': 'https://pixabay.com/photos/flower-195893/',
  };

  test('parses a full pixabay hit correctly', () {
    final image = PixabayImage.fromJson(sampleJson);

    expect(image.id, 195893);
    expect(image.user, 'Josch13');
    expect(image.tags, 'blossom, bloom, flower');
    expect(image.likes, 90);
    expect(image.imageWidth, 4000);
    expect(image.imageHeight, 3000);
  });

  test('falls back to webformatURL when largeImageURL is missing', () {
    final json = Map<String, dynamic>.from(sampleJson)..remove('largeImageURL');
    final image = PixabayImage.fromJson(json);

    expect(image.largeImageUrl, sampleJson['webformatURL']);
  });

  test('round-trips through toJson/fromJson without losing data', () {
    final image = PixabayImage.fromJson(sampleJson);
    final roundTripped = PixabayImage.fromJson(image.toJson());

    expect(roundTripped.id, image.id);
    expect(roundTripped.tags, image.tags);
    expect(roundTripped.largeImageUrl, image.largeImageUrl);
  });

  test('missing optional fields fall back to sane defaults', () {
    final image = PixabayImage.fromJson({'id': 1});

    expect(image.tags, '');
    expect(image.user, 'unknown');
    expect(image.likes, 0);
  });
}
