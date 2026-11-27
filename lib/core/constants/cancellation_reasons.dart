class CancellationReason {
  const CancellationReason(this.code, this.label);
  final String code;
  final String label;
}

abstract final class CancellationReasons {
  static const List<CancellationReason> student = <CancellationReason>[
    CancellationReason('schedule_conflict', 'Schedule conflict'),
    CancellationReason('booked_by_mistake', 'Booked by mistake'),
    CancellationReason('found_another_tutor', 'Found another tutor'),
    CancellationReason('price', 'Price'),
    CancellationReason('other', 'Other'),
  ];

  static const List<CancellationReason> tutor = <CancellationReason>[
    CancellationReason('emergency', 'Emergency'),
    CancellationReason('schedule_conflict', 'Schedule conflict'),
    CancellationReason('not_my_subject', 'Not my subject'),
    CancellationReason('other', 'Other'),
  ];

  static String labelFor(String code) {
    for (final CancellationReason r in student) {
      if (r.code == code) return r.label;
    }
    for (final CancellationReason r in tutor) {
      if (r.code == code) return r.label;
    }
    return code;
  }
}
