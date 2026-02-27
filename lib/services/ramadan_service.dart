import 'package:flutter/material.dart';
import '../models/ramadan_day.dart';

class RamadanService {
  static final List<RamadanDay> schedule = [
    RamadanDay(day: 1, seheriTime: const TimeOfDay(hour: 5, minute: 12), iftarTime: const TimeOfDay(hour: 17, minute: 58), arabicDate: '1 Ramadan'),
    RamadanDay(day: 2, seheriTime: const TimeOfDay(hour: 5, minute: 11), iftarTime: const TimeOfDay(hour: 17, minute: 58), arabicDate: '2 Ramadan'),
    RamadanDay(day: 3, seheriTime: const TimeOfDay(hour: 5, minute: 11), iftarTime: const TimeOfDay(hour: 17, minute: 59), arabicDate: '3 Ramadan'),
    RamadanDay(day: 4, seheriTime: const TimeOfDay(hour: 5, minute: 10), iftarTime: const TimeOfDay(hour: 17, minute: 59), arabicDate: '4 Ramadan'),
    RamadanDay(day: 5, seheriTime: const TimeOfDay(hour: 5, minute: 09), iftarTime: const TimeOfDay(hour: 18, minute: 00), arabicDate: '5 Ramadan'),
    RamadanDay(day: 6, seheriTime: const TimeOfDay(hour: 5, minute: 08), iftarTime: const TimeOfDay(hour: 18, minute: 00), arabicDate: '6 Ramadan'),
    RamadanDay(day: 7, seheriTime: const TimeOfDay(hour: 5, minute: 08), iftarTime: const TimeOfDay(hour: 18, minute: 01), arabicDate: '7 Ramadan'),
    RamadanDay(day: 8, seheriTime: const TimeOfDay(hour: 5, minute: 07), iftarTime: const TimeOfDay(hour: 18, minute: 01), arabicDate: '8 Ramadan'),
    RamadanDay(day: 9, seheriTime: const TimeOfDay(hour: 5, minute: 06), iftarTime: const TimeOfDay(hour: 18, minute: 02), arabicDate: '9 Ramadan'),
    RamadanDay(day: 10, seheriTime: const TimeOfDay(hour: 5, minute: 05), iftarTime: const TimeOfDay(hour: 18, minute: 02), arabicDate: '10 Ramadan'),
    RamadanDay(day: 11, seheriTime: const TimeOfDay(hour: 5, minute: 05), iftarTime: const TimeOfDay(hour: 18, minute: 03), arabicDate: '11 Ramadan'),
    RamadanDay(day: 12, seheriTime: const TimeOfDay(hour: 5, minute: 04), iftarTime: const TimeOfDay(hour: 18, minute: 03), arabicDate: '12 Ramadan'),
    RamadanDay(day: 13, seheriTime: const TimeOfDay(hour: 5, minute: 03), iftarTime: const TimeOfDay(hour: 18, minute: 04), arabicDate: '13 Ramadan'),
    RamadanDay(day: 14, seheriTime: const TimeOfDay(hour: 5, minute: 02), iftarTime: const TimeOfDay(hour: 18, minute: 04), arabicDate: '14 Ramadan'),
    RamadanDay(day: 15, seheriTime: const TimeOfDay(hour: 5, minute: 01), iftarTime: const TimeOfDay(hour: 18, minute: 05), arabicDate: '15 Ramadan'),
    RamadanDay(day: 16, seheriTime: const TimeOfDay(hour: 5, minute: 00), iftarTime: const TimeOfDay(hour: 18, minute: 05), arabicDate: '16 Ramadan'),
    RamadanDay(day: 17, seheriTime: const TimeOfDay(hour: 4, minute: 59), iftarTime: const TimeOfDay(hour: 18, minute: 06), arabicDate: '17 Ramadan'),
    RamadanDay(day: 18, seheriTime: const TimeOfDay(hour: 4, minute: 58), iftarTime: const TimeOfDay(hour: 18, minute: 06), arabicDate: '18 Ramadan'),
    RamadanDay(day: 19, seheriTime: const TimeOfDay(hour: 4, minute: 57), iftarTime: const TimeOfDay(hour: 18, minute: 07), arabicDate: '19 Ramadan'),
    RamadanDay(day: 20, seheriTime: const TimeOfDay(hour: 4, minute: 57), iftarTime: const TimeOfDay(hour: 18, minute: 07), arabicDate: '20 Ramadan'),
    RamadanDay(day: 21, seheriTime: const TimeOfDay(hour: 4, minute: 56), iftarTime: const TimeOfDay(hour: 18, minute: 07), arabicDate: '21 Ramadan'),
    RamadanDay(day: 22, seheriTime: const TimeOfDay(hour: 4, minute: 55), iftarTime: const TimeOfDay(hour: 18, minute: 06), arabicDate: '22 Ramadan'),
    RamadanDay(day: 23, seheriTime: const TimeOfDay(hour: 4, minute: 54), iftarTime: const TimeOfDay(hour: 18, minute: 08), arabicDate: '23 Ramadan'),
    RamadanDay(day: 24, seheriTime: const TimeOfDay(hour: 4, minute: 53), iftarTime: const TimeOfDay(hour: 18, minute: 09), arabicDate: '24 Ramadan'),
    RamadanDay(day: 25, seheriTime: const TimeOfDay(hour: 4, minute: 52), iftarTime: const TimeOfDay(hour: 18, minute: 09), arabicDate: '25 Ramadan'),
    RamadanDay(day: 26, seheriTime: const TimeOfDay(hour: 4, minute: 51), iftarTime: const TimeOfDay(hour: 18, minute: 10), arabicDate: '26 Ramadan'),
    RamadanDay(day: 27, seheriTime: const TimeOfDay(hour: 4, minute: 50), iftarTime: const TimeOfDay(hour: 18, minute: 10), arabicDate: '27 Ramadan'),
    RamadanDay(day: 28, seheriTime: const TimeOfDay(hour: 4, minute: 49), iftarTime: const TimeOfDay(hour: 18, minute: 10), arabicDate: '28 Ramadan'),
    RamadanDay(day: 29, seheriTime: const TimeOfDay(hour: 4, minute: 48), iftarTime: const TimeOfDay(hour: 18, minute: 11), arabicDate: '29 Ramadan'),
    RamadanDay(day: 30, seheriTime: const TimeOfDay(hour: 4, minute: 47), iftarTime: const TimeOfDay(hour: 18, minute: 11), arabicDate: '30 Ramadan'),
  ];

  static RamadanDay? getToday() {
    final ramadanStart = DateTime(2026, 2, 19);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(ramadanStart.year, ramadanStart.month, ramadanStart.day);

    final index = today.difference(start).inDays;
    return (index >= 0 && index < schedule.length) ? schedule[index] : null;
  }
}
