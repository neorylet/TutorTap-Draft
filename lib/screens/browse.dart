import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tutor_profile.dart';
import '../providers/catalog_provider.dart';
import '../routing/app_routes.dart';
import '../widgets/filter_chip_pill.dart';
import '../widgets/tutor_card.dart';
import 'screen_scaffold.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    context.read<CatalogProvider>().loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    final CatalogProvider catalog = context.watch<CatalogProvider>();
    final List<String> subjects = catalog.availableSubjects.take(8).toList();

    return ScreenScaffold(
      title: 'Find a tutor',
      subtitle: 'Verified people, clear rates, online sessions.',
      showBack: false,
      body: Column(
        children: <Widget>[
          TextField(
            controller: _searchController,
            onChanged: catalog.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search name or subject',
              prefixIcon: const Icon(Icons.search_outlined),
              suffixIcon: catalog.searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        catalog.setSearchQuery('');
                      },
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                for (final String subject in subjects)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChipPill(
                      label: subject,
                      selected: catalog.selectedSubjects.contains(subject),
                      onTap: () => catalog.toggleSubject(subject),
                    ),
                  ),
                FilterChipPill(
                  label: 'Available now',
                  icon: Icons.schedule_outlined,
                  selected: catalog.availableOnly,
                  onTap: () =>
                      catalog.setAvailableOnly(!catalog.availableOnly),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${catalog.tutors.length} tutor${catalog.tutors.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              IconButton(
                icon: Icon(
                  catalog.isGridView
                      ? Icons.list_rounded
                      : Icons.grid_view_rounded,
                ),
                onPressed: catalog.toggleViewMode,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: catalog.isLoading && catalog.tutors.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : catalog.tutors.isEmpty
                    ? const Center(child: Text('No tutors match those filters.'))
                    : catalog.isGridView
                        ? GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: catalog.tutors.length,
                            itemBuilder: (BuildContext context, int index) {
                              final TutorProfile tutor = catalog.tutors[index];
                              return TutorCard(
                                tutor: tutor,
                                grid: true,
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.tutorProfile,
                                  arguments: tutor.uid,
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount: catalog.tutors.length,
                            itemBuilder: (BuildContext context, int index) {
                              final TutorProfile tutor = catalog.tutors[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: TutorCard(
                                  tutor: tutor,
                                  onTap: () => Navigator.of(context).pushNamed(
                                    AppRoutes.tutorProfile,
                                    arguments: tutor.uid,
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          if (catalog.hasMore)
            TextButton(
              onPressed: catalog.isLoading ? null : catalog.loadMore,
              child: const Text('Load more tutors'),
            ),
        ],
      ),
    );
  }
}
