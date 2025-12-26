import "package:intl/intl.dart";

class DateFormatters {
  static final DateFormat _time = DateFormat("h:mm a");
  static final DateFormat _day = DateFormat("EEE");
  static final DateFormat _monthDay = DateFormat("MMM d");

  static String formatTime(DateTime dateTime) {
    return _time.format(dateTime);
  }

  static String formatDay(DateTime dateTime) {
    return _day.format(dateTime);
  }

  static String formatMonthDay(DateTime dateTime) {
    return _monthDay.format(dateTime);
  }

  static int daysTogether(DateTime anniversary, DateTime now) {
    final start = DateTime(anniversary.year, anniversary.month, anniversary.day);
    final end = DateTime(now.year, now.month, now.day);
    return end.difference(start).inDays.abs() + 1;
  }

  static int nextMilestoneDays(DateTime anniversary, DateTime now) {
    final days = daysTogether(anniversary, now);
    final nextMilestone = ((days / 50).ceil()) * 50;
    return nextMilestone - days;
  }
}
