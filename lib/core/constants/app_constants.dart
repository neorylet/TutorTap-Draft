abstract final class AppConstants {
  static const double defaultCommissionRate = 0.12;
  static const double minCommissionRate = 0.10;
  static const double maxCommissionRate = 0.15;
  static const Duration slotLockDuration = Duration(minutes: 5);
  static const String paymentMode = 'simulated';
  static const int catalogPageSize = 10;

  static const String lottieWelcome = 'assets/lottie/welcome_study.json';
  static const String lottieUploading = 'assets/lottie/uploading_cloud.json';
  static const String lottieEmptySearch = 'assets/lottie/empty_search.json';
  static const String lottieBookingSuccess = 'assets/lottie/booking_success.json';

  static CommissionBreakdown calculateCommission(
    double subtotal, [
    double commissionRate = defaultCommissionRate,
  ]) {
    final double safeSubtotal = subtotal < 0 ? 0 : subtotal;
    final double safeRate = commissionRate.clamp(minCommissionRate, maxCommissionRate);
    final double commission = _round2(safeSubtotal * safeRate);
    return CommissionBreakdown(
      subtotal: _round2(safeSubtotal),
      commissionRate: safeRate,
      commissionAmount: commission,
      totalCharged: _round2(safeSubtotal),
      tutorPayout: _round2(safeSubtotal - commission),
    );
  }

  static double _round2(double value) => (value * 100).roundToDouble() / 100;
}

class CommissionBreakdown {
  const CommissionBreakdown({
    required this.subtotal,
    required this.commissionRate,
    required this.commissionAmount,
    required this.totalCharged,
    required this.tutorPayout,
  });

  final double subtotal;
  final double commissionRate;
  final double commissionAmount;
  final double totalCharged;
  final double tutorPayout;
}
