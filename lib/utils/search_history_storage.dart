import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryStorage {
  static const String _keySearchHistory = 'search_history';

  // Save search history to local storage
  static Future<void> saveSearchHistory(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keySearchHistory, history);
  }

  // Load search history from local storage
  static Future<List<String>> loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySearchHistory) ?? [];
  }

  // Clear search history
  static Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySearchHistory);
  }
}
