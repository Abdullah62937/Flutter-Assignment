// lib/services/local/course_local_store.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/course_model.dart';

/// Local "database" for courses.
///
/// This is the offline storage layer in our architecture
/// (UI → State → Repository → API Service → **Local Database**).
///
/// We use [SharedPreferences] because the dataset is small and flat
/// (~20 course objects). For "simple cases" like this it's the lightest,
/// zero-native-setup option — no codegen, no migrations. The course list is
/// serialized to a single JSON string under one key; a separate key stores the
/// last successful sync time so the UI can show "cached just now / 5 min ago".
///
/// The store knows nothing about the network or UI — it only reads/writes the
/// cache. Swapping it for Hive or sqflite later means re-implementing this one
/// class; nothing above it changes.
class CourseLocalStore {
  static const String _coursesKey = 'cache_courses_v1';
  static const String _lastSyncKey = 'cache_courses_last_sync_v1';

  /// Persist the full course list, overwriting whatever was cached before.
  /// Also stamps the sync time. Called by the repository after every
  /// successful remote fetch or mutation so the cache mirrors the UI.
  Future<void> saveCourses(List<CourseModel> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = courses.map((c) => c.toJson()).toList();
    await prefs.setString(_coursesKey, jsonEncode(jsonList));
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  /// Read the cached courses. Returns an empty list if nothing is cached yet
  /// or if the stored data is corrupt (defensive — never throws to callers).
  Future<List<CourseModel>> readCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_coursesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupt cache — treat as empty rather than crashing the app.
      return [];
    }
  }

  /// True if we have at least one course cached locally.
  Future<bool> hasCache() async {
    final courses = await readCourses();
    return courses.isNotEmpty;
  }

  /// The timestamp of the last successful sync, or null if never synced.
  Future<DateTime?> lastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastSyncKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Wipe the cache (used on logout, or for a manual "clear offline data").
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_coursesKey);
    await prefs.remove(_lastSyncKey);
  }
}
