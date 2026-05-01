import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dream_model.dart';
import 'dream_storage_service.dart';
import 'gemini_service.dart';

class DreamDetailScreen extends StatefulWidget {
  final Dream dream;
  const DreamDetailScreen({super.key, required this.dream});

  @override
  State<DreamDetailScreen> createState() => _DreamDetailScreenState();
}

class _DreamDetailScreenState extends State<DreamDetailScreen>
    with SingleTickerProviderStateMixin {
  late Dream _dream;
  bool _analyzing = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _dream = widget.dream;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    setState(() => _analyzing = true);

    try {
      final result = await GeminiService.analyzeDream(_dream);

      final updated = _dream.copyWith(
        analysis: result.analysis,
        symbols: result.symbols,
        emotion: result.emotion,
      );

      await DreamStorageService.updateDream(updated);

      if (!mounted) return;
      setState(() {
        _dream = updated;
        _analyzing = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _analyzing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analiz hatası. Tekrar dene.'),
          backgroundColor: Color(0xFF7B2FBE),
        ),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    final updated = _dream.copyWith(isFavorite: !_dream.isFavorite);
    await DreamStorageService.updateDream(updated);
    setState(() => _dream = updated);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF140B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Rüyayı sil?',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Bu rüya kalıcı olarak silinecek.',
          style: GoogleFonts.inter(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sil',
              style: TextStyle(color: Color(0xFFFF4D6D)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DreamStorageService.deleteDream(_dream.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _edit() async {
    final titleController = TextEditingController(text: _dream.title);
    final contentController = TextEditingController(text: _dream.content);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10071C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Rüyayı düzenle',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Başlık'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Rüya içeriği'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4FD8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    final updated = _dream.copyWith(
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                    );

                    await DreamStorageService.updateDream(updated);

                    if (!mounted) return;
                    setState(() => _dream = updated);
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    'Kaydet',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFFF4FD8)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
    final catColor = _categoryColor(_dream.category);

    return Scaffold(
      backgroundColor: const Color(0xFF06030D),
      body: Stack(
        children: [
          const _DetailBackground(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      children: [
                        _buildTopBar(catColor),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHero(catColor),
                                const SizedBox(height: 18),
                                _buildContentCard(),
                                const SizedBox(height: 18),
                                _dream.analysis == null
                                    ? _buildAnalyzeButton(catColor)
                                    : _buildAnalysis(catColor),
                              ],
                            ),
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

  Widget _buildTopBar(Color catColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _dream.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _CircleButton(
            icon: _dream.isFavorite
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            color: _dream.isFavorite ? const Color(0xFFFFD166) : Colors.white70,
            glow: _dream.isFavorite ? const Color(0xFFFFD166) : null,
            onTap: _toggleFavorite,
          ),
          const SizedBox(width: 8),
          _CircleButton(icon: Icons.edit_outlined, onTap: _edit),
          const SizedBox(width: 8),
          _CircleButton(
            icon: Icons.delete_outline_rounded,
            color: const Color(0xFFFF4D6D),
            onTap: _delete,
          ),
        ],
      ),
    );
  }

  Widget _buildHero(Color catColor) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      borderColor: catColor.withOpacity(0.26),
      glowColor: catColor.withOpacity(0.16),
      child: SizedBox(
        height: 230,
        child: Stack(
          children: [
            Positioned(
              top: -46,
              right: -28,
              child: _NeonOrb(size: 150, color: catColor),
            ),
            Positioned(
              bottom: -60,
              left: -34,
              child: _NeonOrb(size: 140, color: const Color(0xFFFF4FD8)),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Pill(
                    text: _dream.category.label,
                    color: catColor,
                    emoji: _dream.category.emoji,
                  ),
                  const Spacer(),
                  Text(
                    _dream.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 0.98,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatDate(_dream.date),
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.54),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

  Widget _buildContentCard() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: '🌙', title: 'Rüya'),
          const SizedBox(height: 12),
          Text(
            _dream.content,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.72),
              fontSize: 15,
              height: 1.65,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton(Color catColor) {
    return GestureDetector(
      onTap: _analyzing ? null : _analyze,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: _analyzing
                ? [
                    catColor.withOpacity(0.35),
                    const Color(0xFFFF4FD8).withOpacity(0.22),
                  ]
                : [
                    catColor,
                    const Color(0xFFFF4FD8),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color:
                  const Color(0xFFFF4FD8).withOpacity(_analyzing ? 0.10 : 0.34),
              blurRadius: 34,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: _analyzing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI rüyanı çözümlüyor...',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                )
              : Text(
                  '✨ AI ile rüyanı yorumla',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAnalysis(Color catColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_dream.emotion != null) ...[
          _GlassCard(
            borderColor: const Color(0xFFFFD166).withOpacity(0.28),
            glowColor: const Color(0xFFFFD166).withOpacity(0.12),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _dream.emotion!,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFFD166),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (_dream.symbols.isNotEmpty) ...[
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(icon: '🔑', title: 'Semboller'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _dream.symbols
                      .map(
                        (symbol) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: catColor.withOpacity(0.24),
                            ),
                          ),
                          child: Text(
                            symbol,
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        _GlassCard(
          borderColor: catColor.withOpacity(0.24),
          glowColor: catColor.withOpacity(0.12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(icon: '🧠', title: 'AI Yorumu'),
              const SizedBox(height: 12),
              Text(
                _dream.analysis ?? '',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.74),
                  fontSize: 14,
                  height: 1.7,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _analyzing ? null : _analyze,
          child: _GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _analyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white70,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                const SizedBox(width: 8),
                Text(
                  _analyzing ? 'Yeniden yorumlanıyor...' : 'Tekrar yorumla',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color? glow;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.color = Colors.white70,
    this.glow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                if (glow != null)
                  BoxShadow(
                    color: glow!.withOpacity(0.28),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  final String emoji;

  const _Pill({
    required this.text,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(0.26)),
      ),
      child: Text(
        '$emoji  $text',
        style: GoogleFonts.inter(
          color: Colors.white.withOpacity(0.86),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$icon  $title',
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w900,
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
    final glow = glowColor ?? const Color(0xFFFF4FD8).withOpacity(0.10);

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
                blurRadius: 34,
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

class _NeonOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _NeonOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.35,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              color,
              const Color(0xFFFF4FD8),
              const Color(0xFF00E5FF),
              color,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.30),
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

class _DetailBackground extends StatelessWidget {
  const _DetailBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF07030D),
            Color(0xFF120727),
            Color(0xFF2A0A34),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: _BlurCircle(
              size: 280,
              color: Color(0xFFFF006E),
            ),
          ),
          Positioned(
            top: 120,
            left: -120,
            child: _BlurCircle(
              size: 300,
              color: Color(0xFF0066FF),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -90,
            child: _BlurCircle(
              size: 300,
              color: Color(0xFF7B2FBE),
            ),
          ),
        ],
      ),
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
          color: color.withOpacity(0.28),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
