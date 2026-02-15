import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_models.dart';

/// AllAnime API Service — Full ani-cli pipeline in Dart
///
/// Pipeline (matching ani-cli exactly):
///   1. GraphQL search → find show ID
///   2. GraphQL episode query → get sourceUrls (encrypted)
///   3. Decrypt sourceUrl hex cipher → get provider links
///   4. For clock.json providers: fetch JSON → extract M3U8/MP4
///   5. For direct providers (Yt-mp4): use URL directly with referrer
///   6. Sort by priority: direct M3U8 > direct MP4 > embeds
class AllAnimeApiService {
  static const String _agent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0';
  static const String _referer = 'https://allmanga.to';
  static const String _apiUrl = 'https://api.allanime.day/api';
  static const String _allanimeBase = 'https://allanime.day';

  static const Map<String, String> _defaultHeaders = {
    'User-Agent': _agent,
    'Referer': _referer,
  };

  // --- ani-cli hex cipher (provider_init) ---
  static const Map<String, String> _decryptMap = {
    '79': 'A', '7a': 'B', '7b': 'C', '7c': 'D', '7d': 'E', '7e': 'F',
    '7f': 'G', '70': 'H', '71': 'I', '72': 'J', '73': 'K', '74': 'L',
    '75': 'M', '76': 'N', '77': 'O', '68': 'P', '69': 'Q', '6a': 'R',
    '6b': 'S', '6c': 'T', '6d': 'U', '6e': 'V', '6f': 'W', '60': 'X',
    '61': 'Y', '62': 'Z', '59': 'a', '5a': 'b', '5b': 'c', '5c': 'd',
    '5d': 'e', '5e': 'f', '5f': 'g', '50': 'h', '51': 'i', '52': 'j',
    '53': 'k', '54': 'l', '55': 'm', '56': 'n', '57': 'o', '48': 'p',
    '49': 'q', '4a': 'r', '4b': 's', '4c': 't', '4d': 'u', '4e': 'v',
    '4f': 'w', '40': 'x', '41': 'y', '42': 'z', '08': '0', '09': '1',
    '0a': '2', '0b': '3', '0c': '4', '0d': '5', '0e': '6', '0f': '7',
    '00': '8', '01': '9', '15': '-', '16': '.', '67': '_', '46': '~',
    '02': ':', '17': '/', '07': '?', '1b': '#', '63': '[', '65': ']',
    '78': '@', '19': '!', '1c': r'$', '1e': '&', '10': '(', '11': ')',
    '12': '*', '13': '+', '14': ',', '03': ';', '05': '=', '1d': '%',
  };

  // Provider priority order (from ani-cli generate_link):
  //   4 = hianime (Luf-Mp4)  → best, M3U8
  //   1 = wixmp   (Default)  → M3U8
  //   3 = sharepoint (S-mp4) → MP4/M3U8
  //   2 = youtube (Yt-mp4)   → direct MP4
  // We also handle: Ok, Mp4, Sw, Sup, Uni as embed fallbacks
  static const List<String> _preferredProviders = [
    'Luf-Mp4', 'Default', 'S-mp4', 'Yt-mp4',
  ];

  /// Search for anime, return list of matches with IDs
  Future<List<Map<String, dynamic>>> searchAnime(String query, {bool sub = true}) async {
    const searchGql = r'''
      query( $search: SearchInput $limit: Int $page: Int $translationType: VaildTranslationTypeEnumType $countryOrigin: VaildCountryOriginEnumType ) { 
        shows( search: $search limit: $limit page: $page translationType: $translationType countryOrigin: $countryOrigin ) { 
          edges { _id name availableEpisodes __typename } 
        }
      }
    ''';

    final variables = {
      "search": {"allowAdult": false, "allowUnknown": false, "query": query},
      "limit": 40,
      "page": 1,
      "translationType": sub ? "sub" : "dub",
      "countryOrigin": "ALL",
    };

    try {
      final uri = Uri.parse(_apiUrl).replace(queryParameters: {
        'variables': jsonEncode(variables),
        'query': searchGql,
      });

      final response = await http.get(uri, headers: _defaultHeaders);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final shows = data['data']?['shows']?['edges'] as List? ?? [];
      return shows.map<Map<String, dynamic>>((s) => {
        'id': s['_id'],
        'name': s['name'],
        'episodes': s['availableEpisodes'],
      }).toList();
    } catch (e) {
      print('[AllAnime] Search error: $e');
      return [];
    }
  }

