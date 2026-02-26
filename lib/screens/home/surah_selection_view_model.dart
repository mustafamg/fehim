import 'package:flutter/material.dart';
import 'package:holy_quran/services/firestore_service.dart';
import 'package:injectable/injectable.dart';
@Injectable()
class SurahSelectionScreenViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final String _userId = 'test_user_1'; 
  bool _isShowMore = false;
  bool _isLoading = false;
  bool _isInitialized = false;
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
    String languageCode = 'en',
  }) async {
    if (_isInitialized) return;
    _languageCode = languageCode;
    if (defaultSurahId != null) {
      _surahId = defaultSurahId;
    }
    await _firestoreService.ensureSampleSurahsSeeded();
    _availableSurahs = await _firestoreService.fetchAllSurahs();
    if (_availableSurahs.isNotEmpty &&
        !_availableSurahs.any((surah) => surah['id'] == _surahId)) {
      _surahId = _availableSurahs.first['id'] as String;
    }
    await _loadSurahData();
    _isInitialized = true;
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
  Future<void> completeVerse() async {
    if (_completedVerses >= _totalVerses) {
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
      _setError('Failed to update progress: $e');
    } finally {
      _setLoading(false);
    }
  }
  Future<void> resetProgress() async {
    try {
      _setLoading(true);
      await _firestoreService.clearUserProgress(_userId, _surahId);
      await _loadSurahData();
    } catch (e) {
      _setError('Failed to reset progress: $e');
    } finally {
      _setLoading(false);
    }
  }
  Future<void> _loadSurahData({String? surahId}) async {
    try {
      _setLoading(true);
      _clearError();
      if (surahId != null) {
        _surahId = surahId;
      }
      await _firestoreService.initUserProgress(_userId, _surahId);
      final surahData = await _firestoreService.getSurahData(_surahId);
      final surahInfo = surahData['surah'] as Map<String, dynamic>?;
      _verses = List<Map<String, dynamic>>.from(surahData['verses'] ?? []);
      if (surahInfo != null) {
        final lang = _languageCode;
        final fallbackLang = lang == 'en' ? 'ar' : 'en';
        _availableLanguages = _extractLanguageKeys(surahInfo['names']);
        if (_availableLanguages.isNotEmpty &&
            !_availableLanguages.contains(_languageCode)) {
          _languageCode = _availableLanguages.first;
        }
        _surahName = _resolveLocaleValue(
          surahInfo['names'],
          _languageCode,
          fallbackLang,
          defaultValue: 'Surah',
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
      final progressData = await _firestoreService.getUserProgress(
        _userId,
        _surahId,
      );
      _completedVerses = progressData['completedVerses'] ?? 0;
      _currentVerse = progressData['currentVerse'] ?? 1;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load surah data: $e');
    } finally {
      _setLoading(false);
    }
  }
  List<String> _extractLanguageKeys(dynamic value) {
    if (value is Map) {
      return value.keys.map((e) => e.toString()).toList()..sort();
    }
    return [];
  }
  String verseTranslation(Map<String, dynamic> verse) {
    final translations = verse['translations'];
    final fallback = _languageCode == 'en' ? 'ar' : 'en';
    return _resolveLocaleValue(translations, _languageCode, fallback);
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
