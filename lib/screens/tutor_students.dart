import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../providers/auth_provider.dart';
import '../routing/app_routes.dart';
import '../services/firestore_service.dart';
import 'screen_scaffold.dart';

class TutorStudentsScreen extends StatefulWidget {
  const TutorStudentsScreen({super.key});

  @override
  State<TutorStudentsScreen> createState() => _TutorStudentsScreenState();
}

class _TutorStudentsScreenState extends State<TutorStudentsScreen> {
  StreamSubscription<List<Booking>>? _subscription;
  List<Booking> _bookings = <Booking>[];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final String? uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      _subscription = context
          .read<FirestoreService>()
          .watchBookingsForTutor(uid)
          .listen(
            (List<Booking> bookings) {
              if (mounted) setState(() => _bookings = bookings);
            },
            onError: (Object error) {
              debugPrint('[STREAM] tutor_students failed: $error');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  _bookings = <Booking>[];
                });
              });
            },
          );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> students = <String, String>{};
    for (final Booking booking in _bookings) {
      students.putIfAbsent(booking.studentId, () => booking.studentName);
    }

    return ScreenScaffold(
      title: 'Students',
      subtitle: 'People you have taught on TutorTap.',
      showBack: false,
      body: students.isEmpty
          ? const EmptyHint(message: 'No students yet.', icon: Icons.groups_outlined)
          : ListView(
              children: students.entries.map((MapEntry<String, String> entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.studentDetail,
                      arguments: <String, dynamic>{
                        'studentId': entry.key,
                        'studentName': entry.value,
                      },
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: SectionCard(
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            child: Text(
                              entry.value.isEmpty
                                  ? '?'
                                  : entry.value.substring(0, 1).toUpperCase(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(entry.value)),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
    );
  }
}
