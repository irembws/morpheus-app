import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _authService = AuthService();

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
    _bgController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final email = user?.email ?? 'Kullanıcı';
    final initial =
        email.isNotEmpty ? email.substring(0, 1).toUpperCase() : '?';

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
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 112),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.52),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Profil',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _ProfileHero(
                            initial: initial,
                            email: email,
                          ),
                          const SizedBox(height: 24),
                          _SectionTitle('Hesabım'),
                          const SizedBox(height: 12),
                          _GlassCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                _ProfileTile(
                                  icon: Icons.email_outlined,
                                  title: 'E-posta',
                                  value: email,
                                ),
                                _DividerLine(),
                                const _ProfileTile(
                                  icon: Icons.verified_user_outlined,
                                  title: 'Üyelik',
                                  value: 'Aktif',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          _SectionTitle('Ayarlar'),
                          const SizedBox(height: 12),
                          _GlassCard(
                            padding: EdgeInsets.zero,
                            child: const Column(
                              children: [
                                _ProfileTile(
                                  icon: Icons.notifications_none_rounded,
                                  title: 'Bildirimler',
                                  value: 'Açık',
                                ),
                                _DividerLine(),
                                _ProfileTile(
                                  icon: Icons.language_rounded,
                                  title: 'Dil',
                                  value: 'Türkçe',
                                ),
                                _DividerLine(),
                                _ProfileTile(
                                  icon: Icons.info_outline_rounded,
                                  title: 'Hakkında',
                                  value: 'v1.0.0',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 26),
                          GestureDetector(
                            onTap: _logout,
                            onTapDown: (_) => setState(() => _pressed = true),
                            onTapUp: (_) => setState(() => _pressed = false),
                            onTapCancel: () => setState(() => _pressed = false),
                            child: AnimatedScale(
                              scale: _pressed ? 0.97 : 1,
                              duration: const Duration(milliseconds: 120),
                              curve: Curves.easeOut,
                              child: Container(
                                height: 58,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF4D6D),
                                      Color(0xFFFF4FD8),
                                      Color(0xFF7B2FBE),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF4D6D)
                                          .withOpacity(0.35),
                                      blurRadius: 32,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Çıkış Yap',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final String initial;
  final String email;

  const _ProfileHero({
    required this.initial,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      borderColor: const Color(0xFFFF4FD8).withOpacity(0.24),
      glowColor: const Color(0xFFFF4FD8).withOpacity(0.18),
      child: SizedBox(
        height: 190,
        child: Stack(
          children: [
            Positioned(
              top: -54,
              right: -38,
              child: _NeonOrb(size: 160),
            ),
            Positioned(
              bottom: -58,
              left: -38,
              child: _NeonOrb(size: 140, reverse: true),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF4FD8),
                          Color(0xFF7B2FBE),
                          Color(0xFF00E5FF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF4FD8).withOpacity(0.35),
                          blurRadius: 32,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Morpheus hesabın aktif',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.46),
                      fontSize: 12,
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
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        color: const Color(0xFFFFD166),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFFFF4FD8),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white.withOpacity(0.74),
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 170),
        child: Text(
          value,
          textAlign: TextAlign.right,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.42),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      color: Colors.white.withOpacity(0.07),
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
