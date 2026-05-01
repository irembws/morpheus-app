import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import 'dream_model.dart';
import 'dream_storage_service.dart';

class AddDreamScreen extends StatefulWidget {
  const AddDreamScreen({super.key});

  @override
  State<AddDreamScreen> createState() => _AddDreamScreenState();
}

class _AddDreamScreenState extends State<AddDreamScreen>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  DreamCategory _selectedCategory = DreamCategory.other;

  bool _saving = false;
  bool _pressed = false;

  late final AnimationController _bgController;
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();

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
    _titleController.dispose();
    _contentController.dispose();
    _bgController.dispose();
    _entranceController.dispose();
    super.dispose();
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

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen başlık ve rüya içeriğini gir.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFF7B2FBE),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final dream = Dream(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory,
      date: DateTime.now(),
    );

    await DreamStorageService.addDream(dream);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = _categoryColor(_selectedCategory);

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
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _entranceController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: Column(
                      children: [
                        _TopBar(onBack: () => Navigator.pop(context)),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(22, 12, 22, 34),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _HeroCard(selectedCategory: _selectedCategory),
                                const SizedBox(height: 22),
                                _SectionTitle(
                                  icon: '✦',
                                  title: 'Rüya Başlığı',
                                ),
                                const SizedBox(height: 10),
                                _PremiumInput(
                                  controller: _titleController,
                                  hint: 'Rüyana bir isim ver...',
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 22),
                                _SectionTitle(
                                  icon: '◈',
                                  title: 'Kategori',
                                ),
                                const SizedBox(height: 12),
                                _CategorySelector(
                                  selectedCategory: _selectedCategory,
                                  onSelected: (cat) {
                                    setState(() => _selectedCategory = cat);
                                  },
                                  categoryColor: _categoryColor,
                                ),
                                const SizedBox(height: 22),
                                _SectionTitle(
                                  icon: '☁',
                                  title: 'Rüyanı Anlat',
                                ),
                                const SizedBox(height: 10),
                                _PremiumInput(
                                  controller: _contentController,
                                  hint:
                                      'Rüyanda ne oldu? Ne gördün, ne hissettin?\n\nNe kadar detay verirsen AI yorumu o kadar iyi olur...',
                                  maxLines: 10,
                                ),
                                const SizedBox(height: 28),
                                _PremiumSaveButton(
                                  saving: _saving,
                                  pressed: _pressed,
                                  color: selectedColor,
                                  onTap: _saving ? null : _save,
                                  onTapDown: () =>
                                      setState(() => _pressed = true),
                                  onTapUp: () =>
                                      setState(() => _pressed = false),
                                  onTapCancel: () =>
                                      setState(() => _pressed = false),
                                ),
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
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yeni Rüya',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                'Hatırladıklarını kaydet',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final DreamCategory selectedCategory;

  const _HeroCard({required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      borderColor: const Color(0xFFFF4FD8).withOpacity(0.24),
      glowColor: const Color(0xFFFF4FD8).withOpacity(0.18),
      child: SizedBox(
        height: 185,
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -36,
              child: _NeonOrb(size: 160),
            ),
            Positioned(
              bottom: -55,
              left: -35,
              child: _NeonOrb(size: 135, reverse: true),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Pill(text: 'DREAM ENTRY'),
                  const Spacer(),
                  Text(
                    'Rüyanı\nkaydet',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                      letterSpacing: -1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${selectedCategory.emoji} ${selectedCategory.label} kategorisi seçili',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.58),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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

class _PremiumInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _PremiumInput({
    required this.controller,
    required this.hint,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      borderColor: Colors.white.withOpacity(0.13),
      glowColor: const Color(0xFFFF4FD8).withOpacity(0.08),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: maxLines == 1 ? 1 : 7,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 14,
          height: 1.55,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.34),
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
        textCapitalization: TextCapitalization.sentences,
        cursorColor: const Color(0xFFFF4FD8),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final DreamCategory selectedCategory;
  final ValueChanged<DreamCategory> onSelected;
  final Color Function(DreamCategory) categoryColor;

  const _CategorySelector({
    required this.selectedCategory,
    required this.onSelected,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: DreamCategory.values.map((cat) {
        final selected = selectedCategory == cat;
        final color = categoryColor(cat);

        return GestureDetector(
          onTap: () => onSelected(cat),
          child: AnimatedScale(
            scale: selected ? 1.04 : 1,
            duration: const Duration(milliseconds: 160),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(
                        colors: [
                          color.withOpacity(0.95),
                          const Color(0xFFFF4FD8).withOpacity(0.85),
                        ],
                      )
                    : null,
                color: selected ? null : Colors.white.withOpacity(0.075),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: selected
                      ? Colors.white.withOpacity(0.24)
                      : Colors.white.withOpacity(0.12),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.36),
                          blurRadius: 24,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                '${cat.emoji} ${cat.label}',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(selected ? 0.98 : 0.68),
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PremiumSaveButton extends StatelessWidget {
  final bool saving;
  final bool pressed;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;

  const _PremiumSaveButton({
    required this.saving,
    required this.pressed,
    required this.color,
    required this.onTap,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapCancel,
      child: AnimatedScale(
        scale: pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 62,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            gradient: LinearGradient(
              colors: pressed
                  ? [
                      const Color(0xFF7B2FBE),
                      color,
                      const Color(0xFFFF4FD8),
                    ]
                  : [
                      color,
                      const Color(0xFFFF4FD8),
                      const Color(0xFF7B2FBE),
                    ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4FD8).withOpacity(0.40),
                blurRadius: 35,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.4,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🌙', style: TextStyle(fontSize: 19)),
                      const SizedBox(width: 10),
                      Text(
                        'Rüyayı Kaydet',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
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
        color: Colors.white.withOpacity(0.82),
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.72),
            size: 19,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withOpacity(0.13)),
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
