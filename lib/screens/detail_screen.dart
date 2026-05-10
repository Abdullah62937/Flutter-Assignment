// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/enums.dart';
import '../widgets/app_widgets.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  static const _colors = [AppColors.amber, AppColors.teal, AppColors.rose];
  static const _icons  = [Icons.phone_android_rounded, Icons.build_rounded, Icons.analytics_rounded];

  @override
  Widget build(BuildContext context) {
    final subject = ModalRoute.of(context)!.settings.arguments as Subject;
    final color   = _colors[subject.colorIndex];
    final icon    = _icons[subject.colorIndex];

    return Scaffold(
      body: CustomScrollView(slivers: [
        _buildAppBar(context, subject, color, icon),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          sliver: SliverList(delegate: SliverChildListDelegate([
            FadeSlide(child: _badges(subject, color)),
            const SizedBox(height: 20),
            FadeSlide(delay: const Duration(milliseconds: 70), child: _statsRow(subject)),
            const SizedBox(height: 20),
            FadeSlide(delay: const Duration(milliseconds: 130), child: _section('Course Description', Icons.article_outlined, color,
              Text(subject.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.75)))),
            const SizedBox(height: 14),
            FadeSlide(delay: const Duration(milliseconds: 180), child: _section('Class Schedule', Icons.schedule_rounded, color,
              _scheduleBlock(subject.schedule, color))),
            const SizedBox(height: 14),
            FadeSlide(delay: const Duration(milliseconds: 220), child: _section('Instructor', Icons.person_outline_rounded, color,
              _instructorRow(subject))),
            const SizedBox(height: 40),
          ])),
        ),
      ]),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, Subject subject, Color color, IconData icon) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.bg,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border)),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(children: [
          Container(color: AppColors.bg),
          CustomPaint(painter: _DetailBannerPainter(color)),
          Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 40),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.4), width: 1.5),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(subject.title, textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
            ),
          ])),
        ]),
      ),
    );
  }

  Widget _badges(Subject subject, Color color) => Row(children: [
    AmberTag(subject.code, color: color),
    const SizedBox(width: 8),
    AmberTag(subject.credits, color: AppColors.textSecondary),
  ]);

  Widget _statsRow(Subject subject) => Row(children: [
    Expanded(child: _statBox('Days', subject.schedule.split('—')[0].trim().replaceAll(' ', '\n'))),
    const SizedBox(width: 10),
    Expanded(child: _statBox('Time', subject.schedule.contains('—') ? subject.schedule.split('—')[1].trim() : '—')),
    const SizedBox(width: 10),
    Expanded(child: _statBox('Credits', '3 CH')),
  ]);

  Widget _statBox(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700, height: 1.3)),
    ]),
  );

  Widget _section(String title, IconData icon, Color color, Widget body) => WarmCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 14),
      const AppDivider(),
      const SizedBox(height: 14),
      body,
    ]),
  );

  Widget _scheduleBlock(String schedule, Color color) => Row(children: [
    Container(width: 3, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 14),
    Expanded(child: Text(schedule, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600, height: 1.5))),
  ]);

  Widget _instructorRow(Subject subject) => Row(children: [
    InitialsAvatar(
      initials: subject.instructor.split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join(),
      size: 44,
    ),
    const SizedBox(width: 14),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(subject.instructor, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(subject.title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    ]),
  ]);
}

class _DetailBannerPainter extends CustomPainter {
  final Color color;
  _DetailBannerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color.withOpacity(0.06)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (int i = 0; i < 6; i++) {
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 30.0 + i * 28, p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
