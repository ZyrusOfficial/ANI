// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnimeModelImpl _$$AnimeModelImplFromJson(Map<String, dynamic> json) =>
    _$AnimeModelImpl(
      id: json['id'] as String,
      malId: json['malId'] as String?,
      title: TitleModel.fromJson(json['title'] as Map<String, dynamic>),
      image: json['image'] as String?,
      cover: json['cover'] as String?,
      popularity: (json['popularity'] as num?)?.toInt(),
      color: json['color'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      releaseDate: (json['releaseDate'] as num?)?.toInt(),
      genres:
          (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
      totalEpisodes: (json['totalEpisodes'] as num?)?.toInt(),
      currentEpisode: (json['currentEpisode'] as num?)?.toInt(),
      type: json['type'] as String?,
      countryOfOrigin: json['countryOfOrigin'] as String?,
    );

Map<String, dynamic> _$$AnimeModelImplToJson(_$AnimeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'malId': instance.malId,
      'title': instance.title,
      'image': instance.image,
      'cover': instance.cover,
      'popularity': instance.popularity,
      'color': instance.color,
      'description': instance.description,
      'status': instance.status,
      'releaseDate': instance.releaseDate,
      'genres': instance.genres,
      'totalEpisodes': instance.totalEpisodes,
      'currentEpisode': instance.currentEpisode,
      'type': instance.type,
      'countryOfOrigin': instance.countryOfOrigin,
    };

_$TitleModelImpl _$$TitleModelImplFromJson(Map<String, dynamic> json) =>
    _$TitleModelImpl(
      romaji: json['romaji'] as String?,
      english: json['english'] as String?,
      native: json['native'] as String?,
    );

Map<String, dynamic> _$$TitleModelImplToJson(_$TitleModelImpl instance) =>
    <String, dynamic>{
      'romaji': instance.romaji,
      'english': instance.english,
      'native': instance.native,
    };

_$AnimeListResponseImpl _$$AnimeListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$AnimeListResponseImpl(
      currentPage: (json['currentPage'] as num?)?.toInt(),
      hasNextPage: json['hasNextPage'] as bool?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => AnimeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$AnimeListResponseImplToJson(
        _$AnimeListResponseImpl instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'hasNextPage': instance.hasNextPage,
      'results': instance.results,
    };
