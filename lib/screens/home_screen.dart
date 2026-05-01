import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dream_detail_screen.dart';
import '../dream_model.dart';
import '../dream_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Dream> _dreams = [];
  bool _isLoading = true;

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
      _dreams = dreams;
      _isLoading = false;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Gece sessiz, zihin açık';
    if (hour < 12) return 'Günaydın, rüyalarını hatırla';
    if (hour < 18) return 'Bugünün rüyasına dön';
    return 'İyi geceler, Morpheus burada';
  }

  int _thisWeekCount() {
    final now = DateTime.now();
    return _dreams.where((d) => now.difference(d.date).inDays < 7).length;
  }

  Color _categoryColor(DreamCategory cat) {
    switch (cat) {
      case DreamCategory.nightmare:
        return const Color(0xFFFF4D6D);
      case DreamCategory.adventure:
        return const Color(0xFF00F5A0);
      case DreamCategory.romantic:
        return const Color(0xFFFF4FD8);
      case DreamCategory.spiritual:
        return const Color(0xFF9B5CFF);
      case DreamCategory.mysterious:
        return const Color(0xFF00B4FF);
      case DreamCategory.daily:
        return const Color(0xFF00E5FF);
      default:
        return const Color(0xFF9B5CFF);
    }
  }

  Future<void> _openDream(Dream dream) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DreamDetailScreen(dream: dream),
      ),
    );

    _loadDreams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05020A),
      body: Stack(
        children: [
          _AnimatedPremiumBackground(controller: _bgController),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SafeArea(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF4FD8),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDreams,
                        color: const Color(0xFFFF4FD8),
                        backgroundColor: const Color(0xFF140B22),
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          slivers: [
                            SliverToBoxAdapter(
                              child: FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: _entranceController,
                                  curve: Curves.easeOut,
                                ),
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.04),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: _entranceController,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        22, 22, 22, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getGreeting(),
                                          style: GoogleFonts.inter(
                                            color:
                                                Colors.white.withOpacity(0.52),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              'Morpheus',
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 38,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: -1.4,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              '🌙',
                                              style: TextStyle(fontSize: 30),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'AI destekli rüya günlüğün',
                                          style: GoogleFonts.inter(
                                            color:
                                                Colors.white.withOpacity(0.45),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        _HeroDreamCard(
                                          totalDreams: _dreams.length,
                                          weekDreams: _thisWeekCount(),
                                          lastEmoji: _dreams.isEmpty
                                              ? '✨'
                                              : _dreams.first.category.emoji,
                                        ),
                                        const SizedBox(height: 26),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Rüyaların',
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 23,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            Text(
                                              '${_dreams.length} kayıt',
                                              style: GoogleFonts.inter(
                                                color: Colors.white
                                                    .withOpacity(0.42),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _dreams.isEmpty
                                ? SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(28),
                                        child: _GlassCard(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                '🌑',
                                                style: TextStyle(fontSize: 74),
                                              ),
                                              const SizedBox(height: 18),
                                              Text(
                                                'Henüz rüya yok',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'İlk rüyanı ekle ve AI ile sembollerini yorumlat.',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.inter(
                                                  color: Colors.white
                                                      .withOpacity(0.45),
                                                  fontSize: 14,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                        18, 0, 18, 112),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final dream = _dreams[index];
                                          final catColor =
                                              _categoryColor(dream.category);

                                          return TweenAnimationBuilder<double>(
                                            tween: Tween(begin: 0, end: 1),
                                            duration: Duration(
                                              milliseconds: 380 + index * 65,
                                            ),
                                            curve: Curves.easeOutCubic,
                                            builder: (context, value, child) {
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
                                              onTap: () => _openDream(dream),
                                              child: _DreamPremiumCard(
                                                dream: dream,
                                                catColor: catColor,
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: _dreams.length,
                                      ),
                                    ),
                                  ),
                          ],
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

class _HeroDreamCard extends StatelessWidget {
  final int totalDreams;
  final int weekDreams;
  final String lastEmoji;

  const _HeroDreamCard({
    required this.totalDreams,
    required this.weekDreams,
    required this.lastEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return _PressableCard(
      onTap: () {},
      child: _GlassCard(
        padding: EdgeInsets.zero,
        borderColor: Colors.white.withOpacity(0.16),
        glowColor: const Color(0xFFFF4FD8).withOpacity(0.22),
        child: SizedBox(
          height: 255,
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -32,
                child: _NeonOrb(size: 172),
              ),
              Positioned(
                bottom: -58,
                left: -40,
                child: _NeonOrb(size: 150, reverse: true),
              ),
              Positioned(
                right: 28,
                top: 34,
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.22),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroPill(text: 'AI DREAM INSIGHT'),
                    const Spacer(),
                    Text(
                      'Rüyanı\nAI ile çözümle',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                        height: 0.95,
                        letterSpacing: -1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sembollerini, duygunu ve bilinçaltı izlerini tek ekranda gör.',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.58),
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _MiniStat(value: '$totalDreams', label: 'Rüya'),
                        const SizedBox(width: 10),
                        _MiniStat(value: '$weekDreams', label: 'Bu hafta'),
                        const SizedBox(width: 10),
                        _MiniStat(value: lastEmoji, label: 'Son'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DreamPremiumCard extends StatelessWidget {
  final Dream dream;
  final Color catColor;

  const _DreamPremiumCard({
    required this.dream,
    required this.catColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: _GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: catColor.withOpacity(0.32),
        glowColor: catColor.withOpacity(0.20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    catColor.withOpacity(0.95),
                    const Color(0xFFFF4FD8).withOpacity(0.78),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: catColor.withOpacity(0.38),
                    blurRadius: 26,
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
                      letterSpacing: 0.2,
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
                  if (dream.emotion != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: catColor.withOpacity(0.22),
                        ),
                      ),
                      child: Text(
                        '✨ ${dream.emotion}',
                        style: GoogleFonts.inter(
                          color: catColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${dream.date.day}/${dream.date.month}',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.32),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Icon(
                  dream.isFavorite
                      ? Icons.star_rounded
                      : Icons.arrow_forward_ios_rounded,
                  color: dream.isFavorite
                      ? const Color(0xFFFFD166)
                      : Colors.white.withOpacity(0.34),
                  size: dream.isFavorite ? 21 : 14,
                ),
              ],
            ),
          ],
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

class _HeroPill extends StatelessWidget {
  final String text;

  const _HeroPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: Colors.white.withOpacity(0.13),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white.withOpacity(0.82),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;

  const _MiniStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.105),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
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
    this.padding = const EdgeInsets.all(18),
    this.borderColor,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? Colors.white.withOpacity(0.12);
    final glow = glowColor ?? const Color(0xFFFF4FD8).withOpacity(0.14);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.075),
            borderRadius: BorderRadius.circular(30),
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

class _NeonOrb extends StatelessWidget {
  final double size;
  final bool reverse;

  const _NeonOrb({
    required this.size,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: reverse ? -0.5 : 0.35,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: reverse
                ? const [
                    Color(0xFF00E5FF),
                    Color(0xFFFF4FD8),
                    Color(0xFFFF7A00),
                    Color(0xFF00E5FF),
                  ]
                : const [
                    Color(0xFFFF4FD8),
                    Color(0xFF7B2FBE),
                    Color(0xFF00E5FF),
                    Color(0xFFFF4FD8),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4FD8).withOpacity(0.35),
              blurRadius: 48,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: size * 0.62,
            height: size * 0.62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A102A).withOpacity(0.88),
            ),
          ),
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
              Positioned(
                bottom: 160 + math.cos(t * 0.8) * 18,
                left: 100 + math.sin(t * 0.8) * 18,
                child: const _BlurCircle(
                  size: 190,
                  color: Color(0xFFFF4FD8),
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
