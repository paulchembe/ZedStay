import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static const int cacheValidityHours = 24;

  static Box get _listingsBox => Hive.box('listings_cache');
  static Box get _settingsBox => Hive.box('app_settings');

  static Future<void> cacheListings(
      String key, List<Map<String, dynamic>> listings) async {
    await _listingsBox.put('listings_$key', listings);
    await _listingsBox.put(
        'timestamp_$key', DateTime.now().millisecondsSinceEpoch);
  }

  static List<Map<String, dynamic>>? getCachedListings(String key) {
    final cached = _listingsBox.get('listings_$key');
    final timestamp = _listingsBox.get('timestamp_$key');

    if (cached == null || timestamp == null) return null;

    final cacheTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp as int);
    final hoursDiff =
        DateTime.now().difference(cacheTime).inHours;

    if (hoursDiff >= cacheValidityHours) return null;

    return List<Map<String, dynamic>>.from(
        (cached as List).map((e) => Map<String, dynamic>.from(e)));
  }

  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  static Future<void> clearCache() async {
    await _listingsBox.clear();
  }
}