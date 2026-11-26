import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/cloudinary_config.dart';
import '../core/theme/app_colors.dart';
import '../models/app_user.dart';
import '../models/time_slot.dart';
import '../models/tutor_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../routing/app_routes.dart';
import '../services/firestore_service.dart';
import '../widgets/pill_button.dart';
import '../widgets/slot_cell.dart';
import '../widgets/status_badge.dart';
import 'screen_scaffold.dart';

class TutorProfileScreen extends StatefulWidget {
  const TutorProfileScreen({super.key});

  @override
  State<TutorProfileScreen> createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
  TutorProfile? _tutor;
  bool _loading = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is TutorProfile) {
      setState(() {
        _tutor = arguments;
        _loading = false;
      });
      context.read<BookingProvider>().selectTutor(arguments);
      context.read<BookingProvider>().watchTutorSlots(arguments.uid);
    } else if (arguments is String) {
      _load(arguments);
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _load(String uid) async {
    try {
      final TutorProfile? tutor = await context
          .read<FirestoreService>()
          .fetchTutor(uid);
      if (!mounted) return;
      if (tutor != null) {
        context.read<BookingProvider>()
          ..selectTutor(tutor)
          ..watchTutorSlots(uid);
      }
      setState(() {
        _tutor = tutor;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final TutorProfile? tutor = _tutor;
    if (tutor == null) {
      return const ScreenScaffold(
        title: 'Tutor not found',
        body: EmptyHint(message: 'This tutor profile is unavailable.'),
      );
    }

    final List<TimeSlot> slots = context
        .select<BookingProvider, List<TimeSlot>>(
          (BookingProvider p) => p.slots,
        );
    final TimeSlot? selectedSlot = context.select<BookingProvider, TimeSlot?>(
      (BookingProvider provider) => provider.selectedSlot,
    );
    final String? selectedSlotId = selectedSlot?.id;
    final String? error = context.select<BookingProvider, String?>(
      (BookingProvider p) => p.error,
    );
    final DateTime now = DateTime.now();
    final String? uid = context
        .select<AuthProvider, AppUser?>((AuthProvider p) => p.currentUser)
        ?.uid;
    final bool hasOpenSlots = slots.any(
      (TimeSlot s) => !s.isBooked && s.start.isAfter(now),
    );

    return ScreenScaffold(
      title: tutor.displayName,
      subtitle: tutor.headline.isNotEmpty
          ? tutor.headline
          : tutor.subjectsList.join(' · '),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _header(context, tutor),
                  const SizedBox(height: 12),
                  _verificationBadge(tutor),
                  const SizedBox(height: 16),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tutor.bio.isNotEmpty
                              ? tutor.bio
                              : 'No bio added yet.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (tutor.experience.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    _experienceSection(context, tutor),
                  ],
                  if (tutor.education.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    _educationSection(context, tutor),
                  ],
                  if (tutor.certifications.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    _certSection(context, tutor),
                  ],
                  if (tutor.languages.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Languages',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: tutor.languages
                                .map(
                                  (l) => Chip(
                                    label: Text(l),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Availability',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  if (slots.isEmpty)
                    const EmptyHint(message: 'No open slots right now.')
                  else
                    ..._groupedSlots(context, slots, selectedSlotId, uid, now),
                  if (error != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      error,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Policies',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cancellation frees the slot. You can reschedule once per booking.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (hasOpenSlots)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '₱${tutor.hourlyRate.toStringAsFixed(0)}/hour',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: PillButton(
                        label: 'Continue to checkout',
                        onPressed:
                            selectedSlot == null ||
                                selectedSlot.isBooked ||
                                !selectedSlot.start.isAfter(now)
                            ? null
                            : () =>
                                  Navigator.of(context)
                                      .pushNamed(AppRoutes.checkout),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, TutorProfile tutor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.mint,
          child: (tutor.avatarUrl ?? '').isEmpty
              ? Text(
                  tutor.initials,
                  style: const TextStyle(color: AppColors.forest),
                )
              : ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: CloudinaryConfig.avatarUrl(tutor.avatarUrl!),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(strokeWidth: 2),
                    errorWidget: (context, url, error) => Text(tutor.initials),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      tutor.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (tutor.verificationStatus == VerificationStatus.verified)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: StatusBadge(
                        label: 'Reviewed',
                        tone: StatusTone.positive,
                      ),
                    ),
                ],
              ),
              if (tutor.headline.isNotEmpty)
                Text(
                  tutor.headline,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 4),
              Text(
                '★ ${tutor.rating.toStringAsFixed(1)} (${tutor.ratingCount})',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: tutor.subjectsList
                    .map(
                      (s) => Chip(
                        label: Text(s),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 4),
              Text(
                '₱${tutor.hourlyRate.toStringAsFixed(0)}/hour · ${_modeLabel(tutor.teachingMode)} · ${tutor.experienceYears} yrs experience',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _verificationBadge(TutorProfile tutor) {
    if (tutor.verificationStatus == VerificationStatus.pending) {
      return const StatusBadge(label: 'Under review', tone: StatusTone.warning);
    }
    if (tutor.verificationStatus == VerificationStatus.rejected) {
      return const StatusBadge(
        label: 'Not approved',
        tone: StatusTone.negative,
      );
    }
    return const SizedBox.shrink();
  }

  String _modeLabel(String mode) => switch (mode) {
    'in-person' => 'In-person',
    'both' => 'Online & in-person',
    _ => 'Online',
  };

  Widget _experienceSection(BuildContext context, TutorProfile tutor) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Experience', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...tutor.experience.map(
            (e) => _entry(
              context,
              title: e.role,
              subtitle: e.organization,
              trailing: '${e.startYear}-${e.endYear}',
              description: e.description,
            ),
          ),
        ],
      ),
    );
  }

  Widget _educationSection(BuildContext context, TutorProfile tutor) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Education', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...tutor.education.map(
            (e) => _entry(
              context,
              title: e.school,
              subtitle: e.degree,
              trailing: e.year > 0 ? '${e.year}' : '',
              description: '',
            ),
          ),
        ],
      ),
    );
  }

  Widget _certSection(BuildContext context, TutorProfile tutor) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Certifications',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...tutor.certifications.map(
            (c) => _entry(
              context,
              title: c.name,
              subtitle: c.issuer,
              trailing: c.year > 0 ? '${c.year}' : '',
              description: '',
            ),
          ),
        ],
      ),
    );
  }

  Widget _entry(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String trailing,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (trailing.isNotEmpty)
                Text(trailing, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _groupedSlots(
    BuildContext context,
    List<TimeSlot> slots,
    String? selectedSlotId,
    String? uid,
    DateTime now,
  ) {
    final Map<String, List<TimeSlot>> groups = <String, List<TimeSlot>>{};
    final List<TimeSlot> sorted = List<TimeSlot>.from(slots)
      ..sort((a, b) => a.start.compareTo(b.start));
    for (final TimeSlot slot in sorted) {
      final String key = DateFormat('EEE, d MMM').format(slot.start);
      groups.putIfAbsent(key, () => <TimeSlot>[]).add(slot);
    }
    final List<Widget> widgets = <Widget>[];
    for (final MapEntry<String, List<TimeSlot>> entry in groups.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 4),
          child: Text(entry.key, style: Theme.of(context).textTheme.labelLarge),
        ),
      );
      widgets.add(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: entry.value.map((TimeSlot slot) {
            final bool isPast = !slot.start.isAfter(now);
            final SlotCellState state;
            if (slot.isBooked || isPast) {
              state = SlotCellState.taken;
            } else if (slot.id == selectedSlotId) {
              state = SlotCellState.selected;
            } else {
              state = SlotCellState.available;
            }
            final String label = DateFormat('h:mm a').format(slot.start);
            return SizedBox(
              width: 100,
              child: SlotCell(
                label: label,
                state: state,
                onTap: () => _selectSlot(slot),
              ),
            );
          }).toList(),
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }
    return widgets;
  }

  void _selectSlot(TimeSlot slot) {
    context.read<BookingProvider>().selectSlot(slot);
  }
}
