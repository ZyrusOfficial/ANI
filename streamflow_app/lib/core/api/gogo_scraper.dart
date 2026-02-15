import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:encrypt/encrypt.dart' as encrypt;
import '../models/anime_models.dart';

/// Enhanced Gogoanime Scraper with M3U8 Extraction
/// 
/// This implements proper video URL extraction similar to Aniyomi/Cloudstream:
/// 1. Find episode page → get embed URL
/// 2. Fetch embed page → extract encrypted data
/// 3. AES-128 decrypt → get actual M3U8 stream URL
class GogoScraperService {
  static const String _baseUrl = 'https://anitaku.to';
  static const String _ajaxUrl = 'https://ajax.gogocdn.net';
  
  // Decryption keys (from open source projects - may need updates)
  // These keys are used by Gogoanime's encryption
  static const String _encryptionKey = '37911490979715163134003223491201';
  static const String _decryptionKey = '54674138327930866480207815084989';
  static const String _iv = '3134003223491201';
  
  static const Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
  };

  /// Get playable M3U8 streaming sources for an episode
  Future<StreamingInfo?> getStreamingSources(String animeTitle, int episodeNumber) async {
    try {
      print('[GogoScraper] Starting extraction for: $animeTitle E$episodeNumber');
      
      // Step 1: Get embed URL from episode page
      final embedUrl = await _getEmbedUrl(animeTitle, episodeNumber);
      if (embedUrl == null) {
        print('[GogoScraper] Could not find embed URL');
        return null;
      }
      
      print('[GogoScraper] Found embed: $embedUrl');
      
      // Step 2: Extract M3U8 from embed
      final sources = await _extractM3U8FromEmbed(embedUrl);
      if (sources != null && sources.isNotEmpty) {
        return StreamingInfo(
          headers: {'Referer': _baseUrl},
          sources: sources,
        );
      }
      
      // Fallback: Return embed URL for WebView playback
      print('[GogoScraper] M3U8 extraction failed, returning embed URL');
      return StreamingInfo(
        headers: {'Referer': _baseUrl},
        sources: [StreamingSource(url: embedUrl, quality: 'embed', isM3U8: false)],
      );
      
    } catch (e) {
      print('[GogoScraper] Error: $e');
      return null;
    }
  }

  /// Get the embed iframe URL from episode page
  Future<String?> _getEmbedUrl(String animeTitle, int episodeNumber) async {
    // Try direct slug first
    String slug = _titleToSlug(animeTitle);
    String? embedUrl = await _fetchEmbedFromPage('$_baseUrl/$slug-episode-$episodeNumber');
    
    if (embedUrl != null) return embedUrl;
    
    // Fallback: Search for correct slug
    print('[GogoScraper] Direct slug failed, searching...');
    final searchSlug = await _searchForSlug(animeTitle);
    if (searchSlug != null) {
      embedUrl = await _fetchEmbedFromPage('$_baseUrl/$searchSlug-episode-$episodeNumber');
    }
    
    return embedUrl;
  }

  /// Fetch embed URL from a specific page URL
  Future<String?> _fetchEmbedFromPage(String url) async {
    try {
      print('[GogoScraper] Fetching page: $url');
      final response = await http.get(Uri.parse(url), headers: _headers);
      
      if (response.statusCode != 200) return null;
      
      final document = parser.parse(response.body);
      final iframe = document.querySelector('div.play-video iframe');
      final src = iframe?.attributes['src'];
      
      if (src != null && src.trim().isNotEmpty) {
        return src.startsWith('//') ? 'https:$src' : src;
      }
      return null;
    } catch (e) {
      print('[GogoScraper] Page fetch error: $e');
      return null;
    }
  }

  /// Extract M3U8 URL from embed page using AJAX decryption
  Future<List<StreamingSource>?> _extractM3U8FromEmbed(String embedUrl) async {
    try {
      print('[GogoScraper] Extracting M3U8 from embed...');
      
      // Fetch embed page
      final response = await http.get(
        Uri.parse(embedUrl),
        headers: {..._headers, 'Referer': _baseUrl},
      );
      
      if (response.statusCode != 200) return null;
      
      // Extract crypto parameters from script
      final html = response.body;
      
      // Look for the data-value attribute which contains encrypted data
      final dataValueMatch = RegExp(r'data-value="([^"]+)"').firstMatch(html);
      if (dataValueMatch == null) {
        print('[GogoScraper] No data-value found, trying alternative extraction...');
        return _extractFromScriptTags(html);
      }
      
      final encryptedData = dataValueMatch.group(1)!;
      print('[GogoScraper] Found encrypted data, decrypting...');
      
      // Decrypt the data
      final decrypted = _aesDecrypt(encryptedData, _encryptionKey, _iv);
      if (decrypted == null) return null;
      
      // Extract ID from decrypted data
      final idMatch = RegExp(r'id=([^&]+)').firstMatch(decrypted);
      if (idMatch == null) return null;
      
      final videoId = idMatch.group(1)!;
      
      // Make AJAX request to get sources
      final ajaxResponse = await _fetchAjaxSources(videoId, embedUrl);
      return ajaxResponse;
      
    } catch (e) {
      print('[GogoScraper] M3U8 extraction error: $e');
      return null;
    }
  }

  /// Fetch sources from AJAX endpoint
  Future<List<StreamingSource>?> _fetchAjaxSources(String videoId, String referer) async {
    try {
      final encryptedId = _aesEncrypt(videoId, _encryptionKey, _iv);
      if (encryptedId == null) return null;
      
      final ajaxUrl = '$_ajaxUrl/encrypt-ajax.php?id=$encryptedId&alias=$videoId';
      
      print('[GogoScraper] Fetching AJAX: $ajaxUrl');
      
      final response = await http.get(
        Uri.parse(ajaxUrl),
        headers: {
          ..._headers,
          'Referer': referer,
          'X-Requested-With': 'XMLHttpRequest',
        },
      );
      
      if (response.statusCode != 200) return null;
      
      // Response is encrypted JSON
      final encryptedResponse = json.decode(response.body)['data'];
      if (encryptedResponse == null) return null;
      
      final decrypted = _aesDecrypt(encryptedResponse, _decryptionKey, _iv);
      if (decrypted == null) return null;
      
      final sourceData = json.decode(decrypted);
      final sources = <StreamingSource>[];
      
      // Parse source array
      if (sourceData['source'] != null) {
        for (var src in sourceData['source']) {
          sources.add(StreamingSource(
            url: src['file'],
            quality: src['label'] ?? 'auto',
            isM3U8: src['file'].toString().contains('.m3u8'),
          ));
        }
      }
      
      if (sourceData['source_bk'] != null) {
        for (var src in sourceData['source_bk']) {
          sources.add(StreamingSource(
            url: src['file'],
            quality: '${src['label'] ?? 'backup'}',
            isM3U8: src['file'].toString().contains('.m3u8'),
          ));
        }
      }
      
      print('[GogoScraper] Found ${sources.length} sources');
      return sources.isEmpty ? null : sources;
      
    } catch (e) {
      print('[GogoScraper] AJAX fetch error: $e');
      return null;
    }
  }

  /// Alternative extraction from inline scripts
  Future<List<StreamingSource>?> _extractFromScriptTags(String html) async {
    try {
      // Look for file: 'url' pattern in scripts
      final fileMatch = RegExp(r'''file:\s*['"]([^'"]+\.m3u8[^'"]*)['"]''').firstMatch(html);
      if (fileMatch != null) {
        return [StreamingSource(
          url: fileMatch.group(1)!,
          quality: 'auto',
          isM3U8: true,
        )];
      }
      
      // Look for sources array
      final sourcesMatch = RegExp(r'sources:\s*\[([^\]]+)\]').firstMatch(html);
      if (sourcesMatch != null) {
        final sourcesJson = '[${sourcesMatch.group(1)}]';
        // This may need more sophisticated parsing
        print('[GogoScraper] Found sources array, needs parsing');
      }
      
      return null;
    } catch (e) {
      print('[GogoScraper] Script extraction error: $e');
      return null;
    }
  }

  /// AES-128-CBC Encryption
  String? _aesEncrypt(String data, String keyString, String ivString) {
    try {
      final key = encrypt.Key.fromUtf8(keyString);
      final iv = encrypt.IV.fromUtf8(ivString);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final encrypted = encrypter.encrypt(data, iv: iv);
      return encrypted.base64;
    } catch (e) {
      print('[GogoScraper] Encryption error: $e');
      return null;
    }
  }

  /// AES-128-CBC Decryption
  String? _aesDecrypt(String encryptedData, String keyString, String ivString) {
    try {
      final key = encrypt.Key.fromUtf8(keyString);
      final iv = encrypt.IV.fromUtf8(ivString);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt64(encryptedData, iv: iv);
      return decrypted;
    } catch (e) {
      print('[GogoScraper] Decryption error: $e');
      return null;
    }
  }

  /// Convert anime title to URL slug
  String _titleToSlug(String title) {
    return title.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }

  /// Search for anime slug
  Future<String?> _searchForSlug(String keyword) async {
    try {
      final searchUrl = '$_baseUrl/search.html?keyword=${Uri.encodeComponent(keyword)}';
      final response = await http.get(Uri.parse(searchUrl), headers: _headers);
      
      if (response.statusCode != 200) return null;
      
      final document = parser.parse(response.body);
      final items = document.querySelectorAll('ul.items li p.name a');
      
      // Exact match
      for (var item in items) {
        if (item.text.trim().toLowerCase() == keyword.toLowerCase()) {
          final href = item.attributes['href'];
          return href?.split('/').last;
        }
      }
      
      // First result
      if (items.isNotEmpty) {
        final href = items.first.attributes['href'];
        return href?.split('/').last;
      }
      
      return null;
    } catch (e) {
      print('[GogoScraper] Search error: $e');
      return null;
    }
  }
}
