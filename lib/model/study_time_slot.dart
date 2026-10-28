enum StudyTimeSlot {
  morning('Sáng', '07:00', '11:00'),
  afternoon('Chiều', '13:00', '17:00'),
  evening('Tối', '18:00', '22:00');

  const StudyTimeSlot(this.label, this.start, this.end);
  final String label, start, end;
  String get range => '$start - $end';
}
