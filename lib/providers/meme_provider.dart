import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/meme_model.dart';
import '../services/api_service.dart';

class MemeProvider extends ChangeNotifier {
  // List can now hold Meme objects and ad placeholders (String)
  List<dynamic> _memes = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  List<dynamic> get memes => _memes;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  List<dynamic> _insertAds(List<Meme> memes) {
    final List<dynamic> itemsWithAds = [];
    for (int i = 0; i < memes.length; i++) {
      itemsWithAds.add(memes[i]);
      // Insert an ad after every 5th meme
      if ((i + 1) % 5 == 0) {
        itemsWithAds.add('ad_placeholder');
      }
    }
    return itemsWithAds;
  }

  // Initial load
  Future<void> loadMemes() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads

    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      // Pehle cache se load karo
      await _loadFromCache();

      // Fir fresh memes fetch karo
      final freshMemes = await ApiService.fetchMemes();

      if (freshMemes.isNotEmpty) {
        _memes = _insertAds(freshMemes);
        await _saveToCache();
      } else if (_memes.isEmpty) {
        // Agar cache bhi empty aur API se bhi nahi mila
        _hasError = true;
        _errorMessage = 'No memes found. Check your internet connection.';
      }
    } catch (e) {
      print('Error loading memes: $e');
      if (_memes.isEmpty) {
        _hasError = true;
        _errorMessage = 'Failed to load memes. Please try again.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cache memes locally (only Meme objects)
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Filter for Meme objects before caching
      final memesJson = _memes
          .whereType<Meme>()
          .take(100)
          .map((m) => m.toJson())
          .toList();
      await prefs.setString('cached_memes', json.encode(memesJson));
      print('✓ Cached ${memesJson.length} memes');
    } catch (e) {
      print('Cache save error: $e');
    }
  }

  // Load from cache
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_memes');

      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> memesJson = json.decode(cachedData);
        final List<Meme> cachedMemes = memesJson
            .map((json) => Meme.fromJson(json))
            .toList();

        if (cachedMemes.isNotEmpty) {
          _memes = _insertAds(cachedMemes);
          print('✓ Loaded and processed ${_memes.length} items from cache');
        }
      }
    } catch (e) {
      print('Cache load error: $e');
      _memes = [];
    }
  }

  // Refresh memes
  Future<void> refresh() async {
    _memes = [];
    await loadMemes();
  }
}