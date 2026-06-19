// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../controllers/auth_controller.dart';
import '../models/enums.dart';
import '../widgets/app_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _colors = [AppColors.amber, AppColors.teal, AppColors.rose];
  static const _icons = [
    Icons.phone_android_rounded,
    Icons.build_rounded,
    Icons.analytics_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;

    return Scaffold(
      body: Stack(children: [
        _DashBg(),
        SafeArea(
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeSlide(child: _topBar(context, auth)),
                    const SizedBox(height: 28),
                    FadeSlide(
                      delay: const Duration(milliseconds: 60),
                      child: _profileCard(
                        user?.fullName ?? 'Student',
                        user?.initials ?? 'U',
                        user?.email ?? '',
                      ),
                    ),
                    const SizedBox(height: 22),
                    // ── Manage Courses entry (opens CRUD screen) ──────────
                    FadeSlide(
                      delay: const Duration(milliseconds: 90),
                      child: _manageCoursesBanner(context),
                    ),
                    const SizedBox(height: 28),
                    FadeSlide(
                      delay: const Duration(milliseconds: 120),
                      child: Row(children: [
                        const Expanded(
                          child: Text(
                            'MY SUBJECTS',
                            style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                        AmberTag('${Subject.values.length} enrolled'),
                      ]),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final s = Subject.values[i];
                    return FadeSlide(
                      delay: Duration(milliseconds: 160 + i * 70),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SubjectTile(
                          subject: s,
                          color: _colors[i],
                          icon: _icons[i],
                          onTap: () => Navigator.pushNamed(
                              ctx, AppRoutes.detail,
                              arguments: s),
                        ),
                      ),
                    );
                  },
                  childCount: Subject.values.length,
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _topBar(BuildContext context, AuthController auth) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          GestureDetector(
            onTap: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.rose.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.rose.withOpacity(0.25)),
              ),
              child: const Row(children: [
                Icon(Icons.logout_rounded,
                    color: AppColors.rose, size: 14),
                SizedBox(width: 5),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.rose,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]),
            ),
          ),
        ],
      );

  Widget _profileCard(String name, String initials, String email) =>
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          InitialsAvatar(initials: initials, size: 56),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${name.split(' ').first}!',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                AmberTag('Semester Active', color: AppColors.sage),
              ],
            ),
          ),
        ]),
      );

  // ── New banner that opens the CRUD courses screen ───────────────────────────
  Widget _manageCoursesBanner(BuildContext context) => GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.courses),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.amber.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.amber.withOpacity(0.3)),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.amber.withOpacity(0.35)),
              ),
              child: const Icon(Icons.cloud_sync_rounded,
                  color: AppColors.amber, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Courses',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'View, add, edit & delete courses via API',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.amber, size: 22),
          ]),
        ),
      );
}

// ── Subject tile ──────────────────────────────────────────────────────────────
class _SubjectTile extends StatefulWidget {
  final Subject subject;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _SubjectTile({
    required this.subject,
    required this.color,
    required this.icon,
    required this.onTap,
  });
  @override
  State<_SubjectTile> createState() => _SubjectTileState();
}

class _SubjectTileState extends State<_SubjectTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 110),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: widget.color.withOpacity(0.3)),
                ),
                child:
                    Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.subject.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.schedule_outlined,
                          size: 11, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.subject.schedule,
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint, size: 18),
            ]),
          ),
        ),
      );
}

class _DashBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: MediaQuery.of(context).size, painter: _DashPainter());
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.amber.withOpacity(0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(0, 0),
        Offset(size.width * 0.4, size.height * 0.3), p);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width * 0.6, size.height * 0.7), p);
    final p2 = Paint()
      ..color = AppColors.teal.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(size.width + 20, size.height * 0.5),
        50.0 + i * 40,
        p2,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}