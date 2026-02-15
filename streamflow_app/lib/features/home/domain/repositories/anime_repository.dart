import '../entities/anime.dart';

/// Repository interface for anime data
abstract class AnimeRepository {
  Future<List<Anime>> getTrending({int page = 1, int perPage = 20});
  Future<List<Anime>> getPopular({int page = 1, int perPage = 20});
  Future<List<Anime>> searchAnime(String query, {int page = 1, int perPage = 20});
}
