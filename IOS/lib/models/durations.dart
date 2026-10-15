/// Visit lengths as the visit sheet and Edit Entry offer them, and store them.
const kDurations = ['15m', '30m', '45m', '1h', '1.5h', '2h', '2h+'];

/// Minutes for a preset label, or for the long ones ("15 min", "1 hour")
/// that older entries were saved with; null for anything else.
int? _presetMinutes(String? d) => switch (d) {
      '15m' || '15 min' => 15,
      '30m' || '30 min' => 30,
      '45m' || '45 min' => 45,
      '1h' || '1 hour' => 60,
      '1.5h' || '1.5 hours' => 90,
      '2h' || '2 hours' => 120,
      '2h+' || '2+ hours' => 150,
      _ => null,
    };

final _exactLength = RegExp(r'^(?:(\d+)h)?\s*(?:(\d+)m)?$');

/// Minutes for a stored duration: a preset, an older long label, or an
/// exact length from the advanced log ("1h 25m", "40m"); 0 if unknown.
int durationMinutes(String? d) {
  final preset = _presetMinutes(d);
  if (preset != null) return preset;
  final m = _exactLength.firstMatch(d?.trim() ?? '');
  if (m == null) return 0;
  return int.parse(m[1] ?? '0') * 60 + int.parse(m[2] ?? '0');
}

/// [minutes] the way durations are stored and shown: "40m", "2h", "1h 25m".
String formatMinutes(int minutes) {
  final h = minutes ~/ 60, m = minutes % 60;
  if (h > 0 && m > 0) return '${h}h ${m}m';
  if (h > 0) return '${h}h';
  return '${m}m';
}

/// [d] in today's label set, so an older entry shows as selected when edited.
/// Exact lengths are not presets and come back unchanged.
String? normalizeDuration(String? d) {
  final minutes = _presetMinutes(d);
  if (minutes == null) return d;
  return kDurations.firstWhere((k) => _presetMinutes(k) == minutes);
}

/// The preset closest to [minutes], for leaving the advanced log; null for 0.
String? nearestPreset(int minutes) {
  if (minutes <= 0) return null;
  var best = kDurations.first;
  for (final k in kDurations) {
    if ((_presetMinutes(k)! - minutes).abs() <
        (_presetMinutes(best)! - minutes).abs()) {
      best = k;
    }
  }
  return best;
}

/// "15:10" → minutes after midnight; null if malformed.
int? clockMinutes(String? hm) {
  final p = hm?.split(':');
  if (p == null || p.length != 2) return null;
  final h = int.tryParse(p[0]), m = int.tryParse(p[1]);
  if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) return null;
  return h * 60 + m;
}

/// Minutes after midnight → "15:10", as start and end times are stored.
String clockLabel(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
    '${(minutes % 60).toString().padLeft(2, '0')}';
