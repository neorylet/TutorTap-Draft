import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../models/app_user.dart';
import '../models/time_slot.dart';
import '../models/tutor_private_profile.dart';
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
  final TextEditingController _headlineController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _meetingRoomController = TextEditingController();

  TutorProfile? _profile;
  TutorPrivateProfile? _privateProfile;
  List<String> _subjects = <String>[];
  List<String> _languages = <String>[];
  String _teachingMode = 'online';
  List<_ExperienceDraft> _experience = <_ExperienceDraft>[];
  List<_EducationDraft> _education = <_EducationDraft>[];
  List<_CertificationDraft> _certifications = <_CertificationDraft>[];
  String? _avatarUrl;
  String _avatarPublicId = '';

  bool _initialized = false;
  bool _loading = true;
  bool _saving = false;
  bool _uploadingAvatar = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final AppUser? user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.displayName;
      _load(user.uid, user.email);
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _subjectController.dispose();
    _languageController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    _meetingRoomController.dispose();
    for (final _ExperienceDraft e in _experience) {
      e.dispose();
    }
    for (final _EducationDraft e in _education) {
      e.dispose();
    }
    for (final _CertificationDraft c in _certifications) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load(String uid, String email) async {
    try {
      final FirestoreService firestore = context.read<FirestoreService>();
      final TutorProfile? profile = await firestore.fetchTutor(uid);
      final TutorPrivateProfile? privateProfile =
          await firestore.fetchTutorPrivate(uid);
      if (!mounted) return;
      if (profile != null) _populate(profile);
      _privateProfile = privateProfile ??
          TutorPrivateProfile(uid: uid, meetingRoomInfo: '', contactEmail: email);
      _meetingRoomController.text = _privateProfile!.meetingRoomInfo;
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

  void _populate(TutorProfile profile) {
    _nameController.text = profile.displayName;
    _headlineController.text = profile.headline;
    _bioController.text = profile.bio;
    _subjects = List<String>.from(profile.subjectsList);
    _languages = List<String>.from(profile.languages);
    _teachingMode = profile.teachingMode.isEmpty ? 'online' : profile.teachingMode;
    _yearsController.text =
        profile.experienceYears > 0 ? profile.experienceYears.toString() : '';
    _rateController.text =
        profile.hourlyRate > 0 ? profile.hourlyRate.toStringAsFixed(0) : '';
    _avatarUrl = profile.avatarUrl;
    _avatarPublicId = profile.avatarPublicId;
    _replaceDrafts(profile);
  }

  void _replaceDrafts(TutorProfile profile) {
    for (final _ExperienceDraft e in _experience) {
      e.dispose();
    }
    for (final _EducationDraft e in _education) {
      e.dispose();
    }
    for (final _CertificationDraft c in _certifications) {
      c.dispose();
    }
    _experience = profile.experience
        .map(_ExperienceDraft.fromModel)
        .toList(growable: true);
    _education = profile.education
        .map(_EducationDraft.fromModel)
        .toList(growable: true);
    _certifications = profile.certifications
        .map(_CertificationDraft.fromModel)
        .toList(growable: true);
  }

  TutorProfile _buildProfile(AppUser user) {
    final TutorProfile base = _profile ??
        TutorProfile(
          uid: user.uid,
          displayName: user.displayName,
          headline: '',
          bio: '',
          subjectsList: const <String>[],
          languages: const <String>[],
          teachingMode: 'online',
          experienceYears: 0,
          experience: const <TutorExperience>[],
          education: const <TutorEducation>[],
          certifications: const <TutorCertification>[],
          hourlyRate: 0,
          rating: 0,
          ratingCount: 0,
          verificationStatus: VerificationStatus.pending,
          slots: const <TimeSlot>[],
        );
    return base.copyWith(
      displayName: _nameController.text.trim(),
      headline: _headlineController.text.trim(),
      bio: _bioController.text.trim(),
      subjectsList: List<String>.from(_subjects),
      languages: List<String>.from(_languages),
      teachingMode: _teachingMode,
      experienceYears: int.tryParse(_yearsController.text.trim()) ?? 0,
      experience: _experience.map((e) => e.toModel()).toList(growable: false),
      education: _education.map((e) => e.toModel()).toList(growable: false),
      certifications:
          _certifications.map((c) => c.toModel()).toList(growable: false),
      hourlyRate: double.tryParse(_rateController.text.trim()) ?? 0,
      avatarUrl: _avatarUrl,
      avatarPublicId: _avatarPublicId,
      updatedAt: DateTime.now(),
    );
  }

  int get _completionPercent {
    int done = 0;
    if ((_avatarUrl ?? '').isNotEmpty) done++;
    if (_headlineController.text.trim().isNotEmpty) done++;
    if (_bioController.text.trim().isNotEmpty) done++;
    if (_subjects.isNotEmpty) done++;
    if ((double.tryParse(_rateController.text.trim()) ?? 0) > 0) done++;
    return (done * 100 / 5).round();
  }

  Future<void> _pickAvatar(AppUser user) async {
    final ClassroomProvider classroom = context.read<ClassroomProvider>();
    final FirestoreService firestore = context.read<FirestoreService>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final PlatformFile? file = await FilePicker.pickFile(type: FileType.image);
    final String? path = file?.path;
    if (file == null || path == null || !mounted) return;
    final int size = (await file.length()) ?? 0;
    if (size > 5 * 1024 * 1024) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Image must be 5 MB or smaller.')),
      );
      return;
    }
    setState(() {
      _uploadingAvatar = true;
      _error = null;
    });
    try {
      final result = await classroom.uploadFile(
        filePath: path,
        purpose: UploadPurpose.avatar,
        ownerId: user.uid,
      );
      if (!mounted) return;
      if (result == null) {
        setState(
          () => _error = classroom.pendingUpload?.error ?? 'Upload failed.',
        );
        return;
      }
      _avatarUrl = result.secureUrl;
      _avatarPublicId = result.publicId;
      final TutorProfile updated = _buildProfile(user);
      await firestore.saveTutorProfile(updated);
      if (!mounted) return;
      setState(() => _profile = updated);
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile photo updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
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
      final FirestoreService firestore = context.read<FirestoreService>();
      final TutorProfile profile = _buildProfile(user);
      final TutorPrivateProfile privateProfile = (_privateProfile ??
              TutorPrivateProfile(
                uid: user.uid,
                meetingRoomInfo: '',
                contactEmail: user.email,
              ))
          .copyWith(
        meetingRoomInfo: _meetingRoomController.text.trim(),
        contactEmail: user.email,
      );
      await firestore.saveTutorProfile(profile);
      await firestore.saveTutorPrivateProfile(privateProfile);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _privateProfile = privateProfile;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submitApplication() async {
    final AppUser? user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final FirestoreService firestore = context.read<FirestoreService>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final TutorProfile profile = _buildProfile(user);
      await firestore.saveTutorProfile(profile);
      await firestore.requestTutorVerification(profile, user.email);
      if (!mounted) return;
      setState(() => _profile = profile);
      messenger.showSnackBar(
        const SnackBar(content: Text('Application submitted for review.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addChip(TextEditingController controller, List<String> target, int max) {
    final String value = controller.text.trim();
    if (value.isEmpty) return;
    if (target.any((s) => s.toLowerCase() == value.toLowerCase())) return;
    if (target.length >= max) return;
    setState(() {
      target.add(value);
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider p) => p.currentUser,
    );
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final TutorProfile? profile = _profile;
    final bool busy = _saving || _uploadingAvatar;
    final String status = profile?.verificationStatus.value ?? 'pending';

    return ScreenScaffold(
      title: 'Profile',
      subtitle: 'Complete your profile to appear in browse.',
      showBack: false,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _completionCard(),
              const SizedBox(height: 14),
              _photoCard(user, busy),
              const SizedBox(height: 14),
              _basicsCard(),
              const SizedBox(height: 14),
              _subjectsLanguagesCard(),
              const SizedBox(height: 14),
              _teachingCard(),
              const SizedBox(height: 14),
              _listSection<TutorExperience, _ExperienceDraft>(
                title: 'Experience',
                items: _experience,
                onAdd: () => setState(() => _experience.add(_ExperienceDraft())),
                builder: (d, i) => _experienceTile(d, i),
              ),
              const SizedBox(height: 14),
              _listSection<TutorEducation, _EducationDraft>(
                title: 'Education',
                items: _education,
                onAdd: () => setState(() => _education.add(_EducationDraft())),
                builder: (d, i) => _educationTile(d, i),
              ),
              const SizedBox(height: 14),
              _listSection<TutorCertification, _CertificationDraft>(
                title: 'Certifications',
                items: _certifications,
                onAdd: () =>
                    setState(() => _certifications.add(_CertificationDraft())),
                builder: (d, i) => _certificationTile(d, i),
              ),
              const SizedBox(height: 14),
              _privateCard(),
              const SizedBox(height: 14),
              PillButton(
                label: _saving ? 'Saving…' : 'Save profile',
                onPressed: busy || user == null ? null : _saveProfile,
              ),
              const SizedBox(height: 14),
              _verificationCard(status, busy, user),
              if (_error != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
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

  Widget _completionCard() {
    final int pct = _completionPercent;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Profile $pct% complete',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: pct / 100),
        ],
      ),
    );
  }

  Widget _photoCard(AppUser? user, bool busy) {
    return SectionCard(
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.mint,
            backgroundImage:
                (_avatarUrl ?? '').isNotEmpty ? NetworkImage(_avatarUrl!) : null,
            child: (_avatarUrl ?? '').isEmpty
                ? const Icon(Icons.person, color: AppColors.forest)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: PillButton(
              label: _uploadingAvatar ? 'Uploading…' : 'Change photo',
              variant: PillButtonVariant.secondary,
              onPressed: busy || user == null ? null : () => _pickAvatar(user),
            ),
          ),
        ],
      ),
    );
  }

  Widget _basicsCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Basic info', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
                labelText: 'Display name', border: OutlineInputBorder()),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter your name.' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _headlineController,
            maxLength: 80,
            decoration: const InputDecoration(
                labelText: 'Headline', border: OutlineInputBorder()),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter a headline.' : null,
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _bioController,
            maxLines: 6,
            maxLength: 2000,
            decoration: const InputDecoration(
              labelText: 'Bio',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subjectsLanguagesCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Subjects & languages',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _subjects
                .map((s) => InputChip(
                      label: Text(s),
                      onDeleted: () => setState(() => _subjects.remove(s)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                      labelText: 'Add subject', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addChip(_subjectController, _subjects, 8),
              ),
            ],
          ),
          FormField<List<String>>(
            initialValue: _subjects,
            validator: (_) =>
                _subjects.isEmpty ? 'Add at least one subject.' : null,
            builder: (state) => state.hasError
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(state.errorText!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12)),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _languages
                .map((s) => InputChip(
                      label: Text(s),
                      onDeleted: () => setState(() => _languages.remove(s)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _languageController,
                  decoration: const InputDecoration(
                      labelText: 'Add language', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addChip(_languageController, _languages, 7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teachingCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Teaching details',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _teachingMode,
            decoration: const InputDecoration(
                labelText: 'Teaching mode', border: OutlineInputBorder()),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'online', child: Text('Online')),
              DropdownMenuItem(value: 'in-person', child: Text('In-person')),
              DropdownMenuItem(value: 'both', child: Text('Both')),
            ],
            onChanged: (v) => setState(() => _teachingMode = v ?? 'online'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _yearsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Years of experience',
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _rateController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Hourly rate (₱)', border: OutlineInputBorder()),
            validator: (v) {
              final double? parsed = double.tryParse((v ?? '').trim());
              if (parsed == null || parsed <= 0 || parsed > 10000) {
                return 'Enter a rate between 1 and 10000.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _listSection<T, D>({
    required String title,
    required List<D> items,
    required VoidCallback onAdd,
    required Widget Function(D, int) builder,
  }) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleMedium)),
              IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
            ],
          ),
          ...items.asMap().entries.map((e) => builder(e.value, e.key)),
        ],
      ),
    );
  }

  Widget _experienceTile(_ExperienceDraft d, int i) {
    return _entryTile(
      onRemove: () => setState(() {
        d.dispose();
        _experience.removeAt(i);
      }),
      children: <Widget>[
        TextFormField(
            controller: d.role,
            decoration: const InputDecoration(labelText: 'Role')),
        TextFormField(
            controller: d.organization,
            decoration: const InputDecoration(labelText: 'Organization')),
        Row(children: <Widget>[
          Expanded(
              child: TextFormField(
                  controller: d.startYear,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Start year'))),
          const SizedBox(width: 8),
          Expanded(
              child: TextFormField(
                  controller: d.endYear,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'End year'))),
        ]),
        TextFormField(
            controller: d.description,
            decoration: const InputDecoration(labelText: 'Description')),
      ],
    );
  }

  Widget _educationTile(_EducationDraft d, int i) {
    return _entryTile(
      onRemove: () => setState(() {
        d.dispose();
        _education.removeAt(i);
      }),
      children: <Widget>[
        TextFormField(
            controller: d.school,
            decoration: const InputDecoration(labelText: 'School')),
        TextFormField(
            controller: d.degree,
            decoration: const InputDecoration(labelText: 'Degree')),
        TextFormField(
            controller: d.year,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Year')),
      ],
    );
  }

  Widget _certificationTile(_CertificationDraft d, int i) {
    return _entryTile(
      onRemove: () => setState(() {
        d.dispose();
        _certifications.removeAt(i);
      }),
      children: <Widget>[
        TextFormField(
            controller: d.name,
            decoration: const InputDecoration(labelText: 'Name')),
        TextFormField(
            controller: d.issuer,
            decoration: const InputDecoration(labelText: 'Issuer')),
        TextFormField(
            controller: d.year,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Year')),
      ],
    );
  }

  Widget _entryTile(
      {required VoidCallback onRemove, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          ...children,
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline),
              label: const Text('Remove'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _privateCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Private details', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _meetingRoomController,
            decoration: const InputDecoration(
              labelText: 'Meeting room link',
              hintText: 'https://...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 6),
          Text('Only you can see this.',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _verificationCard(String status, bool busy, AppUser? user) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[
            Expanded(
                child: Text('Verification status',
                    style: Theme.of(context).textTheme.titleMedium)),
            StatusBadge.fromStatus(status),
          ]),
          const SizedBox(height: 8),
          Text('Identity documents are not collected yet.',
              style: Theme.of(context).textTheme.bodySmall),
          if (status != 'verified') ...<Widget>[
            const SizedBox(height: 12),
            PillButton(
              label: 'Submit tutor application',
              variant: PillButtonVariant.amber,
              onPressed: busy || user == null ? null : _submitApplication,
            ),
          ],
        ],
      ),
    );
  }
}

class _ExperienceDraft {
  _ExperienceDraft({
    String role = '',
    String organization = '',
    String startYear = '',
    String endYear = '',
    String description = '',
  })  : role = TextEditingController(text: role),
        organization = TextEditingController(text: organization),
        startYear = TextEditingController(text: startYear),
        endYear = TextEditingController(text: endYear),
        description = TextEditingController(text: description);

  factory _ExperienceDraft.fromModel(TutorExperience e) => _ExperienceDraft(
        role: e.role,
        organization: e.organization,
        startYear: e.startYear > 0 ? '${e.startYear}' : '',
        endYear: e.endYear > 0 ? '${e.endYear}' : '',
        description: e.description,
      );

  final TextEditingController role;
  final TextEditingController organization;
  final TextEditingController startYear;
  final TextEditingController endYear;
  final TextEditingController description;

  TutorExperience toModel() => TutorExperience(
        role: role.text.trim(),
        organization: organization.text.trim(),
        startYear: int.tryParse(startYear.text.trim()) ?? 0,
        endYear: int.tryParse(endYear.text.trim()) ?? 0,
        description: description.text.trim(),
      );

  void dispose() {
    role.dispose();
    organization.dispose();
    startYear.dispose();
    endYear.dispose();
    description.dispose();
  }
}

class _EducationDraft {
  _EducationDraft({String school = '', String degree = '', String year = ''})
      : school = TextEditingController(text: school),
        degree = TextEditingController(text: degree),
        year = TextEditingController(text: year);

  factory _EducationDraft.fromModel(TutorEducation e) => _EducationDraft(
        school: e.school,
        degree: e.degree,
        year: e.year > 0 ? '${e.year}' : '',
      );

  final TextEditingController school;
  final TextEditingController degree;
  final TextEditingController year;

  TutorEducation toModel() => TutorEducation(
        school: school.text.trim(),
        degree: degree.text.trim(),
        year: int.tryParse(year.text.trim()) ?? 0,
      );

  void dispose() {
    school.dispose();
    degree.dispose();
    year.dispose();
  }
}

class _CertificationDraft {
  _CertificationDraft({String name = '', String issuer = '', String year = ''})
      : name = TextEditingController(text: name),
        issuer = TextEditingController(text: issuer),
        year = TextEditingController(text: year);

  factory _CertificationDraft.fromModel(TutorCertification c) =>
      _CertificationDraft(
        name: c.name,
        issuer: c.issuer,
        year: c.year > 0 ? '${c.year}' : '',
      );

  final TextEditingController name;
  final TextEditingController issuer;
  final TextEditingController year;

  TutorCertification toModel() => TutorCertification(
        name: name.text.trim(),
        issuer: issuer.text.trim(),
        year: int.tryParse(year.text.trim()) ?? 0,
      );

  void dispose() {
    name.dispose();
    issuer.dispose();
    year.dispose();
  }
}
