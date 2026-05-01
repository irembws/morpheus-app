import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dream_detail_screen.dart';
import '../dream_model.dart';
import '../dream_storage_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  List<Dream> _allDreams = [];
  List<Dream> _results = [];
  final _searchController = TextEditingController();
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
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bgController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _loadDreams() async {
    final dreams = await DreamStorageService.loadDreams();
    setState(() {
      _allDreams = dreams;
      _results = dreams;
      _loading = false;
    });
  }

  void _search(String query) {
    final q = query.toLowerCase().trim();

    setState(() {
      if (q.isEmpty) {
        _results = _allDreams;
      } else {
        _results = _allDreams.where((d) {
          return d.title.toLowerCase().contains(q) ||
              d.content.toLowerCase().contains(q) ||
              (d.analysis?.toLowerCase().contains(q) ?? false) ||
              d.symbols.any((s) => s.toLowerCase().contains(q));
        }).toList();
      }
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dream Search',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.52),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rüya Ara',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Başlık, sembol, duygu veya AI yorumunda ara',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.45),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 22),
                              _SearchBox(
                                controller: _searchController,
                                onChanged: _search,
                                onClear: () {
                                  _searchController.clear();
                                  _search('');
                                },
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _loading
                                        ? 'Aranıyor...'
                                        : '${_results.length} sonuç bulundu',
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.42),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty)
                                    Text(
                                      '"${_searchController.text}"',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFFF4FD8)
                                            .withOpacity(0.78),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _loading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFFF4FD8),
                                  ),
                                )
                              : _results.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(26),
                                        child: _GlassCard(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                '🔍',
                                                style: TextStyle(fontSize: 66),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Sonuç bulunamadı',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Başka bir kelime, sembol veya duygu deneyebilirsin.',
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
                                  : ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.fromLTRB(
                                          18, 0, 18, 112),
                                      itemCount: _results.length,
                                      itemBuilder: (context, index) {
                                        final dream = _results[index];
                                        final color =
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
                                            child: _SearchResultCard(
                                              dream: dream,
                                              color: color,
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

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBox({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      borderColor: const Color(0xFFFF4FD8).withOpacity(0.34),
      glowColor: const Color(0xFFFF4FD8).withOpacity(0.22),
      child: SizedBox(
        height: 62,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            return TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: false,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Başlık, içerik, sembol ara...',
                hintStyle: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.36),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white.withOpacity(0.60),
                ),
                suffixIcon: value.text.isNotEmpty
                    ? IconButton(
                        onPressed: onClear,
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withOpacity(0.54),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Dream dream;
  final Color color;

  const _SearchResultCard({
    required this.dream,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: _GlassCard(
        borderColor: color.withOpacity(0.34),
        glowColor: color.withOpacity(0.20),
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
                    const Color(0xFFFF4FD8).withOpacity(0.78),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.38),
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
                        color: color.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: color.withOpacity(0.22)),
                      ),
                      child: Text(
                        '✨ ${dream.emotion}',
                        style: GoogleFonts.inter(
                          color: color,
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
