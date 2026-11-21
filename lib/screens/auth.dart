import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_form_field.dart';
import '../widgets/pill_button.dart';
import '../widgets/segmented_control.dart';
import 'screen_scaffold.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _registering = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.select<AuthProvider, bool>(
      (AuthProvider provider) => provider.isLoading,
    );

    return ScreenScaffold(
      title: _registering ? 'Create account' : 'Welcome back',
      subtitle: _registering
          ? 'One account, one place for tutoring.'
          : 'Sign in to continue to TutorTap.',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SegmentedControl<bool>(
              values: const <bool>[false, true],
              value: _registering,
              onChanged: (bool value) => setState(() => _registering = value),
              labelBuilder: (bool value) => value ? 'Register' : 'Sign in',
            ),
            const SizedBox(height: 20),
            SectionCard(
              child: Column(
                children: <Widget>[
                  AppFormField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline,
                  ),
                  const SizedBox(height: 14),
                  AppFormField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'At least 6 characters',
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.lock_outline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PillButton(
              label: _registering ? 'Create account' : 'Sign in',
              onPressed: isLoading ? null : _submit,
            ),
            const SizedBox(height: 10),
            PillButton(
              label: 'Continue with Google',
              variant: PillButtonVariant.secondary,
              icon: Icons.g_mobiledata,
              onPressed: isLoading ? null : _signInWithGoogle,
            ),
            const SizedBox(height: 12),
            Text(
              'Payments are simulated in this build.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _show('Enter an email and password.');
      return;
    }
    final AuthProvider auth = context.read<AuthProvider>();
    if (_registering) {
      await auth.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
    _showErrorIfNeeded(auth.error);
  }

  Future<void> _signInWithGoogle() async {
    final AuthProvider auth = context.read<AuthProvider>();
    await auth.signInWithGoogle();
    _showErrorIfNeeded(auth.error);
  }

  void _showErrorIfNeeded(String? error) {
    if (!mounted || error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
