import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ramadan_day.dart';
import '../services/ramadan_service.dart';
import '../widgets/glassmorphic_card.dart';

class CountdownHome extends StatefulWidget {
  const CountdownHome({super.key});

  @override
  State<CountdownHome> createState() => _CountdownHomeState();
}

class _CountdownHomeState extends State<CountdownHome>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late DateTime _now;
  late AnimationController _animationController;
  int _selectedDay = 0;

  final ScrollController _scrollController = ScrollController();

  void _scrollToSelected() {
    if (_scrollController.hasClients) {
      // 78 is the width (68) + padding (10)
      double offset = _selectedDay * 70.0;
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    final today = RamadanService.getToday();
    if (today != null) {
      _selectedDay = today.day - 1;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Duration _getRemainingTime(TimeOfDay target) {
    final now = _now;
    var targetTime = DateTime(
      now.year,
      now.month,
      now.day,
      target.hour,
      target.minute,
    );
    if (targetTime.isBefore(now)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }
    return targetTime.difference(now);
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _convert24To12(int hour, int minute, {bool includeSeconds = false}) {
    String meridiem = hour >= 12 ? 'PM' : 'AM';
    int hour12 = hour % 12;
    if (hour12 == 0) hour12 = 12;
    String hourStr = hour12.toString().padLeft(2, '0');
    String minuteStr = minute.toString().padLeft(2, '0');
    if (includeSeconds) {
      String secondStr = _now.second.toString().padLeft(2, '0');
      return '$hourStr:$minuteStr:$secondStr $meridiem';
    }
    return '$hourStr:$minuteStr $meridiem';
  }

  String _getCurrentTime() =>
      _convert24To12(_now.hour, _now.minute, includeSeconds: true);

  String _formatTime(TimeOfDay time) => _convert24To12(time.hour, time.minute);

  String _getCurrentDate() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[_now.weekday - 1]}, ${_now.day} ${months[_now.month - 1]}';
  }

  String _calculateFastingDuration(RamadanDay dayData) {
    int totalMinutes =
        (dayData.iftarTime.hour * 60 + dayData.iftarTime.minute) -
        (dayData.seheriTime.hour * 60 + dayData.seheriTime.minute);
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  bool _isActive(TimeOfDay time) => _getRemainingTime(time).inSeconds < 3600;

  // Determine time period
  bool _isSeheriTime() {
    final seheriTime = RamadanService.schedule[_selectedDay].seheriTime;
    final seheriDateTime = DateTime(
      _now.year,
      _now.month,
      _now.day,
      seheriTime.hour,
      seheriTime.minute,
    );
    return _now.isBefore(seheriDateTime);
  }

  bool _isFastingTime() {
    final seheriTime = RamadanService.schedule[_selectedDay].seheriTime;
    final iftarTime = RamadanService.schedule[_selectedDay].iftarTime;
    final seheriDateTime = DateTime(
      _now.year,
      _now.month,
      _now.day,
      seheriTime.hour,
      seheriTime.minute,
    );
    final iftarDateTime = DateTime(
      _now.year,
      _now.month,
      _now.day,
      iftarTime.hour,
      iftarTime.minute,
    );
    return _now.isAfter(seheriDateTime) && _now.isBefore(iftarDateTime);
  }

  int _getNextDayIndex() {
    int nextDay = _selectedDay + 1;
    if (nextDay >= RamadanService.schedule.length) nextDay = 0;
    return nextDay;
  }

  @override
  Widget build(BuildContext context) {
    final dayData = RamadanService.schedule[_selectedDay];
    final nextDayData = RamadanService.schedule[_getNextDayIndex()];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'RAMADAN MUBARAK',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade900.withOpacity(0.25),
              Colors.blue.shade900.withOpacity(0.25),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  // 1st: CURRENT TIME
                  _buildCurrentTimeCard(),
                  const SizedBox(height: 16),
                  // 2nd: DAY SELECTOR
                  _buildDaySelector(),
                  const SizedBox(height: 24),
                  // 3rd: COUNTDOWN CARDS
                  if (_isSeheriTime()) ...[
                    _buildCountdownCard(
                      title: 'SEHERI',
                      subtitle: 'Pre-Dawn Meal',
                      scheduledTime: _formatTime(dayData.seheriTime),
                      time: _getRemainingTime(dayData.seheriTime),
                      icon: Icons.wb_sunny,
                      gradientColors: [
                        Colors.purple.shade400,
                        Colors.blue.shade600,
                      ],
                      isActive: _isActive(dayData.seheriTime),
                    ),
                    const SizedBox(height: 16),
                    _buildCountdownCard(
                      title: 'IFTAR',
                      subtitle: 'Post-Sunset Meal',
                      scheduledTime: _formatTime(dayData.iftarTime),
                      time: null,
                      icon: Icons.wb_twilight,
                      gradientColors: [
                        Colors.orange.shade400,
                        Colors.red.shade600,
                      ],
                      isActive: false,
                    ),
                  ] else if (_isFastingTime()) ...[
                    _buildCountdownCard(
                      title: 'IFTAR',
                      subtitle: 'Post-Sunset Meal',
                      scheduledTime: _formatTime(dayData.iftarTime),
                      time: _getRemainingTime(dayData.iftarTime),
                      icon: Icons.wb_twilight,
                      gradientColors: [
                        Colors.orange.shade400,
                        Colors.red.shade600,
                      ],
                      isActive: _isActive(dayData.iftarTime),
                    ),
                  ] else ...[
                    _buildCountdownCard(
                      title: 'SEHERI',
                      subtitle: 'Pre-Dawn Meal',
                      scheduledTime: _formatTime(nextDayData.seheriTime),
                      time: _getRemainingTime(nextDayData.seheriTime),
                      icon: Icons.wb_sunny,
                      gradientColors: [
                        Colors.purple.shade400,
                        Colors.blue.shade600,
                      ],
                      isActive: _isActive(nextDayData.seheriTime),
                    ),
                    const SizedBox(height: 16),
                    _buildCountdownCard(
                      title: 'IFTAR',
                      subtitle: 'Post-Sunset Meal',
                      scheduledTime: _formatTime(nextDayData.iftarTime),
                      time: null,
                      icon: Icons.wb_twilight,
                      gradientColors: [
                        Colors.orange.shade400,
                        Colors.red.shade600,
                      ],
                      isActive: false,
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildScheduleCard(dayData),
                  const SizedBox(height: 24),
                  _buildNextDayCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTimeCard() {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Text(
              _getCurrentDate(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.75),
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getCurrentTime(),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2,
                fontFamily: 'Courier',
              ),
            ),

            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                setState(() => _now = DateTime.now());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'Now',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade300,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 0.8,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(
                    () => _selectedDay = (RamadanService.getToday()!.day - 1),
                  );
                  _scrollToSelected();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade300,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: RamadanService.schedule.length,
            itemBuilder: (_, index) {
              final isSelected = index == _selectedDay;
              final day = RamadanService.schedule[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedDay = index);
                    _scrollToSelected(); // <--- Optional: scroll when user taps too
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                const Color(0xFF10B981).withOpacity(0.8),
                                const Color(0xFF0D9488).withOpacity(0.8),
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.08),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF10B981).withOpacity(0.8)
                            : Colors.white.withOpacity(0.1),
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ramadan',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownCard({
    required String title,
    required String subtitle,
    required String scheduledTime,
    required Duration? time,
    required IconData icon,
    required List<Color> gradientColors,
    required bool isActive,
  }) {
    return GlassmorphicCard(
      shadowColor: gradientColors[0],
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientColors[0].withOpacity(0.15),
              gradientColors[1].withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.65),
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              if (time != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _formatDuration(time),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'Courier',
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hours · Minutes · Seconds',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.55),
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        scheduledTime,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'Courier',
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.55),
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scheduled',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.55),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scheduledTime,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (isActive && time != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade400.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.green.shade400.withOpacity(0.8),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Coming Soon',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade300,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(RamadanDay dayData) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: Colors.blue.shade300,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  dayData.arabicDate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _scheduleRow(
              'Seheri Ends',
              _formatTime(dayData.seheriTime),
              Icons.wb_sunny,
              Colors.purple,
            ),
            const SizedBox(height: 14),
            _scheduleRow(
              'Fasting Duration',
              _calculateFastingDuration(dayData),
              Icons.hourglass_bottom,
              Colors.amber,
            ),
            const SizedBox(height: 14),
            _scheduleRow(
              'Iftar Begins',
              _formatTime(dayData.iftarTime),
              Icons.wb_twilight,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleRow(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildNextDayCard() {
    final nextDayData = RamadanService.schedule[_getNextDayIndex()];

    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade400.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.green.shade300,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Next Day',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _scheduleRow(
              'Seheri Ends',
              _formatTime(nextDayData.seheriTime),
              Icons.wb_sunny,
              Colors.purple,
            ),
            const SizedBox(height: 14),
            _scheduleRow(
              'Fasting Duration',
              _calculateFastingDuration(nextDayData),
              Icons.hourglass_bottom,
              Colors.amber,
            ),
            const SizedBox(height: 14),
            _scheduleRow(
              'Iftar Begins',
              _formatTime(nextDayData.iftarTime),
              Icons.wb_twilight,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
