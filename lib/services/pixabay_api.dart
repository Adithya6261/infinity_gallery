import 'package:dio/dio.dart';

import '../core/constants/api_keys.dart';
import '../models/pixabay_image.dart';

class PixabayApiException implements Exception {
  PixabayApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class PixabayApi {
  PixabayApi({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://pixabay.com/api/',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ));

  final Dio _dio;

  static const int perPage = 24;

  Future<List<PixabayImage>> search({
    required String query,
    required int page,
    String category = '',
  }) async {
    if (pixabayApiKey.isEmpty || pixabayApiKey == 'YOUR_PIXABAY_API_KEY') {
      throw PixabayApiException(
        'Missing Pixabay API key - add yours in lib/core/constants/api_keys.dart',
      );
    }

    try {
      final response = await _dio.get('/', queryParameters: {
        'key': pixabayApiKey,
        'q': query.isEmpty ? 'wallpaper' : query,
        'image_type': 'photo',
        'safesearch': 'true',
        'page': page,
        'per_page': perPage,
        if (category.isNotEmpty) 'category': category,
      });

      final hits = response.data['hits'] as List;
      return hits.map((e) => PixabayImage.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw PixabayApiException('Could not reach the server, check your connection.');
      }
      if (e.response?.statusCode == 429) {
        throw PixabayApiException('Too many requests - wait a bit and try again.');
      }
      if (e.response?.statusCode == 400) {
        throw PixabayApiException('Invalid API key or request.');
      }
      throw PixabayApiException('Failed to load images, please try again.');
    }
  }
}
