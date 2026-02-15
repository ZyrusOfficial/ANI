import 'lib/core/api/jikan_api.dart';
import 'lib/core/api/hianime_api.dart';
import 'lib/core/api/gogo_scraper.dart';

void main() async {
  print('=== COMPREHENSIVE API DEBUG ===\n');
  
  // Test 1: Jikan API
  print('--- 1. Testing Jikan API (Metadata) ---');
  final jikan = JikanApiService();
  
  try {
    final trending = await jikan.getTrending();
    print('✓ Trending: ${trending.length} results');
    if (trending.isNotEmpty) {
      print('  First: ${trending.first.title} (ID: ${trending.first.id})');
    }
    
    final popular = await jikan.getPopular();
    print('✓ Popular: ${popular.length} results');
    
    final search = await jikan.search('Naruto');
    print('✓ Search "Naruto": ${search.length} results');
  } catch (e) {
    print('✗ Jikan Error: $e');
  }
  
  // Test 2: HiAnime API (Primary Streaming)
  print('\n--- 2. Testing HiAnime API (Streaming) ---');
  final hiAnime = HiAnimeApiService();
  
  final testCases = [
    ('Naruto', 1),
    ('One Piece', 1),
    ('Demon Slayer', 1),
  ];
  
  for (var (title, ep) in testCases) {
    print('\nTesting: $title Episode $ep');
    try {
      final sources = await hiAnime.getSourcesByTitle(title, ep);
      if (sources != null && sources.sources.isNotEmpty) {
        print('✓ Found ${sources.sources.length} source(s):');
        for (var s in sources.sources) {
          final urlPreview = s.url.length > 60 ? s.url.substring(0, 60) : s.url;
          print('  - [${s.quality}] $urlPreview...');
          print('    M3U8: ${s.isM3U8}');
        }
        if (sources.subtitles.isNotEmpty) {
          print('  Subtitles: ${sources.subtitles.length} tracks');
        }
      } else {
        print('✗ No sources found');
      }
    } catch (e) {
      print('✗ Error: $e');
    }
  }
  
  // Test 3: GogoScraper (Fallback - expected to fail without JS)
  print('\n--- 3. Testing GogoScraper (Fallback) ---');
  final gogo = GogoScraperService();
  
  try {
    final sources = await gogo.getStreamingSources('Naruto', 1);
    if (sources != null && sources.sources.isNotEmpty) {
      print('✓ Gogo found sources (unexpected success!)');
    } else {
      print('⚠ Gogo returned no sources (expected - JS required)');
    }
  } catch (e) {
    print('⚠ Gogo error (expected): $e');
  }
  
  print('\n=== DEBUG COMPLETE ===');
}
