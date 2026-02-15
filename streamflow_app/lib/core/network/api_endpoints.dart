/// API Endpoints for Consumet
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - can be configured via environment variable or settings
  static const String baseUrl = 'https://consumet-api-clone.vercel.app';
  
  // AniList Meta Provider Endpoints
  static const String trending = '/meta/anilist/trending';
  static const String popular = '/meta/anilist/popular';
  static const String search = '/meta/anilist';
  static String animeInfo(String id) => '/meta/anilist/info/$id';
  
  // Gogoanime Provider Endpoints
  static String streamingLinks(String episodeId) => '/anime/gogoanime/watch/$episodeId';
  static String dubInfo(String title) => '/anime/gogoanime/info/$title-dub';
}
