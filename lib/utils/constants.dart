import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color backgroundColor = Color(0xFF000000);
  static const Color cardColor = Color(0xFF1A1A1A);
  static const Color textColor = Color(0xFFFFFFFF);

  // API URLs
  static const List<String> subreddits = [
    'memes',
    'dankmemes',
    'wholesomememes',
    'me_irl',
  ];

  static String getRedditUrl(String subreddit, {int limit = 50}) {
    return 'https://www.reddit.com/r/$subreddit/top.json?t=day&limit=$limit';
  }

  // App Config
  static const int memesPerLoad = 50;
  static const int adsAfterMemes = 5; // ← Har 5 memes pe ad
  static const Duration apiTimeout = Duration(seconds: 15);
  static const Duration fallbackApiTimeout = Duration(seconds: 10);
}
