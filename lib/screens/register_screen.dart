// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../controllers/auth_controller.dart';
import '../models/enums.dart';
import '../validators/app_validator.dart';
import '../widgets/app_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confCtrl  = TextEditingController();
  Gender? _gender;
  bool _showPass = false, _showConf = false, _submitted = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate() || _gender == null) {
      if (_gender == null) _toast('Please select your gender', isError: true);
      return;
    }
    final auth = context.read<AuthController>();
    final ok = await auth.register(
      fullName: _nameCtrl.text.trim(), email: _emailCtrl.text.trim(),
      password: _passCtrl.text, gender: _gender!,
    );
    if (!mounted) return;
    if (ok) {
      _toast('Account created! Please sign in.', isError: false);
      await Future.delayed(const Duration(milliseconds: 1100));
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      _toast(auth.errorMessage ?? 'Registration failed', isError: true);
    }
  }

  void _toast(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(isError ? Icons.warning_amber_rounded : Icons.check_rounded, color: AppColors.bg, size: 16),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(color: AppColors.bg, fontWeight: FontWeight.w600, fontSize: 13))),
      ]),
      backgroundColor: isError ? AppColors.rose : AppColors.sage,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().state == AuthState.loading;
    return Scaffold(
      body: Stack(children: [
        _GeoBg(),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FadeSlide(child: _header()),
              const SizedBox(height: 32),
              FadeSlide(delay: const Duration(milliseconds: 80), child: Form(
                key: _formKey,
                autovalidateMode: _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const FieldLabel('FULL NAME'),
                  AppField(controller: _nameCtrl, label: 'Full Name', hint: 'Ahmed Ali', prefixIcon: Icons.person_outline_rounded, validator: AppValidator.fullName),
                  const SizedBox(height: 18),
                  const FieldLabel('EMAIL'),
                  AppField(controller: _emailCtrl, label: 'Email', hint: 'you@mail.com', prefixIcon: Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress, validator: AppValidator.email),
                  const SizedBox(height: 18),
                  const FieldLabel('GENDER'),
                  _genderDropdown(),
                  const SizedBox(height: 18),
                  const FieldLabel('PASSWORD'),
                  AppField(
                    controller: _passCtrl, label: 'Password', prefixIcon: Icons.lock_outline_rounded,
                    obscureText: !_showPass, validator: AppValidator.password,
                    suffix: IconButton(onPressed: () => setState(() => _showPass = !_showPass),
                        icon: Icon(_showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18)),
                  ),

                  const SizedBox(height: 18),
                  const FieldLabel('CONFIRM PASSWORD'),
                  AppField(
                    controller: _confCtrl, label: 'Re-type Password', prefixIcon: Icons.lock_outline_rounded,
                    obscureText: !_showConf, validator: (v) => AppValidator.confirmPassword(v, _passCtrl.text),
                    suffix: IconButton(onPressed: () => setState(() => _showConf = !_showConf),
                        icon: Icon(_showConf ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18)),
                  ),
                  const SizedBox(height: 30),
                  PrimaryButton(label: 'CREATE ACCOUNT', isLoading: isLoading, onPressed: isLoading ? null : _submit, icon: Icons.arrow_forward_rounded),
                  const SizedBox(height: 20),
                  _loginLink(),
                ]),
              )),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _header() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 44, height: 44,
      decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.bg, size: 22)),
    const SizedBox(height: 18),
    const Text('Create Account', style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
    const SizedBox(height: 4),
    const Text('Fill in the details below to register', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
  ]);

  Widget _genderDropdown() => DropdownButtonFormField<Gender>(
    value: _gender,
    dropdownColor: AppColors.bgSurface,
    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
    decoration: InputDecoration(
      labelText: 'Select Gender', prefixIcon: const Icon(Icons.wc_rounded, size: 18),
      filled: true, fillColor: AppColors.bgSurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.amber, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.rose)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    items: Gender.values.map((g) => DropdownMenuItem(value: g, child: Text(g.label))).toList(),
    onChanged: (v) => setState(() => _gender = v),
    validator: (_) => _gender == null ? 'Please select your gender' : null,
  );

  Widget _passRules() => ValueListenableBuilder(
    valueListenable: _passCtrl,
    builder: (_, __, ___) {
      final rules = AppValidator.getPasswordRules(_passCtrl.text);
      return Column(children: rules.map((r) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(children: [
          Icon(r.met ? Icons.check_circle_rounded : Icons.circle_outlined, size: 13,
              color: r.met ? AppColors.sage : AppColors.textHint),
          const SizedBox(width: 7),
          Text(r.label, style: TextStyle(fontSize: 12, color: r.met ? AppColors.sage : AppColors.textHint)),
        ]),
      )).toList());
    },
  );

  Widget _loginLink() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
      child: const Text('Sign In', style: TextStyle(color: AppColors.amber, fontSize: 13, fontWeight: FontWeight.w700)),
    ),
  ]);
}

// ── Geometric background decoration ──────────────────────────────────────────
class _GeoBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomPaint(size: MediaQuery.of(context).size, painter: _GeoPainter());
}

class _GeoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.amber.withOpacity(0.04)..style = PaintingStyle.stroke..strokeWidth = 1;
    // top-right corner diamond grid
    for (int i = 0; i < 6; i++) {
      final r = 40.0 + i * 36;
      canvas.drawCircle(Offset(size.width + 10, -10), r, paint);
    }
    // bottom-left accent line cluster
    final lp = Paint()..color = AppColors.amber.withOpacity(0.06)..strokeWidth = 0.8;
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(Offset(0, size.height - 60 + i * 14), Offset(80 - i * 10, size.height), lp);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
