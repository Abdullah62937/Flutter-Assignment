// test/course_provider_test.dart
//
// Unit tests for the state-management + repository layering. Because the UI
// only ever talks to CourseProvider, and the provider only talks to
// CourseRepository, we can verify all the important behaviour (loading,
// offline fallback, optimistic update + rollback, search) by injecting a fake
// repository — no widgets, no real network, no SharedPreferences needed.
// This is the practical pay-off of the clean architecture.

import 'package:flutter_test/flutter_test.dart';
import 'package:assi/models/course_model.dart';
import 'package:assi/models/enums.dart';
import 'package:assi/repositories/course_repository.dart';
import 'package:assi/providers/course_provider.dart';
import 'package:assi/services/api_exception.dart';

/// A controllable stand-in for the real repository.
class FakeCourseRepository extends CourseRepository {
  List<CourseModel> seed;
  DataSource source;
  bool throwNetworkOnMutate;

  FakeCourseRepository({
    required this.seed,
    this.source = DataSource.remote,
    this.throwNetworkOnMutate = false,
  });

  @override
  Future<CoursesResult> getCourses() async {
    return CoursesResult(
      courses: List.of(seed),
      source: source,
      lastSync: DateTime.now(),
    );
  }

  @override
  Future<CourseModel> addCourse({
    required String title,
    required String body,
    required List<CourseModel> current,
  }) async {
    if (throwNetworkOnMutate) throw const NetworkException();
    return CourseModel(id: 999, title: title, body: body);
  }

  @override
  Future<CourseModel> updateCourse({
    required int id,
    required String title,
    required String body,
    required List<CourseModel> current,
  }) async {
    if (throwNetworkOnMutate) throw const NetworkException();
    return CourseModel(id: id, title: title, body: body);
  }

  @override
  Future<void> deleteCourse({
    required int id,
    required List<CourseModel> current,
  }) async {
    if (throwNetworkOnMutate) throw const NetworkException();
  }

  @override
  Future<DateTime?> lastSync() async => DateTime.now();
}

void main() {
  const sample = [
    CourseModel(id: 1, title: 'Flutter', body: 'Cross-platform apps'),
    CourseModel(id: 2, title: 'Databases', body: 'SQL and normalization'),
  ];

  test('load() moves to success and exposes the courses', () async {
    final provider =
        CourseProvider(repository: FakeCourseRepository(seed: sample));
    await provider.load();

    expect(provider.status, CourseStatus.success);
    expect(provider.courses.length, 2);
    expect(provider.isOffline, isFalse);
  });

  test('local source flips the offline flag', () async {
    final provider = CourseProvider(
      repository:
          FakeCourseRepository(seed: sample, source: DataSource.local),
    );
    await provider.load();

    expect(provider.isOffline, isTrue);
    expect(provider.courses.length, 2);
  });

  test('search filters by title and body, case-insensitively', () async {
    final provider =
        CourseProvider(repository: FakeCourseRepository(seed: sample));
    await provider.load();

    provider.search('flut');
    expect(provider.courses.length, 1);
    expect(provider.courses.first.id, 1);

    provider.search('SQL');
    expect(provider.courses.length, 1);
    expect(provider.courses.first.id, 2);

    provider.clearSearch();
    expect(provider.courses.length, 2);
  });

  test('optimistic delete removes the row immediately and keeps it removed '
      'on success', () async {
    final provider =
        CourseProvider(repository: FakeCourseRepository(seed: sample));
    await provider.load();

    final error = await provider.deleteCourse(1);
    expect(error, isNull);
    expect(provider.courses.any((c) => c.id == 1), isFalse);
    expect(provider.courses.length, 1);
  });

  test('failed delete rolls back and restores the row at its position',
      () async {
    final provider = CourseProvider(
      repository:
          FakeCourseRepository(seed: sample, throwNetworkOnMutate: true),
    );
    await provider.load();

    final error = await provider.deleteCourse(1);
    expect(error, isNotNull); // surfaced to the UI for a toast
    expect(provider.courses.length, 2); // rolled back
    expect(provider.courses.first.id, 1); // back in original slot
    expect(provider.isOffline, isTrue);
  });

  test('failed update reverts the edited fields', () async {
    final provider = CourseProvider(
      repository:
          FakeCourseRepository(seed: sample, throwNetworkOnMutate: true),
    );
    await provider.load();

    final error =
        await provider.updateCourse(id: 1, title: 'CHANGED', body: 'CHANGED');
    expect(error, isNotNull);
    final reverted = provider.courses.firstWhere((c) => c.id == 1);
    expect(reverted.title, 'Flutter'); // original restored
  });
}
