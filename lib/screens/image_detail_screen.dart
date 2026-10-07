import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/pixabay_image.dart';
import '../providers/favorites_provider.dart';
import '../services/download_service.dart';

class ImageDetailScreen extends StatefulWidget {
  const ImageDetailScreen({super.key, required this.image});

  final PixabayImage image;

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  final _downloadService = DownloadService();
  bool _downloading = false;
  double _progress = 0;

  Future<void> _download() async {
    setState(() {
      _downloading = true;
      _progress = 0;
    });

    final result = await _downloadService.downloadAndSave(
      widget.image.largeImageUrl,
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
    );

    if (!mounted) return;
    setState(() => _downloading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.image;
    final tags = image.tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favorites, _) {
              final isFav = favorites.isFavorite(image.id);
              return IconButton(
                tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                onPressed: () => favorites.toggle(image),
              );
            },
          ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(
              image.pageUrl.isNotEmpty ? image.pageUrl : image.largeImageUrl,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'image_${image.id}',
              child: CachedNetworkImage(
                imageUrl: image.largeImageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => AspectRatio(
                  aspectRatio: 1,
                  child: Container(color: Colors.grey.shade300),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            image.userImageUrl.isNotEmpty ? NetworkImage(image.userImageUrl) : null,
                        child: image.userImageUrl.isEmpty ? const Icon(Icons.person) : null,
                      ),
                      const SizedBox(width: 10),
                      Text(image.user, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tags.isEmpty ? 'No description provided for this image.' : tags.join(', '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      _Stat(icon: Icons.favorite_border, value: '${image.likes}'),
                      _Stat(icon: Icons.download_outlined, value: '${image.downloads}'),
                      _Stat(icon: Icons.visibility_outlined, value: '${image.views}'),
                      _Stat(
                        icon: Icons.photo_size_select_actual_outlined,
                        value: '${image.imageWidth}x${image.imageHeight}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _downloading ? null : _download,
                      icon: _downloading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: _progress > 0 ? _progress : null,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download),
                      label: Text(
                        _downloading
                            ? 'Downloading ${(_progress * 100).toStringAsFixed(0)}%'
                            : 'Download',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(value),
      ],
    );
  }
}
