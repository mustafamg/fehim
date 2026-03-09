import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:holy_quran/main.dart';
import 'package:holy_quran/services/audio_cache_service.dart';
import 'package:injectable/injectable.dart';

@injectable
class SurahLearningPathViewModel extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioCacheService _audioCacheService = getIt<AudioCacheService>();

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isAudioLoading = false;
  bool get isAudioLoading => _isAudioLoading;
  List<String> _arabicWords = [];
  List<String> get arabicWords => _arabicWords;
  List<String> _englishPhrases = [];
  List<String> get englishPhrases => _englishPhrases;
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
    _englishPhrases = ['From the evil', 'of what', 'He', 'has created'];

    _currentHighlightedWordIndex = 0;
    _currentHighlightedTranslationIndex = 0;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadVerseData({
    required String arabicText,
    required String translationText,
    required String audioUrl,
    List<Map<String, dynamic>>? words,
  }) async {
    _isLoading = true;
    notifyListeners();

    if (words != null && words.isNotEmpty) {
      _arabicWords = words
          .map((w) => (w['arabic'] as String?)?.trim() ?? '')
          .where((word) => word.isNotEmpty)
          .toList();
      _englishPhrases = words
          .map((w) {
            final translation = w['translation'];
            if (translation is Map<String, dynamic>) {
              return (translation['en'] as String?)?.trim() ?? '';
            }
            return (translation as String?)?.trim() ?? '';
          })
          .where((phrase) => phrase.isNotEmpty)
          .toList();
    } else {
      _arabicWords = arabicText.split(RegExp(r'\s+'));
      final fallbackPhrases = translationText.split(RegExp(r'\s+'));
      if (fallbackPhrases.length == _arabicWords.length) {
        _englishPhrases = fallbackPhrases;
      } else {
        _englishPhrases = List.generate(
          _arabicWords.length,
          (_) => translationText,
        );
      }
    }

    if (_englishPhrases.length < _arabicWords.length) {
      _englishPhrases.addAll(
        List.filled(_arabicWords.length - _englishPhrases.length, ''),
      );
    }

    _currentHighlightedWordIndex = _arabicWords.isEmpty ? -1 : 0;
    _currentHighlightedTranslationIndex =
        (_englishPhrases.isEmpty || _currentHighlightedWordIndex == -1)
        ? -1
        : 0;

    final localPath = await _audioCacheService.getCachedAudioPath(audioUrl);
    if (localPath != null) {
      await _audioPlayer.setSource(DeviceFileSource(localPath));
    } else {
      // Audio not cached and cannot download (likely offline)
      print('Audio not available offline for caching: $audioUrl');
      // Still set the URL for potential online playback later
      await _audioPlayer.setSourceUrl(audioUrl);
    }

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
    if (newArabicIndex != _currentHighlightedWordIndex) {
      _currentHighlightedWordIndex = newArabicIndex;
    }
    if (_englishPhrases.isNotEmpty && _currentHighlightedWordIndex >= 0) {
      final maxIndex = _englishPhrases.length - 1;
      _currentHighlightedTranslationIndex = _currentHighlightedWordIndex.clamp(
        0,
        maxIndex,
      );
    } else {
      _currentHighlightedTranslationIndex = -1;
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

        final localPath = await _audioCacheService.getCachedAudioPath(
          _currentAudioUrl!,
        );
        if (localPath != null) {
          await _audioPlayer.play(DeviceFileSource(localPath));
        } else {
          // Audio not cached and cannot download (likely offline)
          print('Audio not available offline: $_currentAudioUrl');
          _isAudioLoading = false;
          notifyListeners();
          return;
        }
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
