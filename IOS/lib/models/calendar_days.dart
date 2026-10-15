/// "2026-10-15" for [d], the way entries store their date.
String dayKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// [d] moved by [days] calendar days, at midnight. Built from the date
/// parts, so a daylight-saving change never lands it on the wrong day.
DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);
