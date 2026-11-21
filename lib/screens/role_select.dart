import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../widgets/pill_button.dart';
import 'screen_scaffold.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.select<AuthProvider, bool>(
      (AuthProvider provider) => provider.isLoading,
    );
    final String? error = context.select<AuthProvider, String?>(
      (AuthProvider provider) => provider.error,
    );

    return ScreenScaffold(
      title: 'How will you use TutorTap?',
      subtitle: 'You can switch later from your profile.',
      showBack: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _RoleCard(
            icon: Icons.school_outlined,
            title: 'I am a student',
            description: 'Browse tutors, book sessions, and study.',
            enabled: !isLoading,
            onTap: () => _select(context, UserRole.student),
          ),
          const SizedBox(height: 12),
          _RoleCard(
            icon: Icons.present_to_all_outlined,
            title: 'I am a tutor',
            description: 'Offer sessions, manage students, and track earnings.',
            enabled: !isLoading,
            onTap: () => _select(context, UserRole.tutor),
          ),
          if (error != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.brick,
              ),
            ),
          ],
          const Spacer(),
          PillButton(
            label: 'Sign out',
            variant: PillButtonVariant.text,
            onPressed: isLoading
                ? null
                : () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
    );
  }

  Future<void> _select(BuildContext context, UserRole role) async {
    await context.read<AuthProvider>().selectRole(role);
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: SectionCard(
        child: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.emerald,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
