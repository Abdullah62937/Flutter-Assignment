// lib/screens/courses_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/course_model.dart';
import '../models/enums.dart';
import '../providers/course_provider.dart';
import '../widgets/app_widgets.dart';

/// CRUD screen for Courses — offline-first, backed by [CourseProvider].
///
/// This widget contains **no business logic and no network/cache code**. It
/// reads state from the provider and calls the provider's methods. All
/// loading / success / error / empty handling, optimistic updates, search,
/// and offline detection live in the provider + repository layers below it.
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Kick off the first load once the provider is available in the tree.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  void _toast(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message,
              style: const TextStyle(
                  color: AppColors.bg, fontWeight: FontWeight.w700)),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  // ─── Create ─────────────────────────────────────────────────────────────────
  Future<void> _openAddSheet() async {
    final result = await _showCourseFormSheet(
      title: 'Add Course',
      submitLabel: 'Create Course',
    );
    if (result == null || !mounted) return;

    final provider = context.read<CourseProvider>();
    final error = await provider.addCourse(
      title: result.title,
      body: result.body,
    );
    if (!mounted) return;
    if (error == null) {
      _toast('Course added successfully', AppColors.sage);
    } else {
      _toast(error, AppColors.rose);
    }
  }

  // ─── Update ─────────────────────────────────────────────────────────────────
  Future<void> _openEditSheet(CourseModel course) async {
    final result = await _showCourseFormSheet(
      title: 'Edit Course',
      submitLabel: 'Save Changes',
      initial: course,
    );
    if (result == null || !mounted) return;

    final provider = context.read<CourseProvider>();
    // Optimistic: the list updates instantly inside the provider.
    final error = await provider.updateCourse(
      id: course.id,
      title: result.title,
      body: result.body,
    );
    if (!mounted) return;
    if (error == null) {
      _toast('Course updated successfully', AppColors.sage);
    } else {
      _toast('Update failed — changes reverted. $error', AppColors.rose);
    }
  }

  // ─── Delete ─────────────────────────────────────────────────────────────────
  Future<void> _confirmAndDelete(CourseModel course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Delete course?',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to delete "${course.title}"? '
          'This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: AppColors.rose, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<CourseProvider>();
    // Optimistic: row disappears instantly; re-appears if the request fails.
    final error = await provider.deleteCourse(course.id);
    if (!mounted) return;
    if (error == null) {
      _toast('Course deleted', AppColors.sage);
    } else {
      _toast('Delete failed — course restored. $error', AppColors.rose);
    }
  }

  // ─── Form bottom-sheet for Add + Edit (pre-fills when initial != null) ───────
  Future<_CourseFormResult?> _showCourseFormSheet({
    required String title,
    required String submitLabel,
    CourseModel? initial,
  }) {
    final titleCtrl = TextEditingController(text: initial?.title ?? '');
    final bodyCtrl = TextEditingController(text: initial?.body ?? '');
    final formKey = GlobalKey<FormState>();

    return showModalBottomSheet<_CourseFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: AppColors.border),
              left: BorderSide(color: AppColors.border),
              right: BorderSide(color: AppColors.border),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                AppField(
                  controller: titleCtrl,
                  label: 'Course Title',
                  hint: 'e.g. Advanced Flutter',
                  prefixIcon: Icons.menu_book_rounded,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Title is required';
                    }
                    if (v.trim().length < 3) {
                      return 'Title must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: bodyCtrl,
                  maxLines: 4,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 15),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What is this course about?',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 60),
                      child: Icon(Icons.description_outlined, size: 18),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: submitLabel,
                  icon: Icons.check_rounded,
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.pop(
                        ctx,
                        _CourseFormResult(
                          title: titleCtrl.text.trim(),
                          body: bodyCtrl.text.trim(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final isLoading = provider.status == CourseStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : () => context.read<CourseProvider>().load(),
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textPrimary),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading ? null : _openAddSheet,
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.bg,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Course',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (provider.isOffline) _OfflineBanner(lastSync: provider.lastSync),
            // Show the search bar whenever there's data to search — it stays
            // up even when the current query matches nothing, so the user can
            // always clear it.
            if (provider.totalCount > 0)
              _SearchBar(
                controller: _searchCtrl,
                onChanged: (v) => context.read<CourseProvider>().search(v),
                onClear: () {
                  _searchCtrl.clear();
                  context.read<CourseProvider>().clearSearch();
                },
              ),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(CourseProvider provider) {
    switch (provider.status) {
      case CourseStatus.initial:
      case CourseStatus.loading:
        return const _LoadingView();
      case CourseStatus.error:
        return _ErrorView(
          message: provider.error ?? 'Something went wrong',
          onRetry: () => context.read<CourseProvider>().load(),
        );
      case CourseStatus.empty:
        return _EmptyView(onAdd: _openAddSheet);
      case CourseStatus.success:
        if (provider.isEmptySearchResult) {
          return _NoSearchResults(query: provider.query);
        }
        final list = provider.courses;
        return RefreshIndicator(
          color: AppColors.amber,
          backgroundColor: AppColors.bgCard,
          onRefresh: () => context.read<CourseProvider>().refresh(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final c = list[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CourseCard(
                  course: c,
                  isDeleting: provider.isDeleting(c.id),
                  onEdit: () => _openEditSheet(c),
                  onDelete: () => _confirmAndDelete(c),
                ),
              );
            },
          ),
        );
    }
  }
}

class _CourseFormResult {
  final String title;
  final String body;
  const _CourseFormResult({required this.title, required this.body});
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  final DateTime? lastSync;
  const _OfflineBanner({this.lastSync});

  String _relative(DateTime? t) {
    if (t == null) return 'never';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.amber.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded,
              color: AppColors.amber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Offline — showing saved courses (synced ${_relative(lastSync)})',
              style: const TextStyle(
                color: AppColors.amberLight,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search courses…',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: onClear,
                ),
          isDense: true,
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CourseCard({
    required this.course,
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                ),
                child: Text(
                  '#${course.id}',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              if (isDeleting)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: AppColors.rose,
                    strokeWidth: 2,
                  ),
                )
              else ...[
                _IconBtn(
                  icon: Icons.edit_rounded,
                  color: AppColors.teal,
                  onTap: onEdit,
                ),
                const SizedBox(width: 6),
                _IconBtn(
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.rose,
                  onTap: onDelete,
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            course.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            course.body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppColors.amber,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading courses...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.rose.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.rose.withOpacity(0.3)),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: AppColors.rose, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load courses',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: PrimaryButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.amber.withOpacity(0.3)),
              ),
              child: const Icon(Icons.inbox_rounded,
                  color: AppColors.amber, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              'No courses yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap "Add Course" to create one.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 180,
              child: PrimaryButton(
                label: 'Add Course',
                icon: Icons.add_rounded,
                onPressed: onAdd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  final String query;
  const _NoSearchResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.teal.withOpacity(0.3)),
              ),
              child: const Icon(Icons.search_off_rounded,
                  color: AppColors.teal, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              'No matches',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Nothing found for "$query".',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
