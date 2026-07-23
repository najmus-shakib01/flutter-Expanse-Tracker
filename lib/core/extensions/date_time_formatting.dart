import 'package:flutter/material.dart';

extension DateTimeFormatting on DateTime {
  String toShortDate() {
    return '$day ${_monthName(month)} $year';
  }
}

extension TimeOfDayFormatting on TimeOfDay {
  String toReadableTime() {
    final readableHour = hourOfPeriod == 0 ? 12 : hourOfPeriod;
    final minuteLabel = minute.toString().padLeft(2, '0');
    final periodLabel = period == DayPeriod.am ? 'AM' : 'PM';

    return '$readableHour:$minuteLabel $periodLabel';
  }
}

String _monthName(int month) {
  return switch (month) {
    1 => 'Jan',
    2 => 'Feb',
    3 => 'Mar',
    4 => 'Apr',
    5 => 'May',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Aug',
    9 => 'Sep',
    10 => 'Oct',
    11 => 'Nov',
    12 => 'Dec',
    _ => '',
  };
}
