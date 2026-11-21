import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/tutor_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/catalog_provider.dart';
import '../routing/app_routes.dart';
import '../widgets/pill_button.dart';
import '../widgets/tutor_card.dart';
import 'screen_scaffold.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    context.read<CatalogProvider>().loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );
    final List<TutorProfile> tutors = context.select<CatalogProvider, List<TutorProfile>>(
      (CatalogProvider provider) => provider.tutors,
    );
    final bool isLoading = context.select<CatalogProvider, bool>(
      (CatalogProvider provider) => provider.isLoading,
    );

    return ScreenScaffold(
      title: 'Hi, ${user?.displayName.split(' ').first ?? 'there'}',
      subtitle: 'Your next breakthrough starts here.',
      showBack: false,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search_outlined),
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.browse),
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Featured tutors', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (isLoading && tutors.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              ...tutors.take(3).map(
                (TutorProfile tutor) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TutorCard(
                    tutor: tutor,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.tutorProfile,
                      arguments: tutor.uid,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            PillButton(
              label: 'Browse all tutors',
              variant: PillButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.browse),
            ),
          ],
        ),
      ),
    );
  }
}
