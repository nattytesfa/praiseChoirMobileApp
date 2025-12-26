import 'package:flutter/material.dart';
import 'package:praise_choir_app/features/songs/data/models/song_model.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/add_song_screen.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/edit_song_screen.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/lyrics_display.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/song_detail_screen.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/song_library_screen.dart';
import 'package:praise_choir_app/features/songs/presentation/screens/song_search_screen.dart';

class SongRoutes {
  static const String songLibrary = '/songs';
  static const String detail = '/songs/detail';
  static const String add = '/songs/add';
  static const String edit = '/songs/edit';
  static const String search = '/songs/search';
  static const String lyricsFullscreen = '/songs/lyrics-fullscreen';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case songLibrary:
        return MaterialPageRoute(
          builder: (_) => const SongLibraryScreen(),
          settings: settings,
        );

      case detail:
        final SongModel song = settings.arguments as SongModel;
        return MaterialPageRoute(
          builder: (_) => SongDetailScreen(song: song),
          settings: settings,
        );

      case add:
        return MaterialPageRoute(
          builder: (_) => const AddSongScreen(),
          settings: settings,
        );

      case edit:
        final SongModel song = settings.arguments as SongModel;
        return MaterialPageRoute(
          builder: (_) => EditSongScreen(song: song),
          settings: settings,
        );

      case search:
        return MaterialPageRoute(
          builder: (_) => const SongSearchScreen(),
          settings: settings,
        );

      case lyricsFullscreen:
        final Map<String, dynamic> args =
            settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => LyricsDisplay(
            lyrics: args['lyrics'] as String,
            title: args['title'] as String,
            language: '',
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      songLibrary: (context) => const SongLibraryScreen(),
      search: (context) => const SongSearchScreen(),
      add: (context) => const AddSongScreen(),
    };
  }

  // Navigation helper methods
  static void navigateToLibrary(BuildContext context) {
    Navigator.pushNamed(context, songLibrary);
  }

  static void navigateToDetail(BuildContext context, SongModel song) {
    Navigator.pushNamed(context, detail, arguments: song);
  }

  static void navigateToAdd(BuildContext context) {
    Navigator.pushNamed(context, add);
  }

  static void navigateToEdit(BuildContext context, SongModel song) {
    Navigator.pushNamed(context, edit, arguments: song);
  }

  static void navigateToSearch(BuildContext context) {
    Navigator.pushNamed(context, search);
  }

  static void navigateToLyricsFullscreen(
    BuildContext context, {
    required String lyrics,
    required String songTitle,
  }) {
    Navigator.pushNamed(
      context,
      lyricsFullscreen,
      arguments: {'lyrics': lyrics, 'songTitle': songTitle},
    );
  }

  // Replacement navigation methods (replace current route)
  static void replaceWithLibrary(BuildContext context) {
    Navigator.pushReplacementNamed(context, songLibrary);
  }

  static void replaceWithDetail(BuildContext context, SongModel song) {
    Navigator.pushReplacementNamed(context, detail, arguments: song);
  }

  // Push and remove until methods
  static void pushAndRemoveUntilLibrary(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, songLibrary, (route) => false);
  }

  // Modal routes for bottom sheets/dialogs
  static Future<T?> showVersionSelector<T>({
    required BuildContext context,
    required SongModel song,
    required Function(SongVersion) onVersionAdded,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Add Song Version',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // VersionSelector would be imported and used here
            // Expanded(
            //   child: VersionSelector(
            //     song: song,
            //     onVersionAdded: onVersionAdded,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  static Future<T?> showSongFilters<T>({
    required BuildContext context,
    required Function(Map<String, dynamic>) onFiltersApplied,
    required Map<String, dynamic> currentFilters,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Filter Songs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // SongFilterSheet would be implemented here
            // Expanded(
            //   child: SongFilterSheet(
            //     onFiltersApplied: onFiltersApplied,
            //     currentFilters: currentFilters,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Route guards and permission checks
  static bool canEditSong(BuildContext context, SongModel song) {
    // For now, return true - will be replaced with actual auth check
    return true;
  }

  static bool canAddSong(BuildContext context) {
    // Leaders and Atigni can add songs
    return true;
  }

  // Route animation customization
  static PageRouteBuilder fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static PageRouteBuilder slideTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
