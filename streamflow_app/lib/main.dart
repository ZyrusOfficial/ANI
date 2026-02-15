import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/search/presentation/pages/search_page.dart';
import 'features/details/presentation/pages/series_details_page.dart';
import 'features/player/presentation/pages/player_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

import 'package:media_kit/media_kit.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();

  // Configure Android edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exception}');
    debugPrint('STACK TRACE: ${details.stack}');
  };

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(StorageService(prefs)),
      ],
      child: const StreamFlowApp(),
    ),
  );
}

class StreamFlowApp extends StatelessWidget {
  const StreamFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StreamFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const HomePage(),
            );
          case '/search':
            return MaterialPageRoute(
              builder: (_) => const SearchPage(),
            );
          case '/details':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => SeriesDetailsPage(
                seriesId: args?['id'],
                title: args?['title'],
              ),
            );
          case '/player':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => PlayerPage(
                seriesId: args?['seriesId'],
                episodeId: args?['episodeId'],
                episodeNumber: args?['episodeNumber'],
                seriesTitle: args?['seriesTitle'],
                episodeTitle: args?['episodeTitle'],
              ),
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (_) => const ProfilePage(),
            );
          case '/settings':
            return MaterialPageRoute(
              builder: (_) => const SettingsPage(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const HomePage(),
            );
        }
      },
    );
  }
}
