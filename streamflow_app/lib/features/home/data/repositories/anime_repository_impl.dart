import '../../domain/entities/anime.dart';
import '../../domain/repositories/anime_repository.dart';
import '../datasources/consumet_api_service.dart';
import '../models/anime_mapper.dart';

/// Implementation of AnimeRepository using Consumet API
class AnimeRepositoryImpl implements AnimeRepository {
  final ConsumetApiService _apiService;

  AnimeRepositoryImpl(this._apiService);

  @override
  Future<List<Anime>> getTrending({int page = 1, int perPage = 20}) async {
    try {
      final response = await _apiService.getTrending(
        page: page,
        perPage: perPage,
      );
      return response.results?.toEntities() ?? [];
    } catch (e) {
      print('[AnimeRepository] Error fetching trending: $e');
      rethrow;
    }
  }

  @override
  Future<List<Anime>> getPopular({int page = 1, int perPage = 20}) async {
    try {
      final response = await _apiService.getPopular(
        page: page,
        perPage: perPage,
      );
      return response.results?.toEntities() ?? [];
    } catch (e) {
      print('[AnimeRepository] Error fetching popular: $e');
      rethrow;
    }
  }

  @override
  Future<List<Anime>> searchAnime(
    String query, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiService.searchAnime(
        query: query,
        page: page,
        perPage: perPage,
      );
      return response.results?.toEntities() ?? [];
    } catch (e) {
      print('[AnimeRepository] Error searching anime: $e');
      rethrow;
    }
  }
}
