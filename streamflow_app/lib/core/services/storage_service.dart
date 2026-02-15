import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime_models.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('Initialize StorageService via override in main.dart');
});

class StorageService {
  final SharedPreferences _prefs;
  
  static const String _keyList = 'my_list';
  static const String _keyHistory = 'watch_history';
  static const String _keyEpisodeProgress = 'episode_progress';
  static const String _keySearch = 'search_history';

  StorageService(this._prefs);

  /// --- My List Operations ---

  List<Anime> getMyList() {
    final jsonString = _prefs.getString(_keyList);
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((j) => Anime.fromJson(j)).toList();
  }

  Future<void> addToMyList(Anime anime) async {
    final list = getMyList();
    if (!list.any((a) => a.id == anime.id)) {
      list.add(anime);
      await _saveList(list);
    }
  }

  Future<void> removeFromMyList(String animeId) async {
    final list = getMyList();
    list.removeWhere((a) => a.id == animeId);
    await _saveList(list);
  }

  bool isInMyList(String animeId) {
    final list = getMyList();
    return list.any((a) => a.id == animeId);
  }

  Future<void> _saveList(List<Anime> list) async {
    final jsonList = list.map((a) => a.toJson()).toList();
    await _prefs.setString(_keyList, jsonEncode(jsonList));
  }

  /// --- Watch History Operations ---

  Map<String, dynamic> getWatchHistory() {
    final jsonString = _prefs.getString(_keyHistory);
    if (jsonString == null) return {};
    return jsonDecode(jsonString);
  }

  /// Get progress map for all episodes of an anime
  /// Returns: {episodeId: progress (0.0 - 1.0)}
  Map<String, double> getAnimeEpisodesProgress(String animeId) {
    final jsonString = _prefs.getString(_keyEpisodeProgress);
    if (jsonString == null) return {};

    final allHistory = jsonDecode(jsonString) as Map<String, dynamic>;
    final animeHistory = allHistory[animeId] as Map<String, dynamic>? ?? {};
    
    return animeHistory.map((key, value) {
      return MapEntry(key, (value['progress'] as num).toDouble());
    });
  }

  Future<void> saveWatchProgress({
    required String animeId,
    required String episodeId, 
    required int episodeNumber,
    required Duration position,
    required Duration duration,
    required Anime animeData, // To show in continue watching
  }) async {
    final progress = duration.inSeconds > 0 
        ? position.inSeconds / duration.inSeconds 
        : 0.0;
        
    // 1. Update "Continue Watching" (Last Watched)
    final history = getWatchHistory();
    history[animeId] = {
      'anime': animeData.toJson(),
      'episodeId': episodeId,
      'episodeNumber': episodeNumber,
      'position': position.inSeconds,
      'duration': duration.inSeconds,
      'progress': progress,
      'lastWatched': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(_keyHistory, jsonEncode(history));

    // 2. Update Specific Episode Progress
    final epString = _prefs.getString(_keyEpisodeProgress);
    final allEpHistory = epString != null ? jsonDecode(epString) as Map<String, dynamic> : {};
    
    if (!allEpHistory.containsKey(animeId)) {
      allEpHistory[animeId] = {};
    }
    
    allEpHistory[animeId][episodeId] = {
      'progress': progress,
      'lastWatched': DateTime.now().toIso8601String(),
    };
    
    await _prefs.setString(_keyEpisodeProgress, jsonEncode(allEpHistory));
  }
  
  /// --- Search History Operations ---
  
  List<String> getSearchHistory() {
    return _prefs.getStringList(_keySearch) ?? [];
  }
  
  Future<void> addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    final history = getSearchHistory();
    history.remove(query); // Remove duplicates/move to top
    history.insert(0, query);
    if (history.length > 10) history.removeLast(); // Limit to 10
    await _prefs.setStringList(_keySearch, history);
  }
}
