// lib/providers/course_provider.dart
import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../models/enums.dart';
import '../repositories/course_repository.dart';
import '../services/api_exception.dart';

/// State-management layer for the Courses feature.
///
/// Sits between the UI and the [CourseRepository] and is the *only* thing the
/// screen talks to. It owns every piece of UI state — the list, the current
/// [CourseStatus], the search query, the offline flag, per-row delete spinners,
/// and the latest error message — and exposes intention-revealing methods
/// (`load`, `refresh`, `search`, `add/update/deleteCourse`). The widget has
/// zero business logic: it reads state and calls these methods.
///
/// Optimistic updates: for edit and delete the provider mutates its in-memory
/// list *immediately* and notifies listeners, then asks the repository to
/// persist the change. If the repository throws (e.g. offline), it restores the
/// pre-mutation snapshot and reports the error — the UI never freezes waiting
/// on the network.
class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository;

  CourseProvider({CourseRepository? repository})
      : _repository = repository ?? CourseRepository();

  // ─── State ──────────────────────────────────────────────────────────────────
  CourseStatus _status = CourseStatus.initial;
  List<CourseModel> _courses = [];
  String _query = '';
  String? _error;
  bool _isOffline = false;
  DateTime? _lastSync;

  // ids with an in-flight delete (drives the per-row spinner)
  final Set<int> _deletingIds = {};

  // ─── Public getters (read-only views for the UI) ─────────────────────────────
  CourseStatus get status => _status;
  String? get error => _error;
  bool get isOffline => _isOffline;
  DateTime? get lastSync => _lastSync;
  String get query => _query;
  bool isDeleting(int id) => _deletingIds.contains(id);

  /// Total courses held (ignores the active search filter). Used to decide
  /// whether to show the search bar — so it stays visible even when the
  /// current query matches nothing.
  int get totalCount => _courses.length;

  /// The list the UI should render — full list, filtered by the search query.
  List<CourseModel> get courses {
    if (_query.trim().isEmpty) return List.unmodifiable(_courses);
    final q = _query.toLowerCase();
    return List.unmodifiable(
      _courses.where(
        (c) =>
            c.title.toLowerCase().contains(q) ||
            c.body.toLowerCase().contains(q),
      ),
    );
  }

  /// True when a search is active but matched nothing (distinct from the
  /// "no courses at all" empty state).
  bool get isEmptySearchResult =>
      _query.trim().isNotEmpty && courses.isEmpty && _courses.isNotEmpty;

  // ─── Load / Refresh ───────────────────────────────────────────────────────--
  Future<void> load() async {
    _status = CourseStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getCourses();
      _courses = result.courses;
      _isOffline = result.source == DataSource.local;
      _lastSync = result.lastSync;
      _status = _courses.isEmpty ? CourseStatus.empty : CourseStatus.success;
    } on AppException catch (e) {
      _error = e.message;
      _isOffline = e is NetworkException;
      _status = CourseStatus.error;
    } catch (e) {
      _error = 'Something went wrong: $e';
      _status = CourseStatus.error;
    }
    notifyListeners();
  }

  /// Pull-to-refresh. Same as [load] but keeps the current list visible while
  /// refreshing (no full-screen spinner), so the UI doesn't flash empty.
  Future<void> refresh() async {
    try {
      final result = await _repository.getCourses();
      _courses = result.courses;
      _isOffline = result.source == DataSource.local;
      _lastSync = result.lastSync;
      _status = _courses.isEmpty ? CourseStatus.empty : CourseStatus.success;
      _error = null;
    } on AppException catch (e) {
      // On refresh failure keep showing what we have; just flag offline.
      _isOffline = e is NetworkException;
      _error = e.message;
    }
    notifyListeners();
  }

  // ─── Search / Filter ────────────────────────────────────────────────────────
  void search(String query) {
    _query = query;
    notifyListeners();
  }

  void clearSearch() {
    if (_query.isEmpty) return;
    _query = '';
    notifyListeners();
  }

  // ─── Create (non-optimistic: brief submit, then insert real result) ─────────
  /// Returns null on success, or an error message on failure.
  Future<String?> addCourse({
    required String title,
    required String body,
  }) async {
    try {
      final created = await _repository.addCourse(
        title: title,
        body: body,
        current: _courses,
      );
      _courses = [created, ..._courses];
      _isOffline = false;
      _lastSync = await _repository.lastSync();
      _status = CourseStatus.success;
      notifyListeners();
      return null;
    } on AppException catch (e) {
      _isOffline = e is NetworkException;
      notifyListeners();
      return e.message;
    }
  }

  // ─── Update (OPTIMISTIC) ─────────────────────────────────────────────────────
  /// Applies the edit to the UI immediately, then persists. Rolls back on error.
  /// Returns null on success, or an error message on failure.
  Future<String?> updateCourse({
    required int id,
    required String title,
    required String body,
  }) async {
    final index = _courses.indexWhere((c) => c.id == id);
    if (index == -1) return 'Course no longer exists.';

    // 1. snapshot for rollback
    final previous = _courses[index];

    // 2. optimistic UI update
    _courses[index] = previous.copyWith(title: title, body: body);
    notifyListeners();

    // 3. persist
    try {
      await _repository.updateCourse(
        id: id,
        title: title,
        body: body,
        current: _courses,
      );
      _isOffline = false;
      _lastSync = await _repository.lastSync();
      return null;
    } on AppException catch (e) {
      // 4. rollback
      final i = _courses.indexWhere((c) => c.id == id);
      if (i != -1) _courses[i] = previous;
      _isOffline = e is NetworkException;
      notifyListeners();
      return e.message;
    }
  }

  // ─── Delete (OPTIMISTIC) ─────────────────────────────────────────────────────
  /// Removes the row immediately, then persists. Re-inserts it at its original
  /// position on failure. Returns null on success, or an error message.
  Future<String?> deleteCourse(int id) async {
    final index = _courses.indexWhere((c) => c.id == id);
    if (index == -1) return 'Course no longer exists.';

    // 1. snapshot for rollback
    final removed = _courses[index];

    // 2. optimistic removal (+ mark in-flight)
    _courses.removeAt(index);
    _deletingIds.add(id);
    notifyListeners();

    // 3. persist
    try {
      await _repository.deleteCourse(id: id, current: _courses);
      _deletingIds.remove(id);
      _isOffline = false;
      _lastSync = await _repository.lastSync();
      _status = _courses.isEmpty ? CourseStatus.empty : CourseStatus.success;
      notifyListeners();
      return null;
    } on AppException catch (e) {
      // 4. rollback — put it back exactly where it was
      _deletingIds.remove(id);
      final insertAt = index <= _courses.length ? index : _courses.length;
      _courses.insert(insertAt, removed);
      _isOffline = e is NetworkException;
      notifyListeners();
      return e.message;
    }
  }
}
