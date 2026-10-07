import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../widgets/image_tile.dart';
import '../widgets/state_views.dart';
import 'image_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Consumer<FavoritesProvider>(
        builder: (context, favorites, _) {
          if (favorites.favorites.isEmpty) {
            return const EmptyView(
              message: 'No favorites yet.\nTap the heart icon on any image to save it here.',
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: favorites.favorites.length,
            itemBuilder: (context, index) {
              final image = favorites.favorites[index];
              return ImageTile(
                image: image,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ImageDetailScreen(image: image)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
