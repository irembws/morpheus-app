import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dream_model.dart';
import '../dream_storage_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Dream> _dreams = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDreams();
  }

  Future<void> _loadDreams() async {
    final dreams = await DreamStorageService.loadDreams();
    setState(() {
      _dreams = dreams;
      _loading = false;
    });
  }

  Map<DreamCategory, int> get _categoryCount {
    final map = <DreamCategory, int>{};
    for (final d in _dreams) {
      map[d.category] = (map[d.category] ?? 0) + 1;
    }
    return map;
  }

  Map<int, int> get _last7Days {
    final map = <int, int>{};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final count = _dreams
          .where((d) =>
              d.date.year == day.year &&
              d.date.month == day.month &&
              d.date.day == day.day)
          .length;

      map[6 - i] = count;
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06030D),
      body: Stack(
        children: [
          const _StatsBackground(),
          SafeArea(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF4FD8),
                    ),
                  )
                : _dreams.isEmpty
                    ? const Center(
                        child: Text(
                          "Henüz veri yok",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "İstatistikler",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 24),

                            /// SUMMARY
                            Row(
                              children: [
                                _statCard(
                                    "🌙", _dreams.length.toString(), "Toplam"),
                                const SizedBox(width: 12),
                                _statCard(
                                    "📅",
                                    _dreams
                                        .where((d) =>
                                            DateTime.now()
                                                .difference(d.date)
                                                .inDays <
                                            7)
                                        .length
                                        .toString(),
                                    "Bu hafta"),
                                const SizedBox(width: 12),
                                _statCard(
                                    "✨",
                                    _dreams
                                        .where((d) => d.analysis != null)
                                        .length
                                        .toString(),
                                    "Analiz"),
                              ],
                            ),

                            const SizedBox(height: 32),

                            /// LAST 7 DAYS
                            Text(
                              "Son 7 Gün",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 16),

                            _GlassCard(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: _last7Days.entries.map((e) {
                                  final maxVal = _last7Days.values
                                      .reduce((a, b) => a > b ? a : b);

                                  final height = maxVal == 0
                                      ? 10.0
                                      : (e.value / maxVal) * 120 + 10;

                                  return TweenAnimationBuilder<double>(
                                    duration: Duration(
                                        milliseconds: 400 + e.key * 100),
                                    tween: Tween(begin: 0, end: height),
                                    builder: (context, value, _) {
                                      return Column(
                                        children: [
                                          Container(
                                            width: 22,
                                            height: value,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFFF4FD8),
                                                  Color(0xFF7B2FBE)
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "${e.value}",
                                            style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 10),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: 32),

                            /// CATEGORY
                            if (_categoryCount.isNotEmpty) ...[
                              Text(
                                "Kategori Dağılımı",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _GlassCard(
                                child: Column(
                                  children: _categoryCount.entries.map((e) {
                                    final percent = e.value / _dreams.length;

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(e.key.label,
                                                  style: const TextStyle(
                                                      color: Colors.white70)),
                                              Text("${e.value}",
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: LinearProgressIndicator(
                                              value: percent,
                                              backgroundColor: Colors.white12,
                                              valueColor:
                                                  const AlwaysStoppedAnimation(
                                                      Color(0xFFFF4FD8)),
                                              minHeight: 8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return Expanded(
      child: _GlassCard(
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

/// GLASS CARD
class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// BACKGROUND
class _StatsBackground extends StatelessWidget {
  const _StatsBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF07030D),
            Color(0xFF120727),
            Color(0xFF240B35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            top: -100,
            right: -80,
            child: _BlurCircle(size: 300, color: Color(0xFFFF006E)),
          ),
          Positioned(
            bottom: -120,
            left: -100,
            child: _BlurCircle(size: 280, color: Color(0xFF0066FF)),
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
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
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
