import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meme_model.dart';
import '../utils/constants.dart';

class ApiService {
  static Future<List<Meme>> fetchMemes() async {
    List<Meme> allMemes = [];

    print('🔄 Fetching memes from Reddit...');

    try {
      final List<Future<void>> futures = [];
      for (String subreddit in AppConstants.subreddits) {
        futures.add(_fetchFromSubreddit(subreddit, allMemes));
      }
      await Future.wait(futures);

      allMemes.shuffle();
      print('✓ Total memes fetched: ${allMemes.length}');

      if (allMemes.isEmpty) {
        print('⚠️ No memes found, trying fallback...');
        return await _fallbackFetch();
      }

      return allMemes;
    } catch (e) {
      print('✗ Critical error: $e');
      return await _fallbackFetch();
    }
  }

  static Future<void> _fetchFromSubreddit(
      String subreddit, List<Meme> allMemes) async {
    try {
      final url = AppConstants.getRedditUrl(subreddit, limit: 20);
      print('  → Fetching from r/$subreddit');

      final response = await http
          .get(Uri.parse(url), headers: {'User-Agent': 'MemeSwipeApp/1.0'})
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null &&
            data['data'] != null &&
            data['data']['children'] != null) {
          final posts = data['data']['children'] as List;
          int validCount = 0;

          for (var post in posts) {
            try {
              if (post != null && post['data'] != null) {
                final postData = post['data'] as Map<String, dynamic>;

                if (Meme.isValidPost(postData)) {
                  final meme = Meme.fromJson(postData);
                  allMemes.add(meme);
                  validCount++;
                }
              }
            } catch (e) {
              continue;
            }
          }

          print('  ✓ Got $validCount memes from r/$subreddit');
        }
      } else {
        print('  ✗ r/$subreddit returned ${response.statusCode}');
      }
    } catch (e) {
      print('  ✗ Error from r/$subreddit: $e');
    }
  }

  static Future<List<Meme>> _fallbackFetch() async {
    try {
      print('🔄 Trying fallback API...');

      final response = await http
          .get(Uri.parse('https://meme-api.com/gimme/memes/30'))
          .timeout(AppConstants.fallbackApiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data['memes'] != null) {
          final memes = (data['memes'] as List)
              .map((m) => Meme.fromJson(m))
              .toList();

          print('✓ Fallback returned ${memes.length} memes');
          return memes;
        }
      }
    } catch (e) {
      print('✗ Fallback failed: $e');
    }

    return [];
  }
}
