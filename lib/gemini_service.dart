import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dream_model.dart';

class DreamAnalysisResult {
  final String analysis;
  final List<String> symbols;
  final String emotion;

  DreamAnalysisResult({
    required this.analysis,
    required this.symbols,
    required this.emotion,
  });
}

class GeminiService {
  static const _apiKey = 'YOUR_API_KEY';

  static Future<DreamAnalysisResult> analyzeDream(Dream dream) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );

      final prompt = '''
Sen bir rüya yorumcususun. Aşağıdaki rüyayı analiz et ve Türkçe yanıt ver.

Rüya Başlığı: ${dream.title}
Rüya İçeriği: ${dream.content}

Sadece JSON döndür. Başka hiçbir açıklama yazma.

{
  "analysis": "Rüyanın detaylı yorumu buraya",
  "symbols": ["sembol1", "sembol2", "sembol3"],
  "emotion": "Ana duygu"
}
''';

      final response = await model.generateContent([
        Content.text(prompt),
      ]);

      final text = response.text ?? '';

      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}') + 1;

      if (jsonStart == -1 || jsonEnd == 0) {
        return DreamAnalysisResult(
          analysis:
              'AI yanıt verdi ama yorum formatı bozuldu. Lütfen tekrar dene.',
          symbols: [],
          emotion: 'Belirsiz',
        );
      }

      final jsonStr = text.substring(jsonStart, jsonEnd);
      final Map<String, dynamic> data = jsonDecode(jsonStr);

      final analysis = data['analysis']?.toString() ?? 'Analiz yapılamadı';
      final emotion = data['emotion']?.toString() ?? 'Belirsiz';

      final symbols = data['symbols'] is List
          ? List<String>.from(
              data['symbols'].map((item) => item.toString()),
            )
          : <String>[];

      return DreamAnalysisResult(
        analysis: analysis,
        symbols: symbols,
        emotion: emotion,
      );
    } catch (e) {
      final errorMessage = e.toString();

      if (errorMessage.contains('503') ||
          errorMessage.contains('UNAVAILABLE') ||
          errorMessage.contains('high demand')) {
        return DreamAnalysisResult(
          analysis:
              'AI şu anda yoğunluk nedeniyle cevap veremiyor. Lütfen birkaç saniye sonra tekrar dene.',
          symbols: [],
          emotion: 'Belirsiz',
        );
      }

      if (errorMessage.contains('API key')) {
        return DreamAnalysisResult(
          analysis:
              'AI bağlantısı için API anahtarında bir sorun var. Lütfen ayarları kontrol et.',
          symbols: [],
          emotion: 'Belirsiz',
        );
      }

      return DreamAnalysisResult(
        analysis: 'Rüya analizi oluşturulamadı. Lütfen tekrar dene.',
        symbols: [],
        emotion: 'Belirsiz',
      );
    }
  }
}
