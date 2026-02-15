/// Anime data model representing a series or movie
class Anime {
  final String id;
  final String title;
  final String? titleEnglish;
  final String? titleJapanese;
  final String image;
  final String? cover;
  final String? description;
  final int? releaseYear;
  final String? status;
  final double? rating;
  final List<String> genres;
  final int? totalEpisodes;
  final String? type; // TV, Movie, OVA, etc.
  final String? duration;
  final String? studio;

  const Anime({
    required this.id,
    required this.title,
    this.titleEnglish,
    this.titleJapanese,
    required this.image,
    this.cover,
    this.description,
    this.releaseYear,
    this.status,
    this.rating,
    this.genres = const [],
    this.totalEpisodes,
    this.type,
    this.duration,
    this.studio,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id']?.toString() ?? '',
      title: json['title']?['english'] ?? 
             json['title']?['romaji'] ?? 
             json['title']?.toString() ?? 
             'Unknown',
      titleEnglish: json['title']?['english'],
      titleJapanese: json['title']?['native'],
      image: json['image'] ?? json['cover'] ?? '',
      cover: json['cover'],
      description: json['description'],
      releaseYear: json['releaseDate'] is int 
          ? json['releaseDate'] 
          : int.tryParse(json['releaseDate']?.toString() ?? ''),
      status: json['status'],
      rating: json['rating'] != null 
          ? (json['rating'] is int 
              ? (json['rating'] as int).toDouble() 
              : json['rating'] as double?) 
          : null,
      genres: (json['genres'] as List<dynamic>?)
          ?.map((g) => g.toString())
          .toList() ?? [],
      totalEpisodes: json['totalEpisodes'],
      type: json['type'],
      duration: json['duration']?.toString(),
      studio: (json['studios'] as List<dynamic>?)?.firstOrNull,
    );
  }

  /// Create from Gogoanime/Zoro search result format
  factory Anime.fromSearchResult(Map<String, dynamic> json) {
    return Anime(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown',
      image: json['image'] ?? json['poster'] ?? '',
      releaseYear: json['releaseDate'] != null 
          ? int.tryParse(json['releaseDate'].toString())
          : null,
      type: json['subOrDub'] ?? json['type'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': {'english': title, 'romaji': title, 'native': titleJapanese},
      'image': image,
      'cover': cover,
      'description': description,
      'releaseDate': releaseYear,
      'status': status,
      'rating': rating,
      'genres': genres,
      'totalEpisodes': totalEpisodes,
      'type': type,
      'duration': duration,
      'studios': studio != null ? [studio] : [],
    };
  }
}

/// Episode data model
class Episode {
  final String id;
  final int number;
  final String? title;
  final String? description;
  final String? thumbnail;
  final String? duration;
  final bool isFiller;

  const Episode({
    required this.id,
    required this.number,
    this.title,
    this.description,
    this.thumbnail,
    this.duration,
    this.isFiller = false,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id']?.toString() ?? '',
      number: json['number'] ?? json['episodeNumber'] ?? 0,
      title: json['title'],
      description: json['description'],
      thumbnail: json['image'],
      duration: json['duration']?.toString(),
      isFiller: json['isFiller'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'description': description,
      'image': thumbnail,
      'duration': duration,
      'isFiller': isFiller,
    };
  }
}

/// Streaming source with quality options
class StreamingSource {
  final String url;
  final String quality;
  final bool isM3U8;

  const StreamingSource({
    required this.url,
    required this.quality,
    this.isM3U8 = true,
  });

  factory StreamingSource.fromJson(Map<String, dynamic> json) {
    return StreamingSource(
      url: json['url'] ?? '',
      quality: json['quality'] ?? 'default',
      isM3U8: json['isM3U8'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'quality': quality,
      'isM3U8': isM3U8,
    };
  }
}

class StreamingInfo {
  final List<StreamingSource> sources;
  final List<Subtitle> subtitles;
  final String? intro; // Skip intro timestamp
  final Map<String, String>? headers; // Headers for playback (Referer, etc)

  const StreamingInfo({
    required this.sources,
    this.subtitles = const [],
    this.intro,
    this.headers,
  });

  factory StreamingInfo.fromJson(Map<String, dynamic> json) {
    return StreamingInfo(
      sources: (json['sources'] as List<dynamic>?)
          ?.map((s) => StreamingSource.fromJson(s))
          .toList() ?? [],
      subtitles: (json['subtitles'] as List<dynamic>?)
          ?.map((s) => Subtitle.fromJson(s))
          .toList() ?? [],
      headers: (json['headers'] as Map<String, dynamic>?)?.cast<String, String>(),
    );
  }

  /// Get best quality source
  StreamingSource? get bestQuality {
    if (sources.isEmpty) return null;
    
    final priorities = ['1080p', '720p', '480p', '360p', 'default', 'auto'];
    for (final quality in priorities) {
      final source = sources.firstWhere(
        (s) => s.quality.toLowerCase().contains(quality),
        orElse: () => sources.first,
      );
      if (source.url.isNotEmpty) return source;
    }
    return sources.first;
  }
}

/// Subtitle track
class Subtitle {
  final String url;
  final String language;

  const Subtitle({
    required this.url,
    required this.language,
  });

  factory Subtitle.fromJson(Map<String, dynamic> json) {
    return Subtitle(
      url: json['url'] ?? '',
      language: json['lang'] ?? 'Unknown',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'lang': language,
    };
  }
}
