import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

class WordPair {
  final String englishWord;
  final String arabicWord;
  WordPair({required this.englishWord, required this.arabicWord});
}

@Injectable()
class ConnnectMeaningViewModel extends ChangeNotifier {
  final List<WordPair> _allWordPairs = [];

  final List<String> _availableDraggableWords = [];
  List<String> get availableDraggableWords => _availableDraggableWords;

  final Map<String, String?> _matchedWords = {};
  Map<String, String?> get matchedWords => _matchedWords;

  String? _failedDragTargetEnglishWord;
  String? get failedDragTargetEnglishWord => _failedDragTargetEnglishWord;
  String? _failedDragTargetArabicWord;
  String? get failedDragTargetArabicWord => _failedDragTargetArabicWord;
  int _errorTick = 0;
  int get errorTick => _errorTick;

  int _currentPage = 0;
  int get currentPage => _currentPage;

  int get totalPages => (_allWordPairs.length / 4).ceil();

  List<WordPair> get currentPageWordPairs {
    final startIndex = _currentPage * 4;
    final endIndex = (startIndex + 4).clamp(0, _allWordPairs.length);
    return _allWordPairs.sublist(startIndex, endIndex);
  }

  Map<String, String?> get currentPageMatchedWords {
    final currentPageWords = currentPageWordPairs;
    final Map<String, String?> pageMatchedWords = {};
    for (final pair in currentPageWords) {
      pageMatchedWords[pair.englishWord] = _matchedWords[pair.englishWord];
    }
    return pageMatchedWords;
  }

  List<String> get currentPageAvailableWords {
    final currentPageWords = currentPageWordPairs;
    final List<String> pageAvailableWords = [];
    for (final pair in currentPageWords) {
      if (_matchedWords[pair.englishWord] == null) {
        pageAvailableWords.add(pair.arabicWord);
      }
    }
    return pageAvailableWords;
  }

  bool get isCurrentPageComplete {
    final currentPageWords = currentPageWordPairs;
    for (final pair in currentPageWords) {
      if (_matchedWords[pair.englishWord] == null) {
        return false;
      }
    }
    return true;
  }

  bool get isAllMatched {
    if (_matchedWords.isEmpty) return false;
    return !_matchedWords.values.contains(null);
  }

  bool get canGoNext => _currentPage < totalPages - 1;
  bool get canGoPrevious => _currentPage > 0;

  void init(List<Map<String, dynamic>> words) {
    _allWordPairs.clear();
    _availableDraggableWords.clear();
    _matchedWords.clear();
    _failedDragTargetEnglishWord = null;
    _currentPage = 0;
    for (var word in words) {
      final english = word['translation']?['en'] as String?;
      final arabic = word['arabic'] as String?;
      if (english != null &&
          arabic != null &&
          english.isNotEmpty &&
          arabic.isNotEmpty) {
        _allWordPairs.add(WordPair(englishWord: english, arabicWord: arabic));
        _matchedWords[english] = null;
      }
    }

    _updateCurrentPageWords();
    notifyListeners();
  }

  void _updateCurrentPageWords() {
    _availableDraggableWords.clear();
    final pageWords = currentPageAvailableWords;
    _availableDraggableWords.addAll(pageWords);
    _availableDraggableWords.shuffle();
  }

  void goToNextPage() {
    if (canGoNext) {
      _currentPage++;
      _updateCurrentPageWords();
      notifyListeners();
    }
  }

  void goToPreviousPage() {
    if (canGoPrevious) {
      _currentPage--;
      _updateCurrentPageWords();
      notifyListeners();
    }
  }

  bool onWordDropped(String arabicWord, String englishTargetWord) {
    final correctPair = _allWordPairs.firstWhere(
      (pair) => pair.englishWord == englishTargetWord,
      orElse: () => WordPair(englishWord: '', arabicWord: ''),
    );
    if (correctPair.arabicWord == arabicWord) {
      _matchedWords[englishTargetWord] = arabicWord;
      _availableDraggableWords.remove(arabicWord);
      _failedDragTargetEnglishWord = null;
      _failedDragTargetArabicWord = null;
      notifyListeners();
      return true;
    } else {
      _failedDragTargetEnglishWord = englishTargetWord;
      _failedDragTargetArabicWord = arabicWord;
      _errorTick++;
      HapticFeedback.heavyImpact();
      HapticFeedback.vibrate();
      notifyListeners();

      Future.delayed(const Duration(seconds: 1), () {
        if (_failedDragTargetEnglishWord == englishTargetWord) {
          _failedDragTargetEnglishWord = null;
          _failedDragTargetArabicWord = null;
          notifyListeners();
        }
      });
      return false;
    }
  }
}
