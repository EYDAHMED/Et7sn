/// Date helpers. Weeks start on Saturday (the usual week start in Egypt).
class WeekUtils {
  WeekUtils._();

  /// Whole days between 1970-01-01 and the calendar date of [date].
  static int dayNumber(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day)
        .difference(DateTime.utc(1970, 1, 1))
        .inDays;
  }

  /// Index of the Saturday-based week that contains [date].
  /// 1970-01-01 was a Thursday, so the first Saturday is day number 2.
  static int weekIndex(DateTime date) {
    return ((dayNumber(date) + 5) ~/ 7) - 1;
  }

  /// First day (Saturday) of the week with the given index, as a local date.
  static DateTime weekStart(int weekIndex) {
    final utc = DateTime.utc(1970, 1, 1 + weekIndex * 7 + 2);
    return DateTime(utc.year, utc.month, utc.day);
  }

  static String weekDocId(int weekIndex) => 'w$weekIndex';

  /// yyyy-MM-dd
  static String dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
