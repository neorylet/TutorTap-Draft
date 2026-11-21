import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/time_slot.dart';
import '../models/tutor_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/pill_button.dart';
import '../widgets/status_badge.dart';
import 'screen_scaffold.dart';

class TutorProfileVerificationScreen extends StatefulWidget {
  const TutorProfileVerificationScreen({super.key});

  @override
  State<TutorProfileVerificationScreen> createState() =>
      _TutorProfileVerificationScreenState();
}

class _TutorProfileVerificationScreenState
    extends State<TutorProfileVerificationScreen> {
  TutorProfile? _profile;
  bool _initialized = false;
  bool _uploading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final String? uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) _load(uid);
  }

  Future<void> _load(String uid) async {
    try {
      final TutorProfile? profile = await context
          .read<FirestoreService>()
          .fetchTutor(uid);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );
    final TutorProfile? profile = _profile;
    final PendingUpload? pending = context
        .select<ClassroomProvider, PendingUpload?>(
          (ClassroomProvider provider) => provider.pendingUpload,
        );

    return ScreenScaffold(
      title: 'Profile & verification',
      subtitle: 'Tutor verification is required before appearing in browse.',
      showBack: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user?.displayName ?? 'Tutor',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Text(
                        'Status: ',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      StatusBadge.fromStatus(
                        profile?.verificationStatus.value ?? 'pending',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${profile?.credentialUrls.length ?? 0} credential(s) uploaded',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PillButton(
              label: _uploading ? 'Saving…' : 'Upload profile photo (bypass)',
              variant: PillButtonVariant.secondary,
              onPressed: _uploading || user == null
                  ? null
                  : () => _pick(user.uid, UploadPurpose.avatar),
            ),
            const SizedBox(height: 8),
            PillButton(
              label: _uploading ? 'Saving…' : 'Upload credential (bypass)',
              variant: PillButtonVariant.secondary,
              onPressed: _uploading || user == null
                  ? null
                  : () => _pick(user.uid, UploadPurpose.credential),
            ),
            if (pending != null && pending.error != null) ...<Widget>[
              const SizedBox(height: 10),
              PillButton(
                label: 'Retry upload',
                variant: PillButtonVariant.amber,
                onPressed: _uploading ? null : _retry,
              ),
            ],
            if (_error != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
              onPressed: () => context.read<AuthProvider>().signOut(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(String ownerId, UploadPurpose purpose) async {
    final FirestoreService firestore = context.read<FirestoreService>();
    final AppUser? user = context.read<AuthProvider>().currentUser;
    setState(() {
      _uploading = true;
      _error = null;
    });

    try {
      // TEMP BYPASS: Generates placeholder URLs without FilePicker or Cloudinary.
      final String placeholderUrl = purpose == UploadPurpose.avatar
          ? 'https://example.com/temp-avatar-$ownerId.png'
          : 'https://example.com/temp-credential-$ownerId-${DateTime.now().millisecondsSinceEpoch}.pdf';

      final TutorProfile baseProfile =
          _profile ??
          TutorProfile(
            uid: ownerId,
            displayName: user?.displayName ?? 'Tutor',
            bio: '',
            subjects: const <String>[],
            hourlyRate: 0,
            meetingRoomInfo: '',
            avatarUrl: null,
            credentialUrls: const <String>[],
            slots: const <TimeSlot>[],
            verificationStatus: VerificationStatus.pending,
            rating: 0,
            ratingCount: 0,
          );

      final TutorProfile updated = purpose == UploadPurpose.avatar
          ? baseProfile.copyWith(avatarUrl: placeholderUrl)
          : baseProfile.copyWith(
              credentialUrls: <String>[
                ...baseProfile.credentialUrls,
                placeholderUrl,
              ],
            );

      await firestore.saveTutorProfile(updated);
      if (!mounted) return;
      setState(() => _profile = updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _retry() async {
    final AppUser? user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    await _pick(user.uid, UploadPurpose.credential);
  }
}
