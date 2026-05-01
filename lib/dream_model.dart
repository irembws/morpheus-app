import 'dart:convert';

enum DreamCategory {
  adventure,
  nightmare,
  romantic,
  spiritual,
  mysterious,
  daily,
  other,
}

extension DreamCategoryExtension on DreamCategory {
  String get label {
    switch (this) {
      case DreamCategory.adventure:
        return '🗺 Macera';
      case DreamCategory.nightmare:
        return '😨 Kabus';
      case DreamCategory.romantic:
        return '❤️ Romantik';
      case DreamCategory.spiritual:
        return '✨ Spiritüel';
      case DreamCategory.mysterious:
        return '🔮 Gizemli';
      case DreamCategory.daily:
        return '🌟 Günlük';
      case DreamCategory.other:
        return '💬 Diğer';
    }
  }

  String get emoji {
    switch (this) {
      case DreamCategory.adventure:
        return '🗺';
      case DreamCategory.nightmare:
        return '😨';
      case DreamCategory.romantic:
        return '❤️';
      case DreamCategory.spiritual:
        return '✨';
      case DreamCategory.mysterious:
        return '🔮';
      case DreamCategory.daily:
        return '🌟';
      case DreamCategory.other:
        return '💬';
    }
  }
}

class Dream {
  final String id;
  final String title;
  final String content;
  final DreamCategory category;
  final DateTime date;
  final String? analysis;
  final List<String> symbols;
  final String? emotion;
  final bool isFavorite;

  Dream({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.date,
    this.analysis,
    this.symbols = const [],
    this.emotion,
    this.isFavorite = false,
  });

  Dream copyWith({
    String? id,
    String? title,
    String? content,
    DreamCategory? category,
    DateTime? date,
    String? analysis,
    List<String>? symbols,
    String? emotion,
    bool? isFavorite,
  }) {
    return Dream(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      date: date ?? this.date,
      analysis: analysis ?? this.analysis,
      symbols: symbols ?? this.symbols,
      emotion: emotion ?? this.emotion,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'category': category.index,
        'date': date.toIso8601String(),
        'analysis': analysis,
        'symbols': symbols,
        'emotion': emotion,
        'isFavorite': isFavorite,
      };

  factory Dream.fromJson(Map<String, dynamic> json) => Dream(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        category: DreamCategory.values[json['category']],
        date: DateTime.parse(json['date']),
        analysis: json['analysis'],
        symbols: List<String>.from(json['symbols'] ?? []),
        emotion: json['emotion'],
        isFavorite: json['isFavorite'] ?? false,
      );
}
