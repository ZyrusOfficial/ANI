import '../entities/anime.dart';
import '../../data/models/anime_model.dart';

/// Extension to convert AnimeModel to Anime entity
extension AnimeModelX on AnimeModel {
  Anime toEntity() {
    return Anime(
      id: id,
      malId: malId,
      titleEnglish: title.english ?? '',
      titleRomaji: title.romaji ?? '',
      titleNative: title.native,
      imageUrl: image,
      coverUrl: cover,
      popularity: popularity,
      accentColor: color,
      description: description,
      status: status,
      releaseYear: releaseDate,
      genres: genres ?? [],
      totalEpisodes: totalEpisodes,
      currentEpisode: currentEpisode,
      type: type,
      country: countryOfOrigin,
    );
  }
}

/// Extension to convert list of AnimeModel to list of Anime
extension AnimeModelListX on List<AnimeModel> {
  List<Anime> toEntities() {
    return map((model) => model.toEntity()).toList();
  }
}
