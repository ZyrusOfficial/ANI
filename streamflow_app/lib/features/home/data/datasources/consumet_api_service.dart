import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/anime_model.dart';

part 'consumet_api_service.g.dart';

/// Retrofit API service for Consumet endpoints
@RestApi(baseUrl: ApiEndpoints.baseUrl)
abstract class ConsumetApiService {
  factory ConsumetApiService(Dio dio, {String baseUrl}) = _ConsumetApiService;

  @GET(ApiEndpoints.trending)
  Future<AnimeListResponse> getTrending({
    @Query('page') int page = 1,
    @Query('perPage') int perPage = 20,
  });

  @GET(ApiEndpoints.popular)
  Future<AnimeListResponse> getPopular({
    @Query('page') int page = 1,
    @Query('perPage') int perPage = 20,
  });

  @GET(ApiEndpoints.search)
  Future<AnimeListResponse> searchAnime({
    @Query('query') required String query,
    @Query('page') int page = 1,
    @Query('perPage') int perPage = 20,
  });

  @GET('/meta/anilist/info/{id}')
  Future<Map<String, dynamic>> getAnimeInfo(@Path('id') String id);

  @GET('/anime/gogoanime/watch/{episodeId}')
  Future<Map<String, dynamic>> getStreamingLinks(@Path('episodeId') String episodeId);
}
