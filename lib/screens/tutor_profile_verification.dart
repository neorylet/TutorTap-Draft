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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _subjectsController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _meetingRoomController = TextEditingController();

  TutorProfile? _profile;
  bool _initialized = false;
  bool _loading = true;
  bool _editingProfile = false;
  bool _saving = false;
  bool _uploading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final AppUser? user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.displayName;
      _load(user.uid);
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _subjectsController.dispose();
    _rateController.dispose();
    _meetingRoomController.dispose();
    super.dispose();
  }

  Future<void> _load(String uid) async {
    try {
      final TutorProfile? profile = await context
          .read<FirestoreService>()
          .fetchTutor(uid);
      if (!mounted) return;
      if (profile != null) {
        _populateFields(profile);
      }
      setState(() {
        _profile = profile;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _populateFields(TutorProfile profile) {
    _nameController.text = profile.displayName;
    _bioController.text = profile.bio;
    _subjectsController.text = profile.subjects.join(', ');
    _rateController.text = profile.hourlyRate > 0
        ? profile.hourlyRate.toStringAsFixed(0)
        : '';
    _meetingRoomController.text = profile.meetingRoomInfo;
  }

  void _startEditing(AppUser user) {
    if (_profile != null) {
      _populateFields(_profile!);
    } else {
      _nameController.text = user.displayName;
    }
    setState(() {
      _editingProfile = true;
      _error = null;
    });
  }

  void _cancelEditing() {
    if (_profile != null) {
      _populateFields(_profile!);
    }
    setState(() {
      _editingProfile = false;
      _error = null;
    });
  }

  TutorProfile _buildDraftProfile(AppUser user) {
    final List<String> subjects = _subjectsController.text
        .split(',')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
    final double rate = double.tryParse(_rateController.text.trim()) ?? 0;
    final String displayName = _nameController.text.trim().isEmpty
        ? user.displayName
        : _nameController.text.trim();

    final TutorProfile base =
        _profile ??
        TutorProfile(
          uid: user.uid,
          displayName: displayName,
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

    return base.copyWith(
      displayName: displayName,
      bio: _bioController.text.trim(),
      subjects: subjects,
      hourlyRate: rate,
      meetingRoomInfo: _meetingRoomController.text.trim(),
    );
  }

  Future<void> _saveProfile() async {
    final AppUser? user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final TutorProfile updated = _buildDraftProfile(user);
      await context.read<FirestoreService>().saveTutorProfile(updated);
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _editingProfile = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Tutor profile saved.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sendTutorApplication(AppUser user) async {
    final TutorProfile draft = _buildDraftProfile(user);

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await context.read<FirestoreService>().requestTutorVerification(
        draft,
        user.email,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tutor application submitted for review.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
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
    final String statusValue = profile?.verificationStatus.value ?? 'pending';
    final bool busy = _saving || _uploading;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String displayName =
        profile?.displayName ?? user?.displayName ?? 'Tutor';
    final String bioText = (profile?.bio.isNotEmpty ?? false)
        ? profile!.bio
        : 'No bio added yet.';
    final String subjectsText = (profile?.subjects.isNotEmpty ?? false)
        ? profile!.subjects.join(' · ')
        : 'No subjects added yet.';
    final String rateText = (profile != null && profile.hourlyRate > 0)
        ? '₱${profile.hourlyRate.toStringAsFixed(0)}/hour'
        : 'Not set';
    final String roomText = (profile?.meetingRoomInfo.isNotEmpty ?? false)
        ? profile!.meetingRoomInfo
        : 'Not set';

    return ScreenScaffold(
      title: 'Profile & verification',
      subtitle: 'Tutor verification is required before appearing in browse.',
      showBack: false,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            displayName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        StatusBadge.fromStatus(statusValue),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${profile?.credentialUrls.length ?? 0} credential(s) uploaded · '
                      '★ ${(profile?.rating ?? 0).toStringAsFixed(1)} (${profile?.ratingCount ?? 0})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Public profile details',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (!_editingProfile)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            tooltip: 'Edit profile details',
                            visualDensity: VisualDensity.compact,
                            onPressed: busy || user == null
                                ? null
                                : () => _startEditing(user),
                          )
                        else
                          TextButton(
                            onPressed: busy ? null : _cancelEditing,
                            child: const Text('Cancel'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (!_editingProfile) ...<Widget>[
                      Text(
                        'Name: $displayName',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Subjects: $subjectsText',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rate: $rateText',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Meeting room: $roomText',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        bioText,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ] else ...<Widget>[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Display name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter your display name.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          hintText: 'Share your teaching experience, background, and style…',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _subjectsController,
                        decoration: const InputDecoration(
                          labelText: 'Subjects (comma-separated)',
                          hintText: 'e.g. Algebra, Calculus, Physics',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _rateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Hourly rate (₱)',
                          hintText: 'e.g. 450',
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final double? parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed < 0) {
                            return 'Enter a valid non-negative rate.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _meetingRoomController,
                        decoration: const InputDecoration(
                          labelText: 'Online meeting room info',
                          hintText:
                              'e.g. Google Meet / Zoom link or instructions',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      PillButton(
                        label: _saving ? 'Saving profile…' : 'Save profile',
                        onPressed: busy || user == null ? null : _saveProfile,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Verification & uploads',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    PillButton(
                      label: _uploading
                          ? 'Saving…'
                          : 'Upload profile photo (bypass)',
                      variant: PillButtonVariant.secondary,
                      onPressed: busy || user == null
                          ? null
                          : () => _pick(user.uid, UploadPurpose.avatar),
                    ),
                    const SizedBox(height: 8),
                    PillButton(
                      label: _uploading
                          ? 'Saving…'
                          : 'Upload credential (bypass)',
                      variant: PillButtonVariant.secondary,
                      onPressed: busy || user == null
                          ? null
                          : () => _pick(user.uid, UploadPurpose.credential),
                    ),
                    if (pending != null && pending.error != null) ...<Widget>[
                      const SizedBox(height: 10),
                      PillButton(
                        label: 'Retry upload',
                        variant: PillButtonVariant.amber,
                        onPressed: busy ? null : _retry,
                      ),
                    ],
                    // Tutor Application Section
                    if (statusValue != 'verified') ...<Widget>[
                      PillButton(
                        label: 'Submit tutor application',
                        variant: PillButtonVariant.amber,
                        onPressed: busy || user == null
                            ? null
                            : () => _sendTutorApplication(user),
                      ),
                    ],
                  ],
                ),
              ),
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
      ),
    );
  }

  Future<void> _pick(String ownerId, UploadPurpose purpose) async {
    final FirestoreService firestore = context.read<FirestoreService>();
    final AppUser? user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() {
      _uploading = true;
      _error = null;
    });

    try {
      // TEMP BYPASS: Generates placeholder URLs without FilePicker or Cloudinary.
      final String placeholderUrl = purpose == UploadPurpose.avatar
          ? 'https://example.com/temp-avatar-$ownerId.png'
          : 'https://example.com/temp-credential-$ownerId-${DateTime.now().millisecondsSinceEpoch}.pdf';

      final TutorProfile baseProfile = _buildDraftProfile(user);

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
