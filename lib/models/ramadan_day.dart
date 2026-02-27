import 'package:flutter/material.dart';

class RamadanDay {
  final int day;
  final TimeOfDay seheriTime;
  final TimeOfDay iftarTime;
  final String arabicDate;

  RamadanDay({
    required this.day,
    required this.seheriTime,
    required this.iftarTime,
    required this.arabicDate,
  });

  String force12Hour(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }
}
