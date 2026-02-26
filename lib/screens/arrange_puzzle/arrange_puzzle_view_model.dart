import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../services/firestore_service.dart';

@Injectable()
class ArrangePuzzleViewModel extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirestoreService _firestoreService = FirestoreService();

  // Stream subscriptions
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;

  // User and surah tracking
  String _userId = 'test_user_1'; // TODO: Get from auth
  String _surahId = 'al_falaq'; // TODO: Pass from screen
  int _verseNumber = 1; // TODO: Pass from screen

  final List<String> _originalWords = [];
  List<String> _draggableWords = [];
  List<String?> _matchedWords = [];

  String? _failedWord;
  int? _failedIndex;

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
    // Update user/surah tracking if provided
    if (userId != null) _userId = userId;
    if (surahId != null) _surahId = surahId;
    if (verseNumber != null) _verseNumber = verseNumber;

    _originalWords.clear();
    _draggableWords.clear();
    _matchedWords.clear();

    // Extract Arabic words from the verse data
    for (var wordData in words) {
      if (wordData.containsKey('arabic')) {
        _originalWords.add(wordData['arabic'] as String);
      }
    }

    // Create draggable words (shuffled copy)
    _draggableWords = List.from(_originalWords)..shuffle();
    _matchedWords = List.filled(_originalWords.length, null);

    // Load audio if URL is provided
    if (audioUrl.isNotEmpty) {
      _audioPlayer.setSourceUrl(audioUrl);
    }

    notifyListeners();
  }

  Future<void> toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  void seekAudio(Duration position) {
    _audioPlayer.seek(position);
  }

  void onWordDropped(String word, int targetIndex) {
    // If the slot is already filled, do nothing
    if (_matchedWords[targetIndex] != null) return;

    // Check if the word is correct for this specific slot
    if (_originalWords[targetIndex] == word) {
      // Correct match
      _matchedWords[targetIndex] = word;
      _draggableWords.remove(word);
      _failedWord = null;
      _failedIndex = null;
      notifyListeners();
    } else {
      // Incorrect match
      _failedWord = word;
      _failedIndex = targetIndex;
      notifyListeners();

      // Reset the error state after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (_failedWord == word && _failedIndex == targetIndex) {
          _failedWord = null;
          _failedIndex = null;
          notifyListeners();
        }
      });
    }
  }

  /// Updates the user's progress in Firebase when the puzzle is completed
  Future<void> updateProgress() async {
    try {
      // Get current progress from Firestore
      final currentProgress = await _firestoreService.getUserProgress(
        _userId,
        _surahId,
      );

      int completedVerses = currentProgress['completedVerses'] as int? ?? 0;
      int currentVerse = currentProgress['currentVerse'] as int? ?? 1;

      // Only update if this verse hasn't been completed yet
      if (_verseNumber > completedVerses) {
        completedVerses = _verseNumber;
        currentVerse = _verseNumber + 1;

        // Update Firestore
        await _firestoreService.updateUserProgress(
          _userId,
          _surahId,
          completedVerses,
          currentVerse,
        );
      }
    } catch (e) {
      // Could add error handling here if needed
      print('Error updating progress: $e');
    }
  }

  @override
  void dispose() {
    // Cancel all stream subscriptions
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerCompleteSubscription?.cancel();

    // Dispose audio player
    _audioPlayer.dispose();
    super.dispose();
  }
}
