import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dream_storage_service.dart';
import '../dream_model.dart';
import '../dream_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Dream> _dreams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDreams();
  }

  Future<void> _loadDreams() async {
    final dreams = await DreamStorageService.loadDreams();
    setState(() {
      _dreams = dreams;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF03010A), Color(0xFF1A0533)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🌙 MORPHEUS',
                            style: GoogleFonts.cinzel(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
                        Text('Rüya Günlüğün',
                            style: GoogleFonts.raleway(
                              color: Colors.white54,
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF7B2FBE)))
                    : _dreams.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🌙',
                                    style: TextStyle(fontSize: 80)),
                                const SizedBox(height: 20),
                                Text('HENÜZ RÜYA YOK',
                                    style: GoogleFonts.cinzel(
                                      color: Colors.white,
                                      fontSize: 18,
                                      letterSpacing: 2,
                                    )),
                                const SizedBox(height: 8),
                                Text('İlk rüyanı kaydet ve\nyorumlatmaya başla',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.raleway(
                                      color: Colors.white38,
                                      fontSize: 14,
                                    )),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _dreams.length,
                            itemBuilder: (context, index) {
                              final dream = _dreams[index];
                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              DreamDetailScreen(dream: dream)));
                                  _loadDreams();
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A0533)
                                        .withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF7B2FBE)
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(dream.title,
                                          style: GoogleFonts.cinzel(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      const SizedBox(height: 8),
                                      Text(dream.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.raleway(
                                            color: Colors.white54,
                                            fontSize: 13,
                                          )),
                                    ],
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
    );
  }
}
