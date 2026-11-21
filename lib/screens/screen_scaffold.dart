import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';

class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions,
    this.floatingActionButton,
    this.showBack = true,
  });

  final String title;
  final Widget body;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: CustomAppBar(
        title: title,
        subtitle: subtitle,
        actions: actions,
        showBack: showBack,
      ),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(16), child: body),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class EmptyHint extends StatelessWidget {
  const EmptyHint({super.key, required this.message, this.icon = Icons.inbox_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 34, color: AppColors.muted),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
