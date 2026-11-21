import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../models/app_user.dart';
import '../models/booking.dart';
import '../models/time_slot.dart';
import '../models/tutor_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../routing/app_routes.dart';
import '../widgets/app_form_field.dart';
import '../widgets/pill_button.dart';
import 'screen_scaffold.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _roomController =
      TextEditingController(text: 'tutortap-online-room');

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CommissionBreakdown breakdown =
        context.select<BookingProvider, CommissionBreakdown>(
      (BookingProvider provider) => provider.breakdown,
    );
    final double rate = context.select<BookingProvider, double>(
      (BookingProvider provider) => provider.commissionRate,
    );
    final TutorProfile? tutor = context.select<BookingProvider, TutorProfile?>(
      (BookingProvider provider) => provider.selectedTutor,
    );
    final TimeSlot? slot = context.select<BookingProvider, TimeSlot?>(
      (BookingProvider provider) => provider.selectedSlot,
    );
    final bool isCheckingOut = context.select<BookingProvider, bool>(
      (BookingProvider provider) => provider.isCheckingOut,
    );
    final String? error = context.select<BookingProvider, String?>(
      (BookingProvider provider) => provider.error,
    );
    final AppUser? user = context.select<AuthProvider, AppUser?>(
      (AuthProvider provider) => provider.currentUser,
    );

    return ScreenScaffold(
      title: 'Confirm booking',
      subtitle: 'Simulated checkout — no real payment is taken.',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tutor?.displayName ?? 'Tutor',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    slot == null
                        ? 'No slot selected'
                        : DateFormat('EEE d MMM · h:mm a').format(slot.start),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                children: <Widget>[
                  _MoneyRow(
                    label: 'Subtotal',
                    value: breakdown.subtotal,
                  ),
                  const SizedBox(height: 8),
                  _MoneyRow(
                    label: 'Platform commission (${(rate * 100).round()}%)',
                    value: breakdown.commissionAmount,
                    negative: true,
                  ),
                  const Divider(height: 22),
                  _MoneyRow(
                    label: 'Total charged',
                    value: breakdown.totalCharged,
                    emphasized: true,
                  ),
                  const SizedBox(height: 6),
                  _MoneyRow(
                    label: 'Tutor payout',
                    value: breakdown.tutorPayout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Commission rate (${(rate * 100).round()}%)',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Slider(
              value: rate,
              min: AppConstants.minCommissionRate,
              max: AppConstants.maxCommissionRate,
              divisions: 5,
              label: '${(rate * 100).round()}%',
              onChanged: context.read<BookingProvider>().setCommissionRate,
            ),
            const SizedBox(height: 10),
            AppFormField(
              controller: _roomController,
              label: 'Online room name',
              hint: 'tutortap-online-room',
              prefixIcon: Icons.videocam_outlined,
            ),
            if (error != null) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                error,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 18),
            PillButton(
              label: isCheckingOut ? 'Confirming…' : 'Confirm simulated payment',
              onPressed: isCheckingOut ||
                      user == null ||
                      tutor == null ||
                      slot == null
                  ? null
                  : _confirm,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    final AppUser? currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;
    final Booking? booking = await context.read<BookingProvider>().checkout(
          studentUid: currentUser.uid,
          studentName: currentUser.displayName,
          onlineSession: OnlineSession(
            room: _roomController.text.trim(),
            note: 'Generated for this simulated session.',
          ),
        );
    if (!mounted || booking == null) return;
    Navigator.of(context).pushNamed(AppRoutes.confirmation, arguments: booking);
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.value,
    this.negative = false,
    this.emphasized = false,
  });

  final String label;
  final double value;
  final bool negative;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: emphasized
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          '${negative ? '−' : ''}₱${value.toStringAsFixed(2)}',
          style: emphasized
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
