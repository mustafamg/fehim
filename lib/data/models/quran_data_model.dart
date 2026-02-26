import 'package:cloud_firestore/cloud_firestore.dart';
class SurahModel {
  final String id;
  final String name;
  final int surahNumber;
  final int totalVerses;
  final String revelationType;
  final Map<String, String> names; 
  final Timestamp createdAt;
  SurahModel({
    required this.id,
    required this.name,
    required this.surahNumber,
    required this.totalVerses,
    required this.revelationType,
    required this.names,
    required this.createdAt,
  });
  factory SurahModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SurahModel(
      id: doc.id,
      name: data['name'] ?? '',
      surahNumber: data['surah_number'] ?? 0,
      totalVerses: data['total_verses'] ?? 0,
      revelationType: data['revelation_type'] ?? '',
      names: Map<String, String>.from(data['names'] ?? {}),
      createdAt: data['created_at'] ?? Timestamp.now(),
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'surah_number': surahNumber,
      'total_verses': totalVerses,
      'revelation_type': revelationType,
      'names': names,
      'created_at': createdAt,
    };
  }
}
class VerseModel {
  final String id;
  final String surahId;
  final int verseNumber;
  final String arabicText;
  final int juzNumber;
  final int hizbNumber;
  final int rubElHizb;
  final String sajda;
  final List<WordModel> words;
  VerseModel({
    required this.id,
    required this.surahId,
    required this.verseNumber,
    required this.arabicText,
    required this.juzNumber,
    required this.hizbNumber,
    required this.rubElHizb,
    required this.sajda,
    required this.words,
  });
  factory VerseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final wordsList = (data['words'] as List<dynamic>?)
        ?.map((word) => WordModel.fromMap(word as Map<String, dynamic>))
        .toList() ?? [];
    return VerseModel(
      id: doc.id,
      surahId: data['surah_id'] ?? '',
      verseNumber: data['verse_number'] ?? 0,
      arabicText: data['arabic_text'] ?? '',
      juzNumber: data['juz_number'] ?? 0,
      hizbNumber: data['hizb_number'] ?? 0,
      rubElHizb: data['rub_el_hizb'] ?? 0,
      sajda: data['sajda'] ?? '',
      words: wordsList,
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'surah_id': surahId,
      'verse_number': verseNumber,
      'arabic_text': arabicText,
      'juz_number': juzNumber,
      'hizb_number': hizbNumber,
      'rub_el_hizb': rubElHizb,
      'sajda': sajda,
      'words': words.map((word) => word.toMap()).toList(),
    };
  }
}
class WordModel {
  final String id;
  final int position;
  final String arabic;
  final Map<String, String> translations; 
  final String? audioUrl;
  final List<String> tajweedRules;
  WordModel({
    required this.id,
    required this.position,
    required this.arabic,
    required this.translations,
    this.audioUrl,
    required this.tajweedRules,
  });
  factory WordModel.fromMap(Map<String, dynamic> data) {
    return WordModel(
      id: data['id'] ?? '',
      position: data['position'] ?? 0,
      arabic: data['arabic'] ?? '',
      translations: Map<String, String>.from(data['translations'] ?? {}),
      audioUrl: data['audio_url'],
      tajweedRules: List<String>.from(data['tajweed_rules'] ?? []),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'position': position,
      'arabic': arabic,
      'translations': translations,
      'audio_url': audioUrl,
      'tajweed_rules': tajweedRules,
    };
  }
}
class PuzzleModel {
  final String id;
  final String verseId;
  final int puzzleNumber; 
  final List<String> arabicWords;
  final List<String> englishWords;
  final List<String> correctOrder; 
  final String difficulty;
  final int points;
  PuzzleModel({
    required this.id,
    required this.verseId,
    required this.puzzleNumber,
    required this.arabicWords,
    required this.englishWords,
    required this.correctOrder,
    required this.difficulty,
    required this.points,
  });
  factory PuzzleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PuzzleModel(
      id: doc.id,
      verseId: data['verse_id'] ?? '',
      puzzleNumber: data['puzzle_number'] ?? 0,
      arabicWords: List<String>.from(data['arabic_words'] ?? []),
      englishWords: List<String>.from(data['english_words'] ?? []),
      correctOrder: List<String>.from(data['correct_order'] ?? []),
      difficulty: data['difficulty'] ?? '',
      points: data['points'] ?? 0,
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'verse_id': verseId,
      'puzzle_number': puzzleNumber,
      'arabic_words': arabicWords,
      'english_words': englishWords,
      'correct_order': correctOrder,
      'difficulty': difficulty,
      'points': points,
    };
  }
}
class UserProgressModel {
  final String id;
  final String userId;
  final String surahId;
  final int currentVerse;
  final int currentPuzzle;
  final List<CompletedPuzzleModel> completedPuzzles;
  final double overallProgress; 
  final Timestamp lastAccessed;
  final Map<String, dynamic> achievements;
  UserProgressModel({
    required this.id,
    required this.userId,
    required this.surahId,
    required this.currentVerse,
    required this.currentPuzzle,
    required this.completedPuzzles,
    required this.overallProgress,
    required this.lastAccessed,
    required this.achievements,
  });
  factory UserProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final completedList = (data['completed_puzzles'] as List<dynamic>?)
        ?.map((puzzle) => CompletedPuzzleModel.fromMap(puzzle as Map<String, dynamic>))
        .toList() ?? [];
    return UserProgressModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      surahId: data['surah_id'] ?? '',
      currentVerse: data['current_verse'] ?? 1,
      currentPuzzle: data['current_puzzle'] ?? 1,
      completedPuzzles: completedList,
      overallProgress: (data['overall_progress'] ?? 0.0).toDouble(),
      lastAccessed: data['last_accessed'] ?? Timestamp.now(),
      achievements: Map<String, dynamic>.from(data['achievements'] ?? {}),
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'surah_id': surahId,
      'current_verse': currentVerse,
      'current_puzzle': currentPuzzle,
      'completed_puzzles': completedPuzzles.map((puzzle) => puzzle.toMap()).toList(),
      'overall_progress': overallProgress,
      'last_accessed': lastAccessed,
      'achievements': achievements,
    };
  }
  double calculateProgress() {
    
    
    
    return overallProgress;
  }
}
class CompletedPuzzleModel {
  final String verseId;
  final int puzzleNumber;
  final Timestamp completedAt;
  final int attempts;
  final int timeInSeconds;
  final int score;
  CompletedPuzzleModel({
    required this.verseId,
    required this.puzzleNumber,
    required this.completedAt,
    required this.attempts,
    required this.timeInSeconds,
    required this.score,
  });
  factory CompletedPuzzleModel.fromMap(Map<String, dynamic> data) {
    return CompletedPuzzleModel(
      verseId: data['verse_id'] ?? '',
      puzzleNumber: data['puzzle_number'] ?? 0,
      completedAt: data['completed_at'] ?? Timestamp.now(),
      attempts: data['attempts'] ?? 0,
      timeInSeconds: data['time_in_seconds'] ?? 0,
      score: data['score'] ?? 0,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'verse_id': verseId,
      'puzzle_number': puzzleNumber,
      'completed_at': completedAt,
      'attempts': attempts,
      'time_in_seconds': timeInSeconds,
      'score': score,
    };
  }
}
