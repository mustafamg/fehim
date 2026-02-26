import 'package:flutter/material.dart';
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
  bool get isAllMatched {
    if (_matchedWords.isEmpty) return false;
    return !_matchedWords.values.contains(null);
  }
  void init(List<Map<String, dynamic>> words) {
    _allWordPairs.clear();
    _availableDraggableWords.clear();
    _matchedWords.clear();
    _failedDragTargetEnglishWord = null;
    for (var word in words) {
      final english = word['translation']?['en'] as String?;
      final arabic = word['arabic'] as String?;
      if (english != null &&
          arabic != null &&
          english.isNotEmpty &&
          arabic.isNotEmpty) {
        _allWordPairs.add(WordPair(englishWord: english, arabicWord: arabic));
        _availableDraggableWords.add(arabic);
        _matchedWords[english] = null;
      }
    }
    
    _availableDraggableWords.shuffle();
    notifyListeners();
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
      notifyListeners();
      return true;
    } else {
      
      _failedDragTargetEnglishWord = englishTargetWord;
      notifyListeners();
      
      Future.delayed(const Duration(seconds: 1), () {
        if (_failedDragTargetEnglishWord == englishTargetWord) {
          _failedDragTargetEnglishWord = null;
          notifyListeners();
        }
      });
      return false;
    }
  }
}