  /// Get streaming sources for an anime title + episode number
  /// This is the main entry point — replicates ani-cli's full pipeline
  Future<StreamingInfo?> getSourcesByTitle(String title, int episodeNumber) async {
    try {
      // 1. Search for the anime
      final results = await searchAnime(title);
      if (results.isEmpty) {
        print('[AllAnime] No results for: $title');
        return null;
      }

      // Smart Selection Logic:
      // availableEpisodes is a Map: {"sub": N, "dub": N, "raw": 0}
      // Extract the sub count for filtering
      int _getSubCount(Map<String, dynamic> show) {
        final ep = show['episodes'];
        if (ep is Map) return (ep['sub'] as int?) ?? 0;
        if (ep is int) return ep;
        return 0;
      }

      // 1. Filter candidates that have enough sub episodes
      final candidates = results.where((s) => _getSubCount(s) >= episodeNumber).toList();

      // 2. Sort by sub count descending (prefer main series with most episodes)
      candidates.sort((a, b) => _getSubCount(b).compareTo(_getSubCount(a)));

      Map<String, dynamic> bestMatch;

      if (candidates.isNotEmpty) {
        // 3. Among valid candidates, prefer exact name match
        bestMatch = candidates.firstWhere(
          (s) => (s['name'] as String).toLowerCase() == title.toLowerCase(),
          orElse: () => candidates.first,
        );
      } else {
        // Fallback: pick show with most episodes even if < episodeNumber
        results.sort((a, b) => _getSubCount(b).compareTo(_getSubCount(a)));
        bestMatch = results.first;
      }

      final showId = bestMatch['id'] as String;
      final showName = bestMatch['name'] as String;
      final subEps = _getSubCount(bestMatch);
      print('[AllAnime] Found: "$showName" (ID: $showId) for query "$title" (Sub eps: $subEps)');

      // 2. Get episode sourceUrls
      final rawSources = await _getEpisodeSources(showId, episodeNumber.toString());
      if (rawSources.isEmpty) {
        print('[AllAnime] No sources for episode $episodeNumber');
        return null;
      }

      print('[AllAnime] Got ${rawSources.length} raw sources: ${rawSources.map((s) => s['sourceName']).join(', ')}');

      // 3. Process ALL providers in parallel (like ani-cli does)
      final allSources = <StreamingSource>[];
      final futures = <Future<List<StreamingSource>>>[];

      for (var src in rawSources) {
        futures.add(_processProvider(
          src['sourceName'] as String,
          src['sourceUrl'] as String,
          src['priority'] as num? ?? 0,
          src['type'] as String? ?? '',
        ));
      }

      final results2 = await Future.wait(futures);
      for (var providerSources in results2) {
        allSources.addAll(providerSources);
      }

      if (allSources.isEmpty) {
        print('[AllAnime] No playable sources found after processing all providers');
        return null;
      }

      // 4. Sort: M3U8 first, then MP4, then embeds. Higher priority first.
      allSources.sort((a, b) {
        // M3U8 > MP4 > embed
        final aScore = a.isM3U8 ? 3 : (a.url.contains('.mp4') || a.quality.contains('mp4') ? 2 : 1);
        final bScore = b.isM3U8 ? 3 : (b.url.contains('.mp4') || b.quality.contains('mp4') ? 2 : 1);
        if (aScore != bScore) return bScore.compareTo(aScore);
        return 0;
      });

      print('[AllAnime] Final sources (${allSources.length}):');
      for (var s in allSources) {
        print('  [${s.quality}] M3U8=${s.isM3U8} ${s.url.substring(0, s.url.length.clamp(0, 80))}...');
      }

      return StreamingInfo(
        headers: _defaultHeaders,
        sources: allSources,
        subtitles: [],
      );
    } catch (e) {
      print('[AllAnime] Error: $e');
      return null;
    }
  }

  /// Get raw episode sources from GraphQL
  Future<List<Map<String, dynamic>>> _getEpisodeSources(String showId, String episodeString) async {
    const embedGql = r'''
      query ($showId: String!, $translationType: VaildTranslationTypeEnumType!, $episodeString: String!) { 
        episode( showId: $showId translationType: $translationType episodeString: $episodeString ) { 
          episodeString sourceUrls 
        }
      }
    ''';

    try {
      final uri = Uri.parse(_apiUrl).replace(queryParameters: {
        'variables': jsonEncode({
          "showId": showId,
          "translationType": "sub",
          "episodeString": episodeString,
        }),
        'query': embedGql,
      });

      final response = await http.get(uri, headers: _defaultHeaders);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final episode = data['data']?['episode'];
      if (episode == null) return [];

      final sourceUrls = episode['sourceUrls'] as List? ?? [];
      return sourceUrls.map<Map<String, dynamic>>((s) => {
        'sourceName': s['sourceName'] ?? 'Unknown',
        'sourceUrl': s['sourceUrl'] ?? '',
        'priority': s['priority'] ?? 0,
        'type': s['type'] ?? '',
      }).toList();
    } catch (e) {
      print('[AllAnime] Episode source error: $e');
      return [];
    }
  }

