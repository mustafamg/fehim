import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@injectable
class SurahLearningPathViewModel extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isAudioLoading = false;
  bool get isAudioLoading => _isAudioLoading;
  List<String> _arabicWords = [];
  List<String> get arabicWords => _arabicWords;
  List<String> _englishWords = [];
  List<String> get englishWords => _englishWords;
  int _currentHighlightedWordIndex = -1;
  int get currentHighlightedWordIndex => _currentHighlightedWordIndex;
  int _currentHighlightedTranslationIndex = -1;
  int get currentHighlightedTranslationIndex =>
      _currentHighlightedTranslationIndex;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  Duration _currentAudioPosition = Duration.zero;
  Duration get currentAudioPosition => _currentAudioPosition;
  Duration _totalAudioDuration = Duration.zero;
  Duration get totalAudioDuration => _totalAudioDuration;
  bool _hasFinishedPlaying = false;
  bool get hasFinishedPlaying => _hasFinishedPlaying;
  String? _currentAudioUrl;
  SurahLearningPathViewModel() {
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
    _durationSubscription = _audioPlayer.onDurationChanged.listen((
      newDuration,
    ) {
      _totalAudioDuration = newDuration;
      notifyListeners();
    });
    _positionSubscription = _audioPlayer.onPositionChanged.listen((
      newPosition,
    ) {
      _currentAudioPosition = newPosition;
      _updateHighlights(newPosition);
      notifyListeners();
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _hasFinishedPlaying = true;
      _currentAudioPosition = Duration.zero;
      _updateHighlights(Duration.zero);
      notifyListeners();
    });
  }
  void initDummyData() {
    _isLoading = true;
    notifyListeners();

    _arabicWords = ['مِن', 'شَرِّ', 'مَا', 'خَلَقَ'];
    _englishWords = ['From the evil', 'of what', 'He', 'has created'];

    _currentHighlightedWordIndex = 0;
    _currentHighlightedTranslationIndex = 0;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadVerseData({
    required String arabicText,
    required String translationText,
    required String audioUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    _arabicWords = arabicText.split(' ');

    _englishWords = translationText.split(' ');
    _currentHighlightedWordIndex = 0;
    _currentHighlightedTranslationIndex = 0;
    await _audioPlayer.setSourceUrl(audioUrl);
    _currentAudioUrl = audioUrl;
    _isLoading = false;
    notifyListeners();
  }

  void _updateHighlights(Duration position) {
    if (_totalAudioDuration.inMilliseconds == 0 || _arabicWords.isEmpty) return;
    final progress =
        position.inMilliseconds / _totalAudioDuration.inMilliseconds;
    final newArabicIndex = (progress * _arabicWords.length).floor().clamp(
      0,
      _arabicWords.length - 1,
    );
    final newEnglishIndex = (progress * _englishWords.length).floor().clamp(
      0,
      _englishWords.length - 1,
    );
    if (newArabicIndex != _currentHighlightedWordIndex ||
        newEnglishIndex != _currentHighlightedTranslationIndex) {
      _currentHighlightedWordIndex = newArabicIndex;
      _currentHighlightedTranslationIndex = newEnglishIndex;
    }
  }

  Future<void> resetAudio() async {
    if (_currentAudioUrl != null) {
      await _audioPlayer.stop();
      await _audioPlayer.setSourceUrl(_currentAudioUrl!);
    } else {
      await _audioPlayer.stop();
    }
    _isPlaying = false;
    _hasFinishedPlaying = false;
    _currentAudioPosition = Duration.zero;
    _updateHighlights(Duration.zero);
    notifyListeners();
  }

  Future<void> playAudio() async {
    if (_currentAudioUrl == null) return;

    _isAudioLoading = true;
    notifyListeners();

    try {
      if (_hasFinishedPlaying || _currentAudioPosition == Duration.zero) {
        await _audioPlayer.stop();
        _hasFinishedPlaying = false;
        _currentAudioPosition = Duration.zero;
        _updateHighlights(Duration.zero);
        await _audioPlayer.play(UrlSource(_currentAudioUrl!));
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      // Handle audio loading error
    } finally {
      _isAudioLoading = false;
      notifyListeners();
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> seekAudio(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();

    _audioPlayer.dispose();
    super.dispose();
  }
}
