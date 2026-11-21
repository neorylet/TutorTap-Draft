import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../routing/app_routes.dart';
import '../widgets/lottie_slot.dart';
import '../widgets/pill_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(),
              const LottieSlot(
                asset: AppConstants.lottieWelcome,
                height: 200,
                caption: 'Learning that fits around you',
              ),
              const SizedBox(height: 28),
              Text(
                'Learn with people who care.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 10),
              Text(
                'Find a verified tutor, book a slot, and keep everything in one calm place.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              PillButton(
                label: 'Get started',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.auth),
              ),
              const SizedBox(height: 10),
              PillButton(
                label: 'Sign in instead',
                variant: PillButtonVariant.secondary,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.auth),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
