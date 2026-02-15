import 'package:jikan_api/jikan_api.dart' as jikan;
import '../models/anime_models.dart';

class JikanApiService {
  final jikan.Jikan _jikan;
  final bool _enableLogging;

  JikanApiService({bool enableLogging = true}) 
      : _jikan = jikan.Jikan(),
        _enableLogging = enableLogging;

  void _log(String message) {
    if (_enableLogging) print('[JikanAPI] $message');
  }

  /// Search for anime
  Future<List<Anime>> search(String query) async {
    if (query.trim().isEmpty) return [];
    
    _log('Searching for: $query');
    
    try {
      final results = await _jikan.searchAnime(query: query);
      _log('Found ${results.length} results');
      return results.map((r) => _mapJikanToAnime(r)).toList();
    } catch (e) {
      _log('Search error: $e');
      return [];
    }
  }

  /// Get trending anime (Top Airing)
  Future<List<Anime>> getTrending({int page = 1}) async {
    _log('Getting trending (Top Airing) - Page $page');
    
    try {
      final results = await _jikan.getTopAnime(
        filter: jikan.TopFilter.airing, 
        page: page
      );
      _log('Trending found ${results.length} results');
      return results.map((r) => _mapJikanToAnime(r)).toList();
    } catch (e) {
      _log('Trending error: $e');
      return [];
    }
  }

  /// Get popular anime (Top All Time / Bypopularity)
  Future<List<Anime>> getPopular({int page = 1}) async {
    _log('Getting popular (Top By Popularity) - Page $page');
    
    try {
      final results = await _jikan.getTopAnime(
        filter: jikan.TopFilter.bypopularity, 
        page: page
      );
      _log('Popular found ${results.length} results');
      return results.map((r) => _mapJikanToAnime(r)).toList();
    } catch (e) {
      _log('Popular error: $e');
      return [];
    }
  }

  /// Get detailed anime info
  Future<Anime?> getAnimeInfo(String id) async {
    _log('Getting anime info for MAL ID: $id');
    
    try {
      final malId = int.tryParse(id);
      if (malId == null) throw Exception('Invalid MAL ID: $id');

      final result = await _jikan.getAnime(malId);
      return _mapJikanToAnime(result);
    } catch (e) {
      _log('Anime info error: $e');
      return null;
    }
  }

  /// Get episodes for an anime (Metadata only)
  Future<List<Episode>> getEpisodes(String id) async {
    _log('Getting episodes metadata for MAL ID: $id');
    
    try {
      final malId = int.tryParse(id);
      if (malId == null) return [];

      final results = await _jikan.getAnimeEpisodes(malId);
      _log('Found ${results.length} episodes');
      
      return results.asMap().entries.map((entry) {
        final e = entry.value;
        final epNum = entry.key + 1; // 1-based episode number
        return Episode(
          id: epNum.toString(),
          number: epNum,
          title: e.title ?? 'Episode $epNum',
          description: '',
          thumbnail: '',
          isFiller: e.filler ?? false,
        );
      }).toList();
    } catch (e) {
      _log('Episodes error: $e');
      return [];
    }
  }

  /// Get anime characters
  Future<List<Map<String, dynamic>>> getCharacters(String id) async {
    _log('Getting characters for MAL ID: $id');
    try {
      final malId = int.tryParse(id);
      if (malId == null) return [];

      // The jikan_api package returns List<CharacterMeta> directly in this version
      // CharacterMeta has name and imageUrl, but no role info
      final results = await _jikan.getAnimeCharacters(malId);
      _log('Found ${results.length} characters');
      
      return results.take(10).map((c) => {
        'name': c.name,
        'role': 'Character', // Role not available in CharacterMeta
        'image': c.imageUrl,
      }).toList();
    } catch (e) {
      _log('Characters error: $e');
      return [];
    }
  }

  /// Get anime recommendations
  Future<List<Anime>> getRecommendations(String id) async {
    _log('Getting recommendations for MAL ID: $id');
    try {
      final malId = int.tryParse(id);
      if (malId == null) return [];

      final results = await _jikan.getAnimeRecommendations(malId);
      _log('Found ${results.length} recommendations');
      
      return results.take(6).map((r) => Anime(
        id: r.entry.malId.toString(),
        title: r.entry.title,
        image: r.entry.imageUrl ?? '',
        // Minimal data for recommendations
        cover: r.entry.imageUrl ?? '',
        description: '',
        genres: [],
        rating: 0.0,
        releaseYear: null, // Fixed: match int? type
        status: '',
        totalEpisodes: 0,
        duration: '',
        type: '',
      )).toList();
    } catch (e) {
      _log('Recommendations error: $e');
      return [];
    }
  }

  /// Helper to convert Jikan Object -> App Anime Model
  Anime _mapJikanToAnime(dynamic jikanAnime) {
    // Determine English title
    String title = jikanAnime.title ?? 'Unknown';
    if (jikanAnime.titleEnglish != null && jikanAnime.titleEnglish!.isNotEmpty) {
      title = jikanAnime.titleEnglish!;
    }
    
    // Safely extract genres as List<String>
    // Note: older jikan_api might use BuiltList, so we avoid direct List cast
    final genres = jikanAnime.genres
        .map((g) => g.name.toString())
        .toList()
        .cast<String>();

    return Anime(
      id: jikanAnime.malId.toString(),
      title: title,
      image: jikanAnime.imageUrl ?? '',
      cover: jikanAnime.imageUrl ?? '',
      description: jikanAnime.synopsis ?? '',
      genres: genres,
      rating: jikanAnime.score,
      releaseYear: jikanAnime.year,
      status: jikanAnime.status,
      totalEpisodes: jikanAnime.episodes,
      duration: jikanAnime.duration,
      type: jikanAnime.type,
    );
  }
}
