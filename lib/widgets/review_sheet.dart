import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../services/firestore_service.dart';
import 'pill_button.dart';
import 'star_rating.dart';

Future<bool?> showReviewSheet(
  BuildContext context, {
  required Booking booking,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => _ReviewSheet(booking: booking),
  );
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({required this.booking});

  final Booking booking;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int? _stars;
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars == null || _submitting) return;
    final int stars = _stars!;
    final NavigatorState navigator = Navigator.of(context);
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await FirestoreService().submitReview(
        booking: widget.booking,
        stars: stars,
        comment: _commentController.text,
      );
      if (!mounted) return;
      navigator.pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Could not save your review. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Rate this session',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Your rating is shared with ${widget.booking.tutorName}.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            StarRating(
              value: _stars?.toDouble() ?? 0,
              size: 34,
              onChanged: _submitting
                  ? null
                  : (int stars) => setState(() => _stars = stars),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              enabled: !_submitting,
              maxLength: 500,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 14),
            PillButton(
              label: _submitting ? 'Submitting…' : 'Submit review',
              onPressed: _stars == null || _submitting ? null : _submit,
            ),
            const SizedBox(height: 8),
            PillButton(
              label: 'Not now',
              variant: PillButtonVariant.text,
              onPressed: _submitting
                  ? null
                  : () => Navigator.of(context).pop(null),
            ),
          ],
        ),
      ),
    );
  }
}
