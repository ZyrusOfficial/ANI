import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/allanime_api.dart'; // Remote Streaming (AllAnime)
import '../api/jikan_api.dart'; // For metadata (MAL)
import '../models/anime_models.dart';
import '../api/gogo_scraper.dart'; // Scraper Fallback (Gogoanime)

/// Provider for Jikan API (MyAnimeList Metadata)
final jikanApiProvider = Provider<JikanApiService>((ref) {
  return JikanApiService();
});

/// Provider for AllAnime API (Primary Streaming Source)
final allAnimeApiProvider = Provider<AllAnimeApiService>((ref) {
  return AllAnimeApiService();
});

/// Provider for GogoScraper (Fallback Streaming Source)
final gogoScraperProvider = Provider<GogoScraperService>((ref) {
  return GogoScraperService();
});

/// Provider for trending anime (Top Airing on MAL)
final trendingAnimeProvider = FutureProvider<List<Anime>>((ref) async {
  final api = ref.watch(jikanApiProvider);
  return api.getTrending(page: 1);
});

/// Provider for popular anime (Top All Time on MAL)
final popularAnimeProvider = FutureProvider<List<Anime>>((ref) async {
  final api = ref.watch(jikanApiProvider);
  return api.getPopular(page: 1);
});

/// Provider for search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for search results
final searchResultsProvider = FutureProvider<List<Anime>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  
  final api = ref.watch(jikanApiProvider);
  return api.search(query);
});

/// Provider for anime details by ID (MAL ID)
final animeDetailsProvider = FutureProvider.family<Anime?, String>((ref, id) async {
  final api = ref.watch(jikanApiProvider);
  return api.getAnimeInfo(id);
});

/// Provider for episodes by anime ID (MAL ID)
final episodesProvider = FutureProvider.family<List<Episode>, String>((ref, id) async {
  final api = ref.watch(jikanApiProvider);
  return api.getEpisodes(id);
});

/// Provider for streaming sources
/// Tries AllAnime first, then falls back to GogoScraper
final streamingSourcesProvider = FutureProvider.family<StreamingInfo?, ({String title, int episode})>((ref, params) async {
  // 1. Try AllAnime (Direct API)
  try {
    print('[Provider] Trying AllAnime for: ${params.title}');
    final allAnime = ref.watch(allAnimeApiProvider);
    final sources = await allAnime.getSourcesByTitle(params.title, params.episode);
    
    if (sources != null && sources.sources.isNotEmpty) {
       print('[Provider] AllAnime found sources');
       return sources;
    }
  } catch (e) {
    print('[Provider] AllAnime failed: $e');
  }

  // 2. Fallback to GogoScraper (HTML Parsing)
  print('[Provider] AllAnime failed/empty. Falling back to GogoScraper...');
  try {
    final gogo = ref.watch(gogoScraperProvider);
    
    // Use title search inside scraper
    final sources = await gogo.getStreamingSources(params.title, params.episode);
    
    if (sources != null && sources.sources.isNotEmpty) {
       print('[Provider] GogoScraper found sources');
       return sources;
    }
  } catch (e) {
    print('[Provider] GogoScraper failed: $e');
  }
  
  return null;
});

/// Provider for anime by genre (fallback to search)
final genreAnimeProvider = FutureProvider.family<List<Anime>, String>((ref, genre) async {
  final api = ref.watch(jikanApiProvider);
  return api.search(genre);
});

