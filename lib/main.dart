import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/favorites_provider.dart';
import 'providers/gallery_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const InfinityGalleryApp());
}

class InfinityGalleryApp extends StatelessWidget {
  const InfinityGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Infinity Gallery',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
