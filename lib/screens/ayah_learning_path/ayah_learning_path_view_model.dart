import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
class AyahLearningPathViewModel extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, dynamic> verse;
  List<Map<String, dynamic>> _words = [];
  List<Map<String, dynamic>> get words => _words;
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  bool _hasFinishedPlaying = false;
  bool get hasFinishedPlaying => _hasFinishedPlaying;
  double _audioProgress = 0.0;
  double get audioProgress => _audioProgress;
  final Set<int> _finishedWords = {};
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;
  AyahLearningPathViewModel(this.verse) {
    _initWords();
    _setupAudioPlayer();
  }
  void _initWords() {
    if (verse.containsKey('words') && verse['words'] is List) {
      _words = List<Map<String, dynamic>>.from(verse['words']);
    }
  }
  void _setupAudioPlayer() {
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      _audioPlayer.getDuration().then((duration) {
        if (duration != null && duration.inMilliseconds > 0) {
          _audioProgress = position.inMilliseconds / duration.inMilliseconds;
          notifyListeners();
        }
      });
    });
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _hasFinishedPlaying = true;
      _audioProgress = 1.0;
      _finishedWords.add(_currentIndex);
      notifyListeners();
    });
  }
  bool isWordFinished(int index) {
    return _finishedWords.contains(index);
  }
  void setCurrentIndex(int index) {
    if (index == _currentIndex) return;
    _currentIndex = index;
    _hasFinishedPlaying = false;
    _audioProgress = 0.0;
    _audioPlayer.stop();
    notifyListeners();
  }
  Future<void> pauseCurrentWordAudio() async {
    await _audioPlayer.pause();
  }
  Future<void> playCurrentWordAudio() async {
    if (_words.isEmpty) return;
    final currentWord = _words[_currentIndex];
    final audioUrl = currentWord['audioUrl'] as String?;
    if (audioUrl == null) return;
    try {
      await _audioPlayer.stop();
    } catch (_) {
      
    }
    _hasFinishedPlaying = false;
    _finishedWords.remove(_currentIndex);
    _audioProgress = 0.0;
    notifyListeners();
    await _audioPlayer.play(UrlSource(audioUrl));
  }
  void goToNextWord() {
    if (_currentIndex < _words.length - 1) {
      setCurrentIndex(_currentIndex + 1);
    }
  }
  void goToPreviousWord() {
    if (_currentIndex > 0) {
      setCurrentIndex(_currentIndex - 1);
    }
  }
  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
