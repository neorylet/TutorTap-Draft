import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/booking.dart';
import '../models/time_slot.dart';
import '../models/tutor_profile.dart';
import '../services/firestore_service.dart';

/// Slot grid widgets should use `context.select<BookingProvider, List<TimeSlot>>((p) => p.slots)`;
/// the checkout total uses `Selector<BookingProvider, CommissionBreakdown>`.
class BookingProvider extends ChangeNotifier {
  BookingProvider(this._firestoreService);

  final FirestoreService _firestoreService;
  StreamSubscription<List<TimeSlot>>? _slotsSubscription;
  StreamSubscription<List<Booking>>? _bookingsSubscription;

  TutorProfile? _selectedTutor;
  TimeSlot? _selectedSlot;
  List<TimeSlot> _slots = <TimeSlot>[];
  List<Booking> _bookings = <Booking>[];
  DateTime _selectedDate = DateTime.now();
  double _commissionRate = AppConstants.defaultCommissionRate;
  bool _isCheckingOut = false;
  String? _error;
  Booking? _lastCompletedBooking;
  bool _disposed = false;

  TutorProfile? get selectedTutor => _selectedTutor;
  TimeSlot? get selectedSlot => _selectedSlot;
  List<TimeSlot> get slots => _slots;
  List<Booking> get bookings => _bookings;
  DateTime get selectedDate => _selectedDate;
  double get commissionRate => _commissionRate;
  bool get isCheckingOut => _isCheckingOut;
  String? get error => _error;
  Booking? get lastCompletedBooking => _lastCompletedBooking;

  double get subtotal {
    final TimeSlot? slot = _selectedSlot;
    final double hours = slot == null
        ? 1
        : slot.end.difference(slot.start).inMinutes / 60.0;
    return (_selectedTutor?.hourlyRate ?? 0) * hours;
  }

  CommissionBreakdown get breakdown =>
      AppConstants.calculateCommission(subtotal, _commissionRate);

  void selectTutor(TutorProfile tutor) {
    _selectedTutor = tutor;
    _selectedSlot = null;
    _error = null;
    _lastCompletedBooking = null;
    _notify();
  }

  void selectSlot(TimeSlot slot) {
    _selectedSlot = slot;
    _error = null;
    _notify();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _notify();
  }

  void setCommissionRate(double rate) {
    _commissionRate = rate.clamp(
      AppConstants.minCommissionRate,
      AppConstants.maxCommissionRate,
    );
    _notify();
  }

  void watchTutorSlots(String tutorId) {
    _slotsSubscription?.cancel();
    _slotsSubscription = _firestoreService.watchSlots(tutorId).listen((slots) {
      _slots = slots;
      if (_selectedSlot != null) {
        final TimeSlot? refreshed = slots.cast<TimeSlot?>().firstWhere(
          (slot) => slot?.id == _selectedSlot?.id,
          orElse: () => null,
        );
        _selectedSlot = refreshed;
      }
      _notify();
    });
  }

  void watchStudentBookings(String studentId) {
    _bookingsSubscription?.cancel();
    _bookingsSubscription = _firestoreService
        .watchBookingsForStudent(studentId)
        .listen((bookings) {
          _bookings = bookings;
          _notify();
        });
  }

  void watchTutorBookings(String tutorId) {
    _bookingsSubscription?.cancel();
    _bookingsSubscription = _firestoreService
        .watchBookingsForTutor(tutorId)
        .listen((bookings) {
          _bookings = bookings;
          _notify();
        });
  }

  Future<Booking?> checkout({
    required String studentUid,
    required String studentName,
    required OnlineSession onlineSession,
  }) async {
    final TutorProfile? tutor = _selectedTutor;
    final TimeSlot? slot = _selectedSlot;
    if (tutor == null || slot == null) {
      _error = 'Choose a slot before checkout.';
      _notify();
      return null;
    }

    _isCheckingOut = true;
    _error = null;
    _notify();
    try {
      final Booking booking = await _firestoreService.confirmSimulatedBooking(
        studentId: studentUid,
        tutorId: tutor.uid,
        slotId: slot.id,
        studentName: studentName,
        tutorName: tutor.displayName,
        subject: tutor.subjects.isEmpty ? 'Tutoring' : tutor.subjects.first,
        slotStart: slot.start,
        slotEnd: slot.end,
        onlineSession: onlineSession,
        subtotal: subtotal,
        commissionRate: _commissionRate,
      );
      _lastCompletedBooking = booking;
      return booking;
    } on SlotAlreadyTakenException catch (error) {
      _error = error.message;
      debugPrint('[BOOKING_RECON] provider ${error.runtimeType} $error');
      return null;
    } catch (error) {
      _error = error.toString();
      debugPrint('[BOOKING_RECON] provider ${error.runtimeType} $error');
      return null;
    } finally {
      _isCheckingOut = false;
      _notify();
    }
  }

  Future<bool> cancelBooking(
    Booking booking, {
    required String cancelledBy,
    required String reason,
    String note = '',
  }) async {
    _error = null;
    try {
      await _firestoreService.cancelBooking(
        booking,
        cancelledBy: cancelledBy,
        reason: reason,
        note: note,
      );
      _notify();
      return true;
    } catch (error) {
      _error = error.toString();
      _notify();
      return false;
    }
  }

  Future<bool> completeBooking(Booking booking) async {
    _error = null;
    try {
      await _firestoreService.completeBooking(booking);
      _notify();
      return true;
    } catch (error) {
      _error = error.toString();
      _notify();
      return false;
    }
  }

  Future<bool> rescheduleBooking({
    required Booking booking,
    required String newSlotId,
    required DateTime newStart,
    required DateTime newEnd,
    required String reason,
    required String note,
  }) async {
    _error = null;
    bool ok = false;
    try {
      await _firestoreService.rescheduleBooking(
        booking: booking,
        newSlotId: newSlotId,
        newStart: newStart,
        newEnd: newEnd,
        reason: reason,
        note: note,
      );
      ok = true;
    } on SlotAlreadyTakenException catch (error) {
      _error = error.message;
    } catch (error) {
      _error = error.toString();
    }
    _notify();
    return ok;
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    _notify();
  }

  void clearSelection() {
    _selectedTutor = null;
    _selectedSlot = null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _slotsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    _disposed = true;
    super.dispose();
  }
}
