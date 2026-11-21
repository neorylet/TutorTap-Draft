import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../models/tutor_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import '../services/cloudinary_service.dart';
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

class _TutorProfileVerificationScreenState extends State<TutorProfileVerificationScreen> {
  TutorProfile? _profile;
  bool _initialized = false;
  bool _uploading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final String? uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) _load(uid);
  }

  Future<void> _load(String uid) async {
    final TutorProfile? profile =
        await context.read<FirestoreService>().fetchTutor(uid);
    if (!mounted) return;
    setState(() => _profile = profile);
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );
    final TutorProfile? profile = _profile;
    final PendingUpload? pending =
        context.select<ClassroomProvider, PendingUpload?>(
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
              label: _uploading ? 'Uploading…' : 'Upload profile photo',
              variant: PillButtonVariant.secondary,
              onPressed: _uploading || user == null
                  ? null
                  : () => _pick(user.uid, UploadPurpose.avatar),
            ),
            const SizedBox(height: 8),
            PillButton(
              label: _uploading ? 'Uploading…' : 'Upload credential',
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
          ],
        ),
      ),
    );
  }

  Future<void> _pick(String ownerId, UploadPurpose purpose) async {
    final ClassroomProvider classroom = context.read<ClassroomProvider>();
    final FirestoreService firestore = context.read<FirestoreService>();
    final PlatformFile? file = await FilePicker.pickFile();
    final String? path = file?.path;
    if (path == null) return;
    setState(() => _uploading = true);
    final CloudinaryUploadResult? upload = await classroom.uploadFile(
      filePath: path,
      purpose: purpose,
      ownerId: ownerId,
    );
    if (!mounted) return;
    setState(() => _uploading = false);
    if (upload == null || _profile == null) return;
    final TutorProfile updated = purpose == UploadPurpose.avatar
        ? _profile!.copyWith(avatarUrl: upload.secureUrl)
        : _profile!.copyWith(
            credentialUrls: <String>[..._profile!.credentialUrls, upload.secureUrl],
          );
    await firestore.saveTutorProfile(updated);
    if (mounted) setState(() => _profile = updated);
  }

  Future<void> _retry() async {
    final ClassroomProvider classroom = context.read<ClassroomProvider>();
    final FirestoreService firestore = context.read<FirestoreService>();
    setState(() => _uploading = true);
    final CloudinaryUploadResult? upload =
        await classroom.retryPendingUpload();
    if (!mounted) return;
    setState(() => _uploading = false);
    if (upload == null || _profile == null) return;
    final TutorProfile updated = _profile!.copyWith(
      credentialUrls: <String>[..._profile!.credentialUrls, upload.secureUrl],
    );
    await firestore.saveTutorProfile(updated);
    if (mounted) setState(() => _profile = updated);
  }
}
