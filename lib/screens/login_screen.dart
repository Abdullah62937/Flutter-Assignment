// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../controllers/auth_controller.dart';
import '../models/enums.dart';
import '../validators/app_validator.dart';
import '../widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _showPass = false, _submitted = false;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final ok = await auth.login(email: _emailCtrl.text.trim(), password: _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.bg, size: 16),
          const SizedBox(width: 10),
          Expanded(child: Text(auth.errorMessage ?? 'Login failed',
              style: const TextStyle(color: AppColors.bg, fontWeight: FontWeight.w600, fontSize: 13))),
        ]),
        backgroundColor: AppColors.rose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isLoading = auth.state == AuthState.loading;
    return Scaffold(
      body: Stack(children: [
        _LoginBg(),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FadeSlide(child: _header()),
              const SizedBox(height: 40),
              FadeSlide(delay: const Duration(milliseconds: 80), child: Form(
                key: _formKey,
                autovalidateMode: _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const FieldLabel('EMAIL'),
                  AppField(controller: _emailCtrl, label: 'Email', hint: 'you@mail.com',
                      prefixIcon: Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress,
                      validator: AppValidator.email),
                  const SizedBox(height: 18),
                  const FieldLabel('PASSWORD'),
                  AppField(
                    controller: _passCtrl, label: 'Password', prefixIcon: Icons.lock_outline_rounded,
                    obscureText: !_showPass,
                    validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                    suffix: IconButton(
                      onPressed: () => setState(() => _showPass = !_showPass),
                      icon: Icon(_showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18)),
                  ),
                  const SizedBox(height: 16),
                  _rememberRow(auth),
                  const SizedBox(height: 32),
                  PrimaryButton(label: 'SIGN IN', isLoading: isLoading, onPressed: isLoading ? null : _submit, icon: Icons.login_rounded),
                  const SizedBox(height: 24),
                  _registerLink(),
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
      decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.2), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.teal.withOpacity(0.4))),
      child: const Icon(Icons.shield_outlined, color: AppColors.teal, size: 22)),
    const SizedBox(height: 18),
    const Text('Welcome Back', style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
    const SizedBox(height: 4),
    const Text('Sign in to continue', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
  ]);

  Widget _rememberRow(AuthController auth) => Row(children: [
    SizedBox(width: 20, height: 20, child: Checkbox(
      value: auth.rememberMe,
      onChanged: (v) => auth.setRememberMe(v ?? false),
    )),
    const SizedBox(width: 10),
    const Text('Remember me', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
  ]);

  Widget _registerLink() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.register),
      child: const Text('Register', style: TextStyle(color: AppColors.amber, fontSize: 13, fontWeight: FontWeight.w700)),
    ),
  ]);
}

class _LoginBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomPaint(size: MediaQuery.of(context).size, painter: _LoginPainter());
}

class _LoginPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppColors.teal.withOpacity(0.04)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(Offset(-20, size.height + 10), 60.0 + i * 44, p);
    }
    final lp = Paint()..color = AppColors.amber.withOpacity(0.05)..strokeWidth = 0.8;
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(Offset(size.width - 80 + i * 16, 0), Offset(size.width, 60 - i * 10), lp);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
