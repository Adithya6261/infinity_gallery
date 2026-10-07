import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/pixabay_image.dart';

class ImageTile extends StatelessWidget {
  const ImageTile({super.key, required this.image, required this.onTap});

  final PixabayImage image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final aspectRatio =
        image.imageWidth > 0 && image.imageHeight > 0 ? image.imageWidth / image.imageHeight : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'image_${image.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: CachedNetworkImage(
              imageUrl: image.webUrl,
              fit: BoxFit.cover,
              memCacheWidth: 400, // grid thumbnails don't need full res in memory
              placeholder: (context, url) => Container(color: Colors.grey.shade300),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
