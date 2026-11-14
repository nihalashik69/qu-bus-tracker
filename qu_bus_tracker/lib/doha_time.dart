/// Doha (Asia/Qatar) wall-clock helpers for the bus timetable.
///
/// Every `stops:getSchedule` value is a **minute-of-day in Doha local time**
/// (e.g. `515` = 08:35). Reading those against `DateTime.now()` meant the web
/// build was only correct when the browser happened to be set to Doha time:
/// any other timezone shifted every "X min" pill by its UTC offset, and runs
/// that had already passed flipped to "Tomorrow".
///
/// Qatar has been a constant UTC+03:00 with no daylight saving since 1972, so
/// a fixed offset is exact and avoids shipping a timezone database.
///
/// Only [nowMinutesOfDay] and [nowFormatted] are exposed on purpose: shifting
/// a `DateTime` into another timezone while keeping its UTC flag would make
/// `difference()` against real instants silently wrong.
library;

class DohaTime {
  DohaTime._();

  /// Asia/Qatar offset — constant UTC+03:00, no DST.
  static const Duration utcOffset = Duration(hours: 3);

  /// Minutes elapsed since midnight in Doha (0-1439).
  static int nowMinutesOfDay() {
    final doha = DateTime.now().toUtc().add(utcOffset);
    return doha.hour * 60 + doha.minute;
  }

  /// Current Doha time as `h:mm AM/PM`.
  static String nowFormatted() => formatMinutesOfDay(nowMinutesOfDay());

  /// Formats a minute-of-day the way the schedule pills do.
  static String formatMinutesOfDay(int minutesOfDay) {
    final wrapped = minutesOfDay % (24 * 60);
    final hour24 = wrapped ~/ 60;
    final minute = wrapped % 60;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 > 12 ? hour24 - 12 : (hour24 == 0 ? 12 : hour24);
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }
}
