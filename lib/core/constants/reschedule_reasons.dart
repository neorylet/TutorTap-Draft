class RescheduleReason {
  const RescheduleReason(this.code, this.label);
  final String code;
  final String label;
}

abstract final class RescheduleReasons {
  static const List<RescheduleReason> all = <RescheduleReason>[
    RescheduleReason('schedule_conflict', 'Schedule conflict'),
    RescheduleReason('need_different_time', 'Need a different time'),
    RescheduleReason('tutor_availability', 'Tutor availability issue'),
    RescheduleReason('personal', 'Personal reasons'),
    RescheduleReason('other', 'Other'),
  ];

  static String labelFor(String code) {
    for (final RescheduleReason r in all) {
      if (r.code == code) return r.label;
    }
    return code;
  }
}
