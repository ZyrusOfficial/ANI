import 'package:freezed_annotation/freezed_annotation.dart';

part 'anime_model.freezed.dart';
part 'anime_model.g.dart';

/// Model for anime items from trending/popular endpoints
@freezed
class AnimeModel with _$AnimeModel {
  const factory AnimeModel({
    required String id,
    String? malId,
    @JsonKey(name: 'title') required TitleModel title,
    String? image,
    String? cover,
    int? popularity,
    String? color,
    String? description,
    String? status,
    int? releaseDate,
    @JsonKey(name: 'genres') List<String>? genres,
    int? totalEpisodes,
    int? currentEpisode,
    String? type,
    String? countryOfOrigin,
  }) = _AnimeModel;

  factory AnimeModel.fromJson(Map<String, dynamic> json) => 
      _$AnimeModelFromJson(json);
}

@freezed
class TitleModel with _$TitleModel {
  const factory TitleModel({
    String? romaji,
    String? english,
    String? native,
  }) = _TitleModel;

  factory TitleModel.fromJson(Map<String, dynamic> json) =>
      _$TitleModelFromJson(json);
}

/// Response model for trending/popular endpoints
@freezed
class AnimeListResponse with _$AnimeListResponse {
  const factory AnimeListResponse({
    int? currentPage,
    bool? hasNextPage,
    List<AnimeModel>? results,
  }) = _AnimeListResponse;

  factory AnimeListResponse.fromJson(Map<String, dynamic> json) =>
      _$AnimeListResponseFromJson(json);
}
