import 'package:flutter/material.dart';
import 'package:holy_quran/generated/l10n.dart';
import 'package:holy_quran/main.dart';
import 'package:holy_quran/services/audio_cache_service.dart';
import 'package:holy_quran/services/connectivity_service.dart';
import 'package:holy_quran/services/firestore_service.dart';
import 'package:holy_quran/utils/helper/shared_pref.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class SurahSelectionScreenViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AudioCacheService _audioCacheService = getIt<AudioCacheService>();
  final ConnectivityService _connectivityService = ConnectivityService();
  SurahSelectionScreenViewModel(this._firestoreService) {
    final savedLanguage = SharedPrefrencesHelper.getString(
      key: SharedPrefrencesHelper.languageCodeKey,
    );
    if (savedLanguage != null && savedLanguage.isNotEmpty) {
      _languageCode = savedLanguage;
    }
  }

  String get _userId =>
      SharedPrefrencesHelper.getString(key: SharedPrefrencesHelper.userIdKey) ??
      '';

  bool _isShowMore = false;
  bool _isLoading = true;
  bool _isInitialized = false;
  bool _hasValidData = false;
  bool get isInitialized => _isInitialized;
  String? _error;
  String _surahId = 'al_falaq';
  String _languageCode = 'en';

  String _surahName = '';
  String _arabicName = '';
  int _totalVerses = 0;
  int _juzNumber = 0;
  int _surahNumber = 0;
  String _placeOfRevelation = '';
  String _position = '';
  String _otherName = '';
  String _briefContext = '';
  int _currentVerse = 1;
  int _completedVerses = 0;
  List<Map<String, dynamic>> _verses = [];
  List<Map<String, dynamic>> _availableSurahs = [];
  List<String> _availableLanguages = [];

  bool get isShowMore => _isShowMore;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get surahName => _surahName;
  String get arabicName => _arabicName;
  int get totalVerses => _totalVerses;
  int get juzNumber => _juzNumber;
  int get surahNumber => _surahNumber;
  String get placeOfRevelation => _placeOfRevelation;
  String get position => _position;
  String get otherName => _otherName;
  String get briefContext => _briefContext;
  int get currentVerse => _currentVerse;
  int get completedVerses => _completedVerses;
  List<Map<String, dynamic>> get verses => _verses;
  List<Map<String, dynamic>> get availableSurahs => _availableSurahs;
  String get selectedSurahId => _surahId;
  String get languageCode => _languageCode;
  List<String> get availableLanguages => _availableLanguages;

  double get progressPercentage =>
      _totalVerses == 0 ? 0 : _completedVerses / _totalVerses;
  String get progressText => '${(progressPercentage * 100).toInt()}%';
  void toggleShowMore() {
    _isShowMore = !_isShowMore;
    notifyListeners();
  }

  Future<void> initialize({
    String? defaultSurahId,
    String? languageCode,
  }) async {
    if (_isInitialized) return;
    final savedLanguage = SharedPrefrencesHelper.getString(
      key: SharedPrefrencesHelper.languageCodeKey,
    );
    _languageCode = languageCode ?? savedLanguage ?? _languageCode;
    if (defaultSurahId != null) {
      _surahId = defaultSurahId;
    }

    // Load from cache immediately without loading state
    await _initializeFromCache();

    // Only seed data and fetch from Firestore if user is authenticated
    if (_userId.isNotEmpty) {
      // Start background refresh without showing loading
      _refreshInBackground();
    } else {
      // Use empty list when not authenticated
      _availableSurahs = [];
    }

    if (_availableSurahs.isNotEmpty &&
        !_availableSurahs.any((surah) => surah['id'] == _surahId)) {
      _surahId = _availableSurahs.first['id'] as String;
    }
    _isInitialized = true;
  }

  Future<void> _initializeFromCache() async {
    try {
      // Try to load from cache first
      _availableSurahs = await _firestoreService
          .fetchAllSurahs(forceRefresh: false)
          .timeout(const Duration(milliseconds: 500));

      if (_availableSurahs.isNotEmpty) {
        await _loadSurahDataFromCache();
        // Only remove loading if we actually have verses data
        if (_verses.isNotEmpty && _surahName.isNotEmpty) {
          _setLoading(false);
        } else {
          // Keep loading if verses are empty and we need to fetch them
          _setDefaultValues();
        }
      } else {
        // Cache is empty (like fresh install), so we need to wait for data
        _setDefaultValues();
        // Important: we DON'T set loading to false here. We let _refreshInBackground do it.
      }
    } catch (e) {
      // On error (e.g. timeout), set loading and wait for background refresh
      _availableSurahs = [];
      _setDefaultValues();
      // Important: we DON'T set loading to false here. We let _refreshInBackground do it.
    }
  }

  Future<void> _loadSurahDataFromCache() async {
    try {
      final surahData = await _firestoreService.getSurahData(
        _surahId,
        forceRefresh: false,
      );
      final surahInfo = surahData['surah'] as Map<String, dynamic>?;
      _verses = List<Map<String, dynamic>>.from(surahData['verses'] ?? []);

      if (surahInfo != null) {
        final fallbackLang = _determineFallbackLanguage(surahInfo);
        _availableLanguages = _extractLanguageKeys(surahInfo['names']);
        if (_availableLanguages.isNotEmpty &&
            !_availableLanguages.contains(_languageCode)) {
          _languageCode = _availableLanguages.first;
        }
        _surahName = _resolveLocaleValue(
          surahInfo['names'],
          _languageCode,
          fallbackLang,
          defaultValue: S.current.surahSelectionDefaultName,
        );
        _arabicName = surahInfo['names']?['ar'] ?? _surahName;
        _totalVerses = surahInfo['totalVerses'] ?? _verses.length;
        _juzNumber = surahInfo['juzNumber'] ?? 0;
        _surahNumber = surahInfo['surahNumber'] ?? 0;
        _placeOfRevelation = _resolveLocaleValue(
          surahInfo['placeOfRevelation'],
          _languageCode,
          fallbackLang,
        );
        _position = _resolveLocaleValue(
          surahInfo['position'],
          _languageCode,
          fallbackLang,
        );
        _otherName = _resolveLocaleValue(
          surahInfo['otherNames'],
          _languageCode,
          fallbackLang,
        );
        _briefContext = _resolveLocaleValue(
          surahInfo['briefContext'],
          _languageCode,
          fallbackLang,
        );
      }

      if (_userId.isNotEmpty) {
        final progressData = await _firestoreService.getUserProgress(
          _userId,
          _surahId,
          forceRefresh: false,
        );
        _completedVerses = progressData['completedVerses'] ?? 0;
        _currentVerse = progressData['currentVerse'] ?? 1;
      } else {
        _completedVerses = 0;
        _currentVerse = 1;
      }

      // Prefetch audio for all verses in the background
      _prefetchAudioForVerses();

      if (_verses.isNotEmpty) {
        _hasValidData = true;
        _setLoading(false);
      }
    } catch (e) {
      _hasValidData = false;
      _setDefaultValues();
    }
  }

  void _setDefaultValues() {
    _verses = [];
    _completedVerses = 0;
    _currentVerse = 1;
    _surahName = S.current.surahSelectionDefaultName;
    _arabicName = '';
    _totalVerses = 0;
    _juzNumber = 0;
    _surahNumber = 0;
    _placeOfRevelation = '';
    _position = '';
    _otherName = '';
    _briefContext = '';
    // Don't call notifyListeners() here to prevent empty UI flash
    _hasValidData = false;
  }

  Future<void> _refreshInBackground() async {
    try {
      // Check internet connectivity first
      final hasConnection = await _connectivityService.isConnected();
      if (!hasConnection) {
        print('No internet connection - skipping background refresh');
        if (_isLoading) _setLoading(false);
        return;
      }

      await _firestoreService.ensureSampleSurahsSeeded();
      final freshSurahs = await _firestoreService.fetchAllSurahs(
        forceRefresh: true,
      );

      // We need to fetch full surah data before deciding to dismiss loading
      // Especially if cache was completely empty
      if (_availableSurahs.isEmpty ||
          _surahListsDiffer(_availableSurahs, freshSurahs)) {
        _availableSurahs = freshSurahs;
        await _loadSurahData(forceRefresh: true);
      }
    } catch (e) {
      // Silently handle background refresh errors
      print('Background refresh failed: $e');
    } finally {
      // Always clear loading state when done, especially important for fresh installs
      // However, we only clear it here if it's still loading. The inner _loadSurahData
      // might have already cleared it, or might have set it if there was an issue.
      if (!_hasValidData && _error == null) {
        // Keep loading spinner until data arrives or an error occurs
        return;
      }
      if (_isLoading) {
        _setLoading(false);
      }
    }
  }

  bool _surahListsDiffer(
    List<Map<String, dynamic>> oldList,
    List<Map<String, dynamic>> newList,
  ) {
    if (oldList.length != newList.length) return true;
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i]['id'] != newList[i]['id']) return true;
    }
    return false;
  }

  Future<void> selectSurah(String surahId) async {
    if (surahId == _surahId) return;
    await _loadSurahData(surahId: surahId);
  }

  Future<void> selectLanguage(String languageCode) async {
    if (_languageCode == languageCode) return;
    _languageCode = languageCode;
    await _loadSurahData();
  }

  Future<void> refresh() async {
    await _loadSurahData();
  }

  Future<void> safeRefresh() async {
    if (hasListeners) {
      await refresh();
    }
  }

  Future<void> completeVerse() async {
    if (_completedVerses >= _totalVerses || _userId.isEmpty) {
      return;
    }
    try {
      _setLoading(true);
      _completedVerses++;
      if (_completedVerses < _totalVerses) {
        _currentVerse++;
      }
      await _firestoreService.updateUserProgress(
        _userId,
        _surahId,
        _completedVerses,
        _currentVerse,
      );
      notifyListeners();
    } catch (e) {
      _setError(S.current.surahSelectionProgressUpdateFailed('$e'));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetProgress() async {
    if (_userId.isEmpty) return;
    try {
      _setLoading(true);
      await _firestoreService.clearUserProgress(_userId, _surahId);
      await _loadSurahData();
    } catch (e) {
      _setError(S.current.surahSelectionResetFailed('$e'));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadSurahData({
    String? surahId,
    bool forceRefresh = false,
  }) async {
    try {
      _clearError();
      if (surahId != null) {
        _surahId = surahId;
      }

      if (_userId.isNotEmpty) {
        await _firestoreService.initUserProgress(_userId, _surahId);
      }

      final surahData = await _firestoreService.getSurahData(
        _surahId,
        forceRefresh: forceRefresh,
      );
      final surahInfo = surahData['surah'] as Map<String, dynamic>?;
      _verses = List<Map<String, dynamic>>.from(surahData['verses'] ?? []);

      if (surahInfo != null) {
        final fallbackLang = _determineFallbackLanguage(surahInfo);
        _availableLanguages = _extractLanguageKeys(surahInfo['names']);
        if (_availableLanguages.isNotEmpty &&
            !_availableLanguages.contains(_languageCode)) {
          _languageCode = _availableLanguages.first;
        }
        _surahName = _resolveLocaleValue(
          surahInfo['names'],
          _languageCode,
          fallbackLang,
          defaultValue: S.current.surahSelectionDefaultName,
        );
        _arabicName = surahInfo['names']?['ar'] ?? _surahName;
        _totalVerses = surahInfo['totalVerses'] ?? _verses.length;
        _juzNumber = surahInfo['juzNumber'] ?? 0;
        _surahNumber = surahInfo['surahNumber'] ?? 0;
        _placeOfRevelation = _resolveLocaleValue(
          surahInfo['placeOfRevelation'],
          _languageCode,
          fallbackLang,
        );
        _position = _resolveLocaleValue(
          surahInfo['position'],
          _languageCode,
          fallbackLang,
        );
        _otherName = _resolveLocaleValue(
          surahInfo['otherNames'],
          _languageCode,
          fallbackLang,
        );
        _briefContext = _resolveLocaleValue(
          surahInfo['briefContext'],
          _languageCode,
          fallbackLang,
        );
      }

      if (_userId.isNotEmpty) {
        final progressData = await _firestoreService.getUserProgress(
          _userId,
          _surahId,
          forceRefresh: forceRefresh,
        );
        _completedVerses = progressData['completedVerses'] ?? 0;
        _currentVerse = progressData['currentVerse'] ?? 1;
      } else {
        _completedVerses = 0;
        _currentVerse = 1;
      }

      // Prefetch audio for all verses in the background
      _prefetchAudioForVerses();

      // Only dismiss loading if we have valid data
      if (_verses.isNotEmpty &&
          _surahName.isNotEmpty &&
          _surahName != S.current.surahSelectionDefaultName) {
        _hasValidData = true;
        _setLoading(false);
      }
    } catch (e) {
      _setError(S.current.surahSelectionLoadFailed('$e'));
      if (_verses.isEmpty) {
        _setDefaultValues();
      }
      _setLoading(false); // In case of hard error, we must dismiss loading
    }
  }

  void _prefetchAudioForVerses() {
    final audioUrls = <String>[];
    for (final verse in _verses) {
      final verseAudio = verse['audioUrl'] ?? verse['audio'];
      if (verseAudio is String && verseAudio.isNotEmpty) {
        audioUrls.add(verseAudio);
      }

      final words = verse['words'];
      if (words is List) {
        for (final word in words) {
          if (word is Map) {
            final wordAudio = word['audioUrl'] ?? word['audio'];
            if (wordAudio is String && wordAudio.isNotEmpty) {
              audioUrls.add(wordAudio);
            }
          }
        }
      }
    }

    if (audioUrls.isNotEmpty) {
      _audioCacheService.prefetchAudios(audioUrls);
    }
  }

  List<String> _extractLanguageKeys(dynamic value) {
    if (value is Map) {
      return value.keys.map((e) => e.toString()).toList()..sort();
    }
    return [];
  }

  String localizedSurahName(Map<String, dynamic> surah) {
    final names = surah['names'];
    final availableLangs = _extractLanguageKeys(names);
    final fallback = _pickFallback(availableLangs);
    return _resolveLocaleValue(
      names,
      _languageCode,
      fallback,
      defaultValue: S.current.surahSelectionDefaultName,
    );
  }

  String verseTranslation(Map<String, dynamic> verse) {
    final translations = verse['translations'];
    final availableLangs = _extractLanguageKeys(translations);
    final fallback = _pickFallback(availableLangs);
    return _resolveLocaleValue(translations, _languageCode, fallback);
  }

  String _determineFallbackLanguage(Map<String, dynamic> surahInfo) {
    final names = surahInfo['names'];
    if (names is Map) {
      final available = names.keys.toList();
      return _pickFallback(available.map((e) => e.toString()).toList());
    }
    return 'en';
  }

  String _pickFallback(List<String> availableLanguages) {
    if (availableLanguages.isEmpty) return 'en';
    if (!availableLanguages.contains(_languageCode)) {
      return availableLanguages.first;
    }
    final candidates = availableLanguages
        .where((lang) => lang != _languageCode)
        .toList();
    if (candidates.isEmpty) return availableLanguages.first;
    if (candidates.contains('en')) return 'en';
    if (candidates.contains('ar')) return 'ar';
    return candidates.first;
  }

  String _resolveLocaleValue(
    dynamic value,
    String preferred,
    String fallback, {
    String defaultValue = '',
  }) {
    if (value is Map<String, dynamic>) {
      return value[preferred] ?? value[fallback] ?? defaultValue;
    }
    if (value is Map<String, String>) {
      return value[preferred] ?? value[fallback] ?? defaultValue;
    }
    return value?.toString() ?? defaultValue;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
