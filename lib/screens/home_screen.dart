import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../providers/gallery_provider.dart';
import '../widgets/image_tile.dart';
import '../widgets/state_views.dart';
import 'favorites_screen.dart';
import 'image_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  // not every pixabay category, just the ones that return decent results
  static const _categories = [
    '',
    'nature',
    'animals',
    'food',
    'travel',
    'people',
    'sports',
    'computer',
    'fashion',
  ];
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final nearBottom =
        _scrollController.position.pixels > _scrollController.position.maxScrollExtent - 400;
    if (nearBottom) {
      context.read<GalleryProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinity Gallery'),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search images...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<GalleryProvider>().search('');
                          setState(() {});
                        },
                      ),
              ),
              onSubmitted: (value) => context.read<GalleryProvider>().search(value),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = category == _selectedCategory;
                // ChoiceChip's selected state (checkmark) renders a bit
                // shorter than unselected chips, and ListView top-aligns
                // items by default - force every chip into the same slot
                // height and center it so the row doesn't look jagged.
                return SizedBox(
                  height: 44,
                  child: Center(
                    child: ChoiceChip(
                      label: Text(category.isEmpty ? 'All' : category),
                      selected: selected,
                      showCheckmark: false,
                      onSelected: (_) {
                        setState(() => _selectedCategory = category);
                        context.read<GalleryProvider>().setCategory(category);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<GalleryProvider>(
              builder: (context, gallery, _) {
                if (gallery.status == GalleryStatus.loading) {
                  return const LoadingView();
                }

                if (gallery.status == GalleryStatus.error && gallery.images.isEmpty) {
                  return ErrorView(
                    message: gallery.errorMessage ?? 'Something went wrong',
                    onRetry: gallery.loadFirstPage,
                  );
                }

                if (gallery.images.isEmpty) {
                  return const EmptyView(message: 'No images found, try another search.');
                }

                return RefreshIndicator(
                  onRefresh: gallery.loadFirstPage,
                  child: MasonryGridView.count(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemCount: gallery.images.length + (gallery.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= gallery.images.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final image = gallery.images[index];
                      return ImageTile(
                        image: image,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ImageDetailScreen(image: image)),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
