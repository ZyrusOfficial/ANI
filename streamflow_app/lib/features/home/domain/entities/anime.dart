import 'package:equatable/equatable.dart';

/// Domain entity for Anime
class Anime extends Equatable {
  final String id;
  final String? malId;
  final String titleEnglish;
  final String titleRomaji;
  final String? titleNative;
  final String? imageUrl;
  final String? coverUrl;
  final int? popularity;
  final String? accentColor;
  final String? description;
  final String? status;
  final int? releaseYear;
  final List<String> genres;
  final int? totalEpisodes;
  final int? currentEpisode;
  final String? type;
  final String? country;

  const Anime({
    required this.id,
    this.malId,
    required this.titleEnglish,
    required this.titleRomaji,
    this.titleNative,
    this.imageUrl,
    this.coverUrl,
    this.popularity,
    this.accentColor,
    this.description,
    this.status,
    this.releaseYear,
    this.genres = const [],
    this.totalEpisodes,
    this.currentEpisode,
    this.type,
    this.country,
  });

  /// Get display title (prefer English, fallback to Romaji)
  String get displayTitle => titleEnglish.isNotEmpty ? titleEnglish : titleRomaji;

  @override
  List<Object?> get props => [
        id,
        malId,
        titleEnglish,
        titleRomaji,
        titleNative,
        imageUrl,
        coverUrl,
        popularity,
        accentColor,
        description,
        status,
        releaseYear,
        genres,
        totalEpisodes,
        currentEpisode,
        type,
        country,
      ];
}
