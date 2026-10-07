class PixabayImage {
  final int id;
  final String previewUrl;
  final String webUrl;
  final String largeImageUrl;
  final String tags;
  final String user;
  final String userImageUrl;
  final int likes;
  final int downloads;
  final int views;
  final int imageWidth;
  final int imageHeight;
  final String pageUrl;

  PixabayImage({
    required this.id,
    required this.previewUrl,
    required this.webUrl,
    required this.largeImageUrl,
    required this.tags,
    required this.user,
    required this.userImageUrl,
    required this.likes,
    required this.downloads,
    required this.views,
    required this.imageWidth,
    required this.imageHeight,
    required this.pageUrl,
  });

  factory PixabayImage.fromJson(Map<String, dynamic> json) {
    return PixabayImage(
      id: json['id'] as int,
      previewUrl: json['previewURL'] as String? ?? '',
      webUrl: json['webformatURL'] as String? ?? '',
      largeImageUrl: json['largeImageURL'] as String? ?? json['webformatURL'] as String? ?? '',
      tags: json['tags'] as String? ?? '',
      user: json['user'] as String? ?? 'unknown',
      userImageUrl: json['userImageURL'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      imageWidth: json['imageWidth'] as int? ?? 0,
      imageHeight: json['imageHeight'] as int? ?? 0,
      pageUrl: json['pageURL'] as String? ?? '',
    );
  }

  // mirrors the pixabay response shape so this doubles as our favorites
  // storage format too - one less thing to keep in sync
  Map<String, dynamic> toJson() => {
        'id': id,
        'previewURL': previewUrl,
        'webformatURL': webUrl,
        'largeImageURL': largeImageUrl,
        'tags': tags,
        'user': user,
        'userImageURL': userImageUrl,
        'likes': likes,
        'downloads': downloads,
        'views': views,
        'imageWidth': imageWidth,
        'imageHeight': imageHeight,
        'pageURL': pageUrl,
      };
}
