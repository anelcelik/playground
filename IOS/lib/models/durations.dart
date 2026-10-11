/// Visit lengths as the visit sheet and Edit Entry offer them, and store them.
const kDurations = ['15m', '30m', '45m', '1h', '1.5h', '2h', '2h+'];

/// Minutes for a stored duration. Accepts today's labels and the long ones
/// ("15 min", "1 hour") that older entries were saved with; 0 if unknown.
int durationMinutes(String? d) => switch (d) {
      '15m' || '15 min' => 15,
      '30m' || '30 min' => 30,
      '45m' || '45 min' => 45,
      '1h' || '1 hour' => 60,
      '1.5h' || '1.5 hours' => 90,
      '2h' || '2 hours' => 120,
      '2h+' || '2+ hours' => 150,
      _ => 0,
    };

/// [d] in today's label set, so an older entry shows as selected when edited.
String? normalizeDuration(String? d) {
  final minutes = durationMinutes(d);
  if (minutes == 0) return d;
  return kDurations.firstWhere((k) => durationMinutes(k) == minutes);
}
