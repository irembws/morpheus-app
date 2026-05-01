import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main_screen.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _pressed = false;
  bool _obscurePassword = true;
  String? _error;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bgController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final error = await _authService.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _error = error);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
        (route) => false,
      );
    }
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
                      begin: const Offset(0, 0.04),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _entranceController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
                      child: Column(
                        children: [
                          const SizedBox(height: 28),
                          _LogoCard(),
                          const SizedBox(height: 30),
                          _GlassCard(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              children: [
                                _PremiumInput(
                                  controller: _nameController,
                                  hint: 'Ad Soyad',
                                  icon: Icons.person_outline_rounded,
                                ),
                                const SizedBox(height: 14),
                                _PremiumInput(
                                  controller: _emailController,
                                  hint: 'E-posta',
                                  icon: Icons.mail_outline_rounded,
                                ),
                                const SizedBox(height: 14),
                                _PremiumInput(
                                  controller: _passwordController,
                                  hint: 'Şifre',
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  suffix: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white.withOpacity(0.45),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: 14),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF4D6D)
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFFF4D6D)
                                            .withOpacity(0.25),
                                      ),
                                    ),
                                    child: Text(
                                      _error!,
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFFF8FA3),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 18),
                                _PremiumButton(
                                  isLoading: _isLoading,
                                  pressed: _pressed,
                                  onTapDown: () =>
                                      setState(() => _pressed = true),
                                  onTapUp: () =>
                                      setState(() => _pressed = false),
                                  onTapCancel: () =>
                                      setState(() => _pressed = false),
                                  onTap: _isLoading ? null : _register,
                                  text: 'Kayıt Ol',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Zaten hesabın var mı? Giriş yap',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFFFD166),
                                fontWeight: FontWeight.w900,
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

class _LogoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(22),
      borderColor: const Color(0xFFFF4FD8).withOpacity(0.22),
      glowColor: const Color(0xFFFF4FD8).withOpacity(0.20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const _NeonOrb(size: 118),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌙', style: TextStyle(fontSize: 42)),
              const SizedBox(height: 8),
              Text(
                'Morpheus',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Yeni rüya alanını oluştur',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.52),
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

class _PremiumInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;

  const _PremiumInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.zero,
      borderColor: Colors.white.withOpacity(0.13),
      glowColor: const Color(0xFFFF4FD8).withOpacity(0.08),
      child: SizedBox(
        height: 58,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.36),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.white.withOpacity(0.55),
              size: 20,
            ),
            suffixIcon: suffix,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 19),
          ),
        ),
      ),
    );
  }
}

class _PremiumButton extends StatelessWidget {
  final bool isLoading;
  final bool pressed;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;
  final VoidCallback? onTap;
  final String text;

  const _PremiumButton({
    required this.isLoading,
    required this.pressed,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    required this.onTap,
    required this.text,
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
          height: 58,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: pressed
                  ? const [Color(0xFF7B2FBE), Color(0xFFFF4FD8)]
                  : const [Color(0xFFFF4FD8), Color(0xFF7B2FBE)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4FD8).withOpacity(0.42),
                blurRadius: 35,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.4,
                    ),
                  )
                : Text(
                    text,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
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

  const _NeonOrb({required this.size});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.35,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(
            colors: [
              Color(0xFFFF4FD8),
              Color(0xFF7B2FBE),
              Color(0xFF00E5FF),
              Color(0xFFFF4FD8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4FD8).withOpacity(0.28),
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
