// lib/repositories/course_repository.dart
import '../models/course_model.dart';
import '../models/enums.dart';
import '../services/api_exception.dart';
import '../services/connectivity_service.dart';
import '../services/course_service.dart';
import '../services/local/course_local_store.dart';

/// The result of a read, carrying not just the data but *where it came from*
/// and *when it was last synced* — so the UI can show an offline banner.
class CoursesResult {
  final List<CourseModel> courses;
  final DataSource source;
  final DateTime? lastSync;

  const CoursesResult({
    required this.courses,
    required this.source,
    this.lastSync,
  });
}

/// Single source of truth for course data.
///
/// This is the heart of the offline-first design. It is the ONLY layer that
/// knows about all three lower layers (network, cache, connectivity) and it
/// owns the policy for choosing between them:
///
///   getCourses():
///     online?  → fetch from API, refresh the cache, return remote data
///     offline? → return whatever is cached (or error if nothing is cached)
///     API hiccup while "online"? → gracefully fall back to cache
///
///   add/update/delete():
///     call the API, and on success mirror the change into the cache so the
///     local copy never drifts from what the user sees. If the call fails
///     (e.g. offline) the error propagates up so the provider can roll back
///     its optimistic UI update.
///
/// The layers below it (service / local store / connectivity) stay dumb and
/// independently testable; everything above it (provider / UI) talks only to
/// this repository and never to `http` or `SharedPreferences` directly.
class CourseRepository {
  final CourseService _service;
  final CourseLocalStore _local;
  final ConnectivityService _connectivity;

  CourseRepository({
    CourseService? service,
    CourseLocalStore? local,
    ConnectivityService? connectivity,
  })  : _service = service ?? CourseService(),
        _local = local ?? CourseLocalStore(),
        _connectivity = connectivity ?? const ConnectivityService();

  // ─── READ (offline-first) ───────────────────────────────────────────────────
  Future<CoursesResult> getCourses() async {
    final online = await _connectivity.isOnline;

    if (online) {
      try {
        final remote = await _service.fetchCourses();
        await _local.saveCourses(remote); // keep the cache in sync
        return CoursesResult(
          courses: remote,
          source: DataSource.remote,
          lastSync: await _local.lastSync(),
        );
      } on AppException {
        // We believed we were online but the request failed. Rather than
        // showing an error to a user who has perfectly good cached data,
        // serve the cache if we have it; otherwise surface the failure.
        return _cachedOrThrow();
      }
    }

    // Offline path → serve the cache.
    return _cachedOrThrow();
  }

  Future<CoursesResult> _cachedOrThrow() async {
    final cached = await _local.readCourses();
    if (cached.isNotEmpty) {
      return CoursesResult(
        courses: cached,
        source: DataSource.local,
        lastSync: await _local.lastSync(),
      );
    }
    // No network AND no cache — there is genuinely nothing to show.
    throw const NetworkException(
      'You\'re offline and no courses are saved yet. '
      'Connect to the internet to load courses.',
    );
  }

  // ─── CREATE ───────────────────────────────────────────────────────────────--
  /// Calls the API, then mirrors the new course into the cache.
  /// [current] is the list as the UI currently shows it (with the optimistic
  /// item already prepended by the provider) so the cache stays consistent.
  Future<CourseModel> addCourse({
    required String title,
    required String body,
    required List<CourseModel> current,
  }) async {
    // Perform the real network POST (required by the CRUD spec). We ignore the
    // id it echoes back, because JSONPlaceholder returns 101 for *every* create
    // — that would collide on repeated adds. Instead we mint a locally-unique
    // id so list keys and cache identity stay consistent.
    await _service.addCourse(title: title, body: body);
    final nextId =
        current.map((c) => c.id).fold<int>(100, (m, e) => e > m ? e : m) + 1;
    final created = CourseModel(id: nextId, title: title, body: body);
    await _local.saveCourses([created, ...current]);
    return created;
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────--
  Future<CourseModel> updateCourse({
    required int id,
    required String title,
    required String body,
    required List<CourseModel> current,
  }) async {
    final updated =
        await _service.updateCourse(id: id, title: title, body: body);
    final merged = current
        .map((c) => c.id == id ? updated.copyWith(id: id) : c)
        .toList();
    await _local.saveCourses(merged);
    return updated.copyWith(id: id);
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────--
  Future<void> deleteCourse({
    required int id,
    required List<CourseModel> current,
  }) async {
    await _service.deleteCourse(id);
    final remaining = current.where((c) => c.id != id).toList();
    await _local.saveCourses(remaining);
  }

  // ─── Cache helpers exposed to the provider ───────────────────────────────────
  Future<DateTime?> lastSync() => _local.lastSync();
  Future<void> clearCache() => _local.clear();
}