  /// Process a single provider (decrypt + fetch links)
  Future<List<StreamingSource>> _processProvider(
    String sourceName, String sourceUrl, num priority, String type,
  ) async {
    final sources = <StreamingSource>[];

    try {
      String url = sourceUrl;

      // Decrypt if encrypted (starts with --)
      if (url.startsWith('--')) {
        url = _decryptSourceUrl(url.substring(2));
        print('[AllAnime] [$sourceName] Decrypted → ${url.substring(0, url.length.clamp(0, 60))}...');
      }

      // Case 1: Relative path → clock.json endpoint on allanime.day
      if (url.startsWith('/')) {
        final clockUrl = '$_allanimeBase${url.replaceAll('/clock', '/clock.json')}';
        return await _fetchClockJson(sourceName, clockUrl);
      }

      // Case 2: Direct CDN URL (tools.fast4speed.rsvp, wixmp, sharepoint, etc.)
      if (url.startsWith('http') && !_isEmbedUrl(url)) {
        // This is a direct video file — check if it's M3U8 or MP4
        final isM3U8 = url.contains('.m3u8');
        sources.add(StreamingSource(
          url: url,
          quality: '$sourceName-direct',
          isM3U8: isM3U8,
        ));
        print('[AllAnime] [$sourceName] Direct ${isM3U8 ? "M3U8" : "MP4"} link');
        return sources;
      }

      // Case 3: Embed URL (ok.ru, mp4upload, streamwish, etc.)
      // We still include these as fallback, but marked as non-M3U8
      if (url.startsWith('http')) {
        sources.add(StreamingSource(
          url: url,
          quality: '$sourceName-embed',
          isM3U8: false,
        ));
        print('[AllAnime] [$sourceName] Embed URL (fallback)');
      }
    } catch (e) {
      print('[AllAnime] [$sourceName] Error: $e');
    }

    return sources;
  }

  /// Fetch clock.json and extract streaming links
  Future<List<StreamingSource>> _fetchClockJson(String providerName, String clockUrl) async {
    final sources = <StreamingSource>[];

    try {
      print('[AllAnime] [$providerName] Fetching clock.json...');
      final response = await http.get(Uri.parse(clockUrl), headers: _defaultHeaders);

      if (response.statusCode != 200) {
        print('[AllAnime] [$providerName] clock.json returned ${response.statusCode}');
        return sources;
      }

      final clockData = jsonDecode(response.body);
      final links = clockData['links'] as List? ?? [];

      for (var link in links) {
        final linkUrl = link['link']?.toString();
        if (linkUrl == null || linkUrl.isEmpty) continue;

        final resolution = link['resolutionStr']?.toString() ?? 'auto';
        final isHls = link['hls'] == true;
        final isMP4 = link['mp4'] == true;
        final referer = link['Referer']?.toString();

        sources.add(StreamingSource(
          url: linkUrl,
          quality: '$providerName-$resolution',
          isM3U8: isHls || linkUrl.contains('.m3u8'),
        ));

        // If there's a subtitle, we could extract it too
        // (TODO: parse link['subtitles'] array)
      }

      print('[AllAnime] [$providerName] Got ${sources.length} links from clock.json');
    } catch (e) {
      print('[AllAnime] [$providerName] clock.json error: $e');
    }

    return sources;
  }

  /// Check if a URL is an embed page (not a direct video file)
  bool _isEmbedUrl(String url) {
    final embedDomains = [
      'ok.ru', 'mp4upload.com', 'streamwish.to', 'strmup.cc',
      'allanime.uns.bio', 'filemoon.sx', 'vidplay.online',
      'megacloud.tv', 'rapid-cloud.co',
    ];
    return embedDomains.any((d) => url.contains(d));
  }

  /// Decrypt hex-encoded source URL using ani-cli's cipher
  String _decryptSourceUrl(String hex) {
    final buffer = StringBuffer();
    for (int i = 0; i < hex.length; i += 2) {
      if (i + 2 > hex.length) break;
      final pair = hex.substring(i, i + 2);
      buffer.write(_decryptMap[pair] ?? pair);
    }
    return buffer.toString();
  }
}
