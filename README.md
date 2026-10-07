# Infinity Gallery

Infinite-scroll image gallery built with Flutter for the intermediate Flutter
developer assignment. Pulls photos from the Pixabay API, lets you search and
filter by category, view a detail page per image, download images to the
device gallery, and save/unsave favorites that persist locally.

## Getting set up

1. Install Flutter (built and tested against Flutter 3.47 / Dart 3.13 stable).
2. `flutter pub get`
3. Get a free Pixabay API key:
   - Create an account at https://pixabay.com
   - Go to Account -> API docs, your key is shown at the top of that page
4. Copy `lib/core/constants/api_keys.example.dart` to
   `lib/core/constants/api_keys.dart` (gitignored) and paste your key in.
5. `flutter run`

Without a key the app won't throw on launch - the gallery screen will just
show the "Missing Pixabay API key" error view with a retry button, since the
check happens inside `PixabayApi.search()`.

### Building an APK

```
flutter build apk --release
```

Output lands in `build/app/outputs/flutter-apk/app-release.apk`.

## Architecture / state management

Kept this fairly flat and standard for the app's size rather than reaching
for Bloc/Riverpod - `provider` + `ChangeNotifier` was enough to keep state
and UI cleanly separated without extra ceremony.

```
lib/
  core/
    constants/   -> api key
    theme/       -> light/dark ThemeData
  models/        -> PixabayImage (plain Dart, fromJson/toJson)
  services/      -> PixabayApi (network), FavoritesStore (shared_preferences),
                     DownloadService (download + save to gallery)
  providers/     -> GalleryProvider, FavoritesProvider (ChangeNotifier)
  screens/       -> HomeScreen, ImageDetailScreen, FavoritesScreen
  widgets/       -> ImageTile, LoadingView/ErrorView/EmptyView
```

- **Services** only know how to talk to the outside world (HTTP, disk,
  gallery). They don't know about widgets or state.
- **Providers** hold UI state (`GalleryStatus` enum: initial/loading/
  loadingMore/loaded/error) and call into services. Screens just read/watch
  these through `Consumer`/`context.read`.
- **Screens/widgets** are dumb - they render whatever state the provider
  gives them and forward user actions back down.

This separation is mainly what made it easy to unit test `PixabayImage`
parsing and `FavoritesProvider` toggling without spinning up widgets or a
real network connection.

### Pagination

`GalleryProvider` tracks the current page/query/category and appends results
on `loadMore()`, which the grid's `ScrollController` triggers once the user
scrolls within ~400px of the bottom. `hasMore` flips to false once Pixabay
returns fewer than a full page, which is also what stops the trailing
loading spinner from showing forever on the last page.

### Favorites

Stored as a JSON-encoded list in `shared_preferences` - a full sqlite table
felt like overkill for a bounded list of image metadata. `FavoritesProvider`
keeps an in-memory `Map<id, PixabayImage>` and writes the whole list back to
disk on every toggle.

### Downloads

`DownloadService` checks/requests gallery permission via `gal`, downloads
the full-size image with `dio` (reporting progress through a callback that
drives the progress ring on the download button), then saves the bytes with
`Gal.putImageBytes`.

## Features implemented

- Responsive 2-column masonry grid (`flutter_staggered_grid_view`) that
  respects each photo's real aspect ratio instead of cropping to squares
- Infinite scroll pagination
- Loading / error / empty states, each a distinct widget
- Pull-to-refresh on the gallery
- Search by keyword + category filter chips
- Image detail screen with Hero transition, photographer, tags as a
  description, like/download/view/resolution stats
- Download to device gallery with progress indicator
- Favorite/unfavorite from the detail screen, favorites persisted across
  app restarts
- Dedicated favorites screen
- Image caching (disk + memory) and capped `memCacheWidth` on grid thumbnails
  via `cached_network_image` so scrolling doesn't re-decode full-res images
- Share button (shares the Pixabay page link)
- Light/dark theme, following system setting

## Assumptions / known limitations

- Pixabay doesn't return a real "description" field on search results, only
  `tags` - the detail screen uses the tag list as the description, which is
  the closest equivalent the API gives you.
- No offline cache of the gallery list itself - only images already loaded
  by `cached_network_image` are available offline; a cold start with no
  connection goes straight to the error view.
- Download permission handling is Android/iOS-focused (`gal` +
  `permission_handler`); the download button will still attempt to run on
  desktop/web but hasn't been exercised there.
- Category list is a manually picked subset of Pixabay's categories, not the
  full set.
- No automated integration test drives the real network call end to end -
  unit/widget tests mock or avoid the network boundary on purpose so the
  suite stays fast and deterministic.

## Testing

```
flutter test
```

Covers `PixabayImage` JSON parsing (including missing-field fallbacks),
`FavoritesProvider` add/remove/persistence behaviour against a mocked
`SharedPreferences`, and the loading/error/empty state widgets.
