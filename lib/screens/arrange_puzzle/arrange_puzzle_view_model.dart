import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../services/firestore_service.dart';
@Injectable()
class ArrangePuzzleViewModel extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirestoreService _firestoreService = FirestoreService();
  
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;
  
  String _userId = 'test_user_1'; 
  String _surahId = 'al_falaq'; 
  int _verseNumber = 1; 
  final List<String> _originalWords = [];
  List<String> _draggableWords = [];
  List<String?> _matchedWords = [];
  String? _failedWord;
  int? _failedIndex;
  String? _error;
  String? _audioUrl;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  List<String> get draggableWords => _draggableWords;
  List<String?> get matchedWords => _matchedWords;
  String? get failedWord => _failedWord;
  int? get failedIndex => _failedIndex;
  String? get error => _error;
  void setError(String error) {
    _error = error;
    notifyListeners();
  }
  bool get isAllMatched =>
      _matchedWords.isNotEmpty && !_matchedWords.contains(null);
  ArrangePuzzleViewModel() {
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    });
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      _isPlaying = false;
      _currentPosition = Duration.zero;
      notifyListeners();
    });
  }
  void init(
    List<Map<String, dynamic>> words,
    String audioUrl, {
    String? userId,
    String? surahId,
    int? verseNumber,
  }) {
    
    _audioUrl = audioUrl;
    
    if (userId != null) _userId = userId;
    if (surahId != null) _surahId = surahId;
    if (verseNumber != null) _verseNumber = verseNumber;
    _originalWords.clear();
    _draggableWords.clear();
    _matchedWords.clear();
    
    for (var wordData in words) {
      if (wordData.containsKey('arabic')) {
        _originalWords.add(wordData['arabic'] as String);
      }
    }
    
    _draggableWords = List.from(_originalWords)..shuffle();
    _matchedWords = List.filled(_originalWords.length, null);
    
    if (_audioUrl != null && _audioUrl!.isNotEmpty) {
      _audioPlayer.setSourceUrl(_audioUrl!);
    }
    notifyListeners();
  }
  Future<void> toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_audioUrl != null && _audioUrl!.isNotEmpty) {
        await _audioPlayer.play(UrlSource(_audioUrl!));
      }
    }
  }
  void seekAudio(Duration position) {
    _audioPlayer.seek(position);
  }
  void onWordDropped(String word, int targetIndex) {
    
    if (_matchedWords[targetIndex] != null) return;
    
    if (_originalWords[targetIndex] == word) {
      
      _matchedWords[targetIndex] = word;
      _draggableWords.remove(word);
      _failedWord = null;
      _failedIndex = null;
      notifyListeners();
    } else {
      
      _failedWord = word;
      _failedIndex = targetIndex;
      notifyListeners();
      
      Future.delayed(const Duration(seconds: 1), () {
        if (_failedWord == word && _failedIndex == targetIndex) {
          _failedWord = null;
          _failedIndex = null;
          notifyListeners();
        }
      });
    }
  }
  
  Future<void> updateProgress() async {
    try {
      
      final currentProgress = await _firestoreService.getUserProgress(
        _userId,
        _surahId,
      );
      int completedVerses = currentProgress['completedVerses'] as int? ?? 0;
      int currentVerse = currentProgress['currentVerse'] as int? ?? 1;
      
      if (_verseNumber > completedVerses) {
        completedVerses = _verseNumber;
        currentVerse = _verseNumber + 1;
        
        await _firestoreService.updateUserProgress(
          _userId,
          _surahId,
          completedVerses,
          currentVerse,
        );
      } else {}
    } catch (e) {
      
    }
  }
  @override
  void dispose() {
    
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    
    _audioPlayer.dispose();
    super.dispose();
  }
}
