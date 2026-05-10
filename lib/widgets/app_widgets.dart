// lib/widgets/app_widgets.dart
import 'package:flutter/material.dart';
import '../app_theme.dart';

// ── Amber filled button ──────────────────────────────────────────────────────
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({super.key, required this.label, this.onPressed, this.isLoading = false, this.icon});

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ac.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ac.forward(),
      onTapUp: (_) { _ac.reverse(); widget.onPressed?.call(); },
      onTapCancel: () => _ac.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.amber : AppColors.bgElevated,
            borderRadius: BorderRadius.circular(10),
          ),
          child: widget.isLoading
              ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.bg, strokeWidth: 2.5)))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[Icon(widget.icon, size: 18, color: AppColors.bg), const SizedBox(width: 8)],
                    Text(widget.label, style: const TextStyle(color: AppColors.bg, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Ghost / outlined button ──────────────────────────────────────────────────
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const GhostButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600))),
      ),
    );
  }
}

// ── Themed text field ────────────────────────────────────────────────────────
class AppField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const AppField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: _focused ? [BoxShadow(color: AppColors.amber.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 3))] : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: Icon(widget.prefixIcon, size: 18),
            suffixIcon: widget.suffix,
          ),
        ),
      ),
    );
  }
}

// ── Section micro-label ───────────────────────────────────────────────────────
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
  );
}

// ── Card container ────────────────────────────────────────────────────────────
class WarmCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  const WarmCard({super.key, required this.child, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor ?? AppColors.border),
    ),
    child: child,
  );
}

// ── Fade + slide entrance ─────────────────────────────────────────────────────
class FadeSlide extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const FadeSlide({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<FadeSlide> with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _op;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _op = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));
    Future.delayed(widget.delay, () { if (mounted) _ac.forward(); });
  }

  @override
  void dispose() { _ac.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _op, child: SlideTransition(position: _slide, child: widget.child));
}

// ── Avatar initials circle ────────────────────────────────────────────────────
class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  const InitialsAvatar({super.key, required this.initials, this.size = 56});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.amber.withOpacity(0.15),
      border: Border.all(color: AppColors.amber.withOpacity(0.4), width: 1.5),
    ),
    child: Center(
      child: Text(initials,
          style: TextStyle(color: AppColors.amber, fontWeight: FontWeight.w800, fontSize: size * 0.33)),
    ),
  );
}

// ── Amber tag / chip ──────────────────────────────────────────────────────────
class AmberTag extends StatelessWidget {
  final String label;
  final Color? color;
  const AmberTag(this.label, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
    );
  }
}

// ── Divider with optional label ───────────────────────────────────────────────
class AppDivider extends StatelessWidget {
  final String? label;
  const AppDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    const Expanded(child: Divider(color: AppColors.border, thickness: 0.5)),
    if (label != null) ...[
      const SizedBox(width: 12),
      Text(label!, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
      const SizedBox(width: 12),
      const Expanded(child: Divider(color: AppColors.border, thickness: 0.5)),
    ],
  ]);
}
