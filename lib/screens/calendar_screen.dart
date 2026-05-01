import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../dream_detail_screen.dart';
import '../dream_model.dart';
import '../dream_storage_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Dream> _allDreams = [];
  bool _loading = true;

  late final AnimationController _bgController;
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _loadDreams();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _loadDreams() async {
    final dreams = await DreamStorageService.loadDreams();
    setState(() {
      _allDreams = dreams;
      _loading = false;
    });
  }

  List<Dream> _getDreamsForDay(DateTime day) {
    return _allDreams.where((dream) {
      return dream.date.year == day.year &&
          dream.date.month == day.month &&
          dream.date.day == day.day;
    }).toList();
  }

  Future<void> _openDream(Dream dream) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DreamDetailScreen(dream: dream)),
    );
    _loadDreams();
  }

  String _selectedTitle() {
    final day = _selectedDay ?? DateTime.now();
    return '${day.day}/${day.month}/${day.year}';
  }

  @override
  Widget build(BuildContext context) {
    final selectedDreams =
        _selectedDay != null ? _getDreamsForDay(_selectedDay!) : [];

    return Scaffold(
      backgroundColor: const Color(0xFF05020A),
      body: Stack(
        children: [
          _AnimatedPremiumBackground(controller: _bgController),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SafeArea(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _entranceController,
                    curve: Curves.easeOut,
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.035),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _entranceController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF4FD8),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(22, 22, 22, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dream Calendar',
                                      style: GoogleFonts.inter(
                                        color: Colors.white.withOpacity(0.52),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Rüya Takvimi',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Rüyalarını gün gün takip et',
                                      style: GoogleFonts.inter(
                                        color: Colors.white.withOpacity(0.45),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 18),
                                child: _GlassCard(
                                  padding: const EdgeInsets.all(12),
                                  child: TableCalendar<Dream>(
                                    firstDay: DateTime(2020),
                                    lastDay: DateTime(2030),
                                    focusedDay: _focusedDay,
                                    selectedDayPredicate: (day) =>
                                        isSameDay(_selectedDay, day),
                                    eventLoader: _getDreamsForDay,
                                    onDaySelected: (selected, focused) {
                                      setState(() {
                                        _selectedDay = selected;
                                        _focusedDay = focused;
                                      });
                                    },
                                    headerStyle: HeaderStyle(
                                      formatButtonVisible: false,
                                      titleCentered: true,
                                      titleTextStyle: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      leftChevronIcon: Icon(
                                        Icons.chevron_left_rounded,
                                        color: Colors.white.withOpacity(0.78),
                                      ),
                                      rightChevronIcon: Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.white.withOpacity(0.78),
                                      ),
                                    ),
                                    daysOfWeekStyle: DaysOfWeekStyle(
                                      weekdayStyle: GoogleFonts.inter(
                                        color: Colors.white.withOpacity(0.50),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      weekendStyle: GoogleFonts.inter(
                                        color: Colors.white.withOpacity(0.50),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    calendarStyle: CalendarStyle(
                                      outsideDaysVisible: false,
                                      defaultTextStyle: GoogleFonts.inter(
                                        color: Colors.white.withOpacity(0.72),
                                        fontWeight: FontWeight.w700,
                                      ),
                                      weekendTextStyle: GoogleFonts.inter(
                                        color: Colors.white.withOpacity(0.72),
                                        fontWeight: FontWeight.w700,
                                      ),
                                      todayDecoration: BoxDecoration(
                                        color: const Color(0xFFFF4FD8)
                                            .withOpacity(0.20),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFFF4FD8)
                                              .withOpacity(0.45),
                                        ),
                                      ),
                                      selectedDecoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFF4FD8),
                                            Color(0xFF7B2FBE),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      markerDecoration: const BoxDecoration(
                                        color: Color(0xFFFFD166),
                                        shape: BoxShape.circle,
                                      ),
                                      markersMaxCount: 3,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 22),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedDay == null
                                          ? 'Bir gün seç'
                                          : _selectedTitle(),
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    Text(
                                      _selectedDay == null
                                          ? ''
                                          : '${selectedDreams.length} kayıt',
                                      style: GoogleFonts.inter(
                                        color: Colors.white.withOpacity(0.42),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: _selectedDay == null
                                    ? _EmptyState(
                                        emoji: '📅',
                                        title: 'Bir gün seç',
                                        subtitle:
                                            'Rüya yazdığın günleri burada görebilirsin.',
                                      )
                                    : selectedDreams.isEmpty
                                        ? _EmptyState(
                                            emoji: '🌑',
                                            title: 'Bu güne ait rüya yok',
                                            subtitle:
                                                'Bu tarihte kayıtlı rüyan bulunmuyor.',
                                          )
                                        : ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            padding: const EdgeInsets.fromLTRB(
                                                18, 0, 18, 112),
                                            itemCount: selectedDreams.length,
                                            itemBuilder: (context, index) {
                                              final dream =
                                                  selectedDreams[index];

                                              return TweenAnimationBuilder<
                                                  double>(
                                                tween: Tween(begin: 0, end: 1),
                                                duration: Duration(
                                                  milliseconds:
                                                      360 + index * 65,
                                                ),
                                                curve: Curves.easeOutCubic,
                                                builder:
                                                    (context, value, child) {
                                                  return Opacity(
                                                    opacity: value,
                                                    child: Transform.translate(
                                                      offset: Offset(
                                                        0,
                                                        18 * (1 - value),
                                                      ),
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                                child: _PressableCard(
                                                  onTap: () =>
                                                      _openDream(dream),
                                                  child: _DreamCalendarCard(
                                                    dream: dream,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DreamCalendarCard extends StatelessWidget {
  final Dream dream;

  const _DreamCalendarCard({required this.dream});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: _GlassCard(
        borderColor: const Color(0xFFFF4FD8).withOpacity(0.28),
        glowColor: const Color(0xFFFF4FD8).withOpacity(0.15),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF4FD8),
                    Color(0xFF7B2FBE),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4FD8).withOpacity(0.35),
                    blurRadius: 25,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  dream.category.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dream.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    dream.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.50),
                      fontSize: 12,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.34),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: _GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 62)),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? glowColor;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? Colors.white.withOpacity(0.12);
    final glow = glowColor ?? const Color(0xFFFF4FD8).withOpacity(0.14);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.075),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: glow,
                blurRadius: 45,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AnimatedPremiumBackground extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedPremiumBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value * math.pi * 2;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF07030D),
                Color(0xFF120727),
                Color(0xFF260837),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -115 + math.sin(t) * 24,
                right: -88 + math.cos(t) * 20,
                child: const _BlurCircle(
                  size: 305,
                  color: Color(0xFFFF006E),
                ),
              ),
              Positioned(
                top: 120 + math.cos(t) * 22,
                left: -140 + math.sin(t) * 22,
                child: const _BlurCircle(
                  size: 330,
                  color: Color(0xFF0066FF),
                ),
              ),
              Positioned(
                bottom: -120 + math.sin(t * 1.3) * 26,
                right: -95 + math.cos(t * 1.1) * 22,
                child: const _BlurCircle(
                  size: 320,
                  color: Color(0xFF7B2FBE),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 58, sigmaY: 58),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.27),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
