import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dream_detail_screen.dart';
import '../dream_model.dart';
import '../dream_storage_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  List<Dream> _favorites = [];
  bool _loading = true;

  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _loadFavorites();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final dreams = await DreamStorageService.loadDreams();
    setState(() {
      _favorites = dreams.where((d) => d.isFavorite).toList();
      _loading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06030D),
      body: Stack(
        children: [
          _FavoritesBackground(controller: _bgController),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saved Dreams',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.50),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Favoriler',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.1,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text('⭐', style: TextStyle(fontSize: 28)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _HeroFavoriteCard(count: _favorites.length),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFD166),
                              ),
                            )
                          : _favorites.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(26),
                                    child: _GlassCard(
                                      borderColor: const Color(0xFFFFD166)
                                          .withOpacity(0.24),
                                      glowColor: const Color(0xFFFFD166)
                                          .withOpacity(0.12),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            '⭐',
                                            style: TextStyle(fontSize: 66),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Henüz favori yok',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 21,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Beğendiğin rüyaların detayında yıldız ikonuna bas.',
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
                                )
                              : RefreshIndicator(
                                  onRefresh: _loadFavorites,
                                  color: const Color(0xFFFFD166),
                                  backgroundColor: const Color(0xFF140B22),
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics(),
                                    ),
                                    padding: const EdgeInsets.fromLTRB(
                                        18, 0, 18, 110),
                                    itemCount: _favorites.length,
                                    itemBuilder: (context, index) {
                                      final dream = _favorites[index];
                                      final color =
                                          _categoryColor(dream.category);

                                      return TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0, end: 1),
                                        duration: Duration(
                                          milliseconds: 360 + index * 65,
                                        ),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, child) {
                                          return Opacity(
                                            opacity: value,
                                            child: Transform.translate(
                                              offset:
                                                  Offset(0, 16 * (1 - value)),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: GestureDetector(
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DreamDetailScreen(
                                                  dream: dream,
                                                ),
                                              ),
                                            );
                                            _loadFavorites();
                                          },
                                          child: _FavoriteDreamCard(
                                            dream: dream,
                                            color: color,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroFavoriteCard extends StatelessWidget {
  final int count;

  const _HeroFavoriteCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      borderColor: const Color(0xFFFFD166).withOpacity(0.26),
      glowColor: const Color(0xFFFFD166).withOpacity(0.16),
      child: SizedBox(
        height: 150,
        child: Stack(
          children: [
            Positioned(
              top: -45,
              right: -35,
              child: _GoldenOrb(size: 150),
            ),
            Positioned(
              bottom: -60,
              left: -40,
              child: _GoldenOrb(size: 130, reverse: true),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          Color(0xFFFFD166),
                          Color(0xFFFF4FD8),
                          Color(0xFF7B2FBE),
                          Color(0xFFFFD166),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD166).withOpacity(0.30),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count favori rüya',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'En özel rüyalarını burada sakla.',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.52),
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteDreamCard extends StatelessWidget {
  final Dream dream;
  final Color color;

  const _FavoriteDreamCard({
    required this.dream,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: _GlassCard(
        borderColor: const Color(0xFFFFD166).withOpacity(0.28),
        glowColor: const Color(0xFFFFD166).withOpacity(0.12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.95),
                    const Color(0xFFFFD166).withOpacity(0.85),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD166).withOpacity(0.24),
                    blurRadius: 22,
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
                      color: Colors.white.withOpacity(0.48),
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                  if (dream.emotion != null) ...[
                    const SizedBox(height: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD166).withOpacity(0.14),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: const Color(0xFFFFD166).withOpacity(0.22),
                        ),
                      ),
                      child: Text(
                        '✨ ${dream.emotion}',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFFD166),
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
            const Icon(
              Icons.star_rounded,
              color: Color(0xFFFFD166),
              size: 22,
            ),
          ],
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
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? Colors.white.withOpacity(0.12);
    final glow = glowColor ?? const Color(0xFFFFD166).withOpacity(0.10);

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
                blurRadius: 32,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GoldenOrb extends StatelessWidget {
  final double size;
  final bool reverse;

  const _GoldenOrb({
    required this.size,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: reverse ? -0.45 : 0.35,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: reverse
                ? const [
                    Color(0xFFFF4FD8),
                    Color(0xFFFFD166),
                    Color(0xFF00E5FF),
                    Color(0xFFFF4FD8),
                  ]
                : const [
                    Color(0xFFFFD166),
                    Color(0xFFFF4FD8),
                    Color(0xFF7B2FBE),
                    Color(0xFFFFD166),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD166).withOpacity(0.28),
              blurRadius: 42,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: size * 0.62,
            height: size * 0.62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF160D25).withOpacity(0.90),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoritesBackground extends StatelessWidget {
  final AnimationController controller;

  const _FavoritesBackground({required this.controller});

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
                Color(0xFF140727),
                Color(0xFF24110B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -110 + math.sin(t) * 22,
                right: -80 + math.cos(t) * 18,
                child: const _BlurCircle(
                  size: 290,
                  color: Color(0xFFFFD166),
                ),
              ),
              Positioned(
                top: 180 + math.cos(t) * 24,
                left: -130 + math.sin(t) * 20,
                child: const _BlurCircle(
                  size: 310,
                  color: Color(0xFFFF4FD8),
                ),
              ),
              Positioned(
                bottom: -120 + math.sin(t * 1.3) * 26,
                right: -90 + math.cos(t * 1.1) * 22,
                child: const _BlurCircle(
                  size: 310,
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
      imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
