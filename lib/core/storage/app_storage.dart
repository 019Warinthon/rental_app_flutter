import 'package:shared_preferences/shared_preferences.dart';

/// Centralized key-value storage using SharedPreferences.
/// Used for non-sensitive data: onboarding flag, favorites, etc.
class AppStorage {
  static const String _keyOnboardingDone = 'onboarding_done';
  static const String _keyFavoriteIds = 'favorite_ids';

  // ─── Onboarding ────────────────────────────────────────────────────────────

  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  static Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
  }

  // ─── Favorites ─────────────────────────────────────────────────────────────

  static Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavoriteIds) ?? [];
  }

  static Future<void> saveFavoriteIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavoriteIds, ids);
  }
}
