import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtils {
  // Ethiopian calendar constants
  static const int ethiopianYearOffset = 8;
  static const int ethiopianMonthOffset = 9;

  // Date formatting
  static String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(date);
  }

  static String formatTime(DateTime date, {String format = 'HH:mm'}) {
    return DateFormat(format).format(date);
  }

  static String formatDateTime(
    DateTime date, {
    String format = 'dd/MM/yyyy HH:mm',
  }) {
    return DateFormat(format).format(date);
  }

  // Relative time formatting
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // Ethiopian date conversion
  static DateTime gregorianToEthiopian(DateTime gregorianDate) {
    // Simplified conversion - in real app, use a proper Ethiopian calendar package
    final ethiopianYear = gregorianDate.year - ethiopianYearOffset;
    final ethiopianMonth =
        ((gregorianDate.month + ethiopianMonthOffset - 1) % 13) + 1;
    final ethiopianDay = gregorianDate.day;

    return DateTime(ethiopianYear, ethiopianMonth, ethiopianDay);
  }

  static DateTime ethiopianToGregorian(DateTime ethiopianDate) {
    // Simplified conversion
    final gregorianYear = ethiopianDate.year + ethiopianYearOffset;
    final gregorianMonth =
        ((ethiopianDate.month - ethiopianMonthOffset + 13) % 13) + 1;
    final gregorianDay = ethiopianDate.day;

    return DateTime(gregorianYear, gregorianMonth, gregorianDay);
  }

  // Payment due date calculations
  static DateTime getNextPaymentDueDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 1); // 1st of next month
  }

  static bool isPaymentDue(DateTime dueDate) {
    final now = DateTime.now();
    return now.isAfter(dueDate);
  }

  static bool isPaymentOverdue(DateTime dueDate, {int gracePeriodDays = 7}) {
    final overdueDate = dueDate.add(Duration(days: gracePeriodDays));
    return DateTime.now().isAfter(overdueDate);
  }

  static int daysUntilDue(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  static int daysOverdue(DateTime dueDate) {
    final now = DateTime.now();
    return now.difference(dueDate).inDays;
  }

  // Event scheduling
  static DateTime getNextRehearsalDate({
    List<int> rehearsalDays = const [2, 4],
  }) {
    // rehearsalDays: 1=Monday, 7=Sunday
    final now = DateTime.now();
    final currentWeekday = now.weekday;

    for (final day in rehearsalDays) {
      if (day > currentWeekday) {
        final daysToAdd = day - currentWeekday;
        return DateTime(now.year, now.month, now.day + daysToAdd);
      }
    }

    // If all rehearsal days have passed this week, get first day of next week
    final firstRehearsalDay = rehearsalDays.first;
    final daysToAdd = 7 - currentWeekday + firstRehearsalDay;
    return DateTime(now.year, now.month, now.day + daysToAdd);
  }

  static bool isEventToday(DateTime eventDate) {
    final now = DateTime.now();
    return now.year == eventDate.year &&
        now.month == eventDate.month &&
        now.day == eventDate.day;
  }

  static bool isEventThisWeek(DateTime eventDate) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return eventDate.isAfter(startOfWeek) && eventDate.isBefore(endOfWeek);
  }

  // Age calculation
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  // Date validation
  static bool isValidDate(int year, int month, int day) {
    try {
      DateTime(year, month, day);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  static bool isPastDate(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  // Date range calculations
  static List<DateTime> getDaysInRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  static int getDaysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  // Month calculations
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  static List<DateTime> getDaysInMonth(DateTime date) {
    final firstDay = getFirstDayOfMonth(date);
    final lastDay = getLastDayOfMonth(date);
    return getDaysInRange(firstDay, lastDay);
  }

  // Week calculations
  static DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime getEndOfWeek(DateTime date) {
    return date.add(Duration(days: DateTime.daysPerWeek - date.weekday));
  }

  // Format for display
  static String formatForDisplay(DateTime date, {bool includeTime = false}) {
    if (includeTime) {
      return formatDateTime(date);
    }
    return formatDate(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatDayMonth(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  // Ethiopian date formatting
  static String formatEthiopianDate(DateTime date) {
    final ethiopianDate = gregorianToEthiopian(date);
    return '${ethiopianDate.day}/${ethiopianDate.month}/${ethiopianDate.year}';
  }

  // Helper for creating time from string
  static TimeOfDay timeFromString(String timeString) {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  static String timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
