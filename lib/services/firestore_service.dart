import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

class _CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  _CacheEntry(this.data, Duration ttl) : expiresAt = DateTime.now().add(ttl);

  bool get isValid => DateTime.now().isBefore(expiresAt);
}

@singleton
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Duration _defaultCacheDuration = const Duration(minutes: 10);
  final Map<String, _CacheEntry<Map<String, dynamic>>> _surahCache = {};
  final Map<String, _CacheEntry<List<Map<String, dynamic>>>> _surahListCache =
      {};
  final Map<String, _CacheEntry<Map<String, dynamic>>> _userProgressCache = {};
  final Map<String, _CacheEntry<Map<String, dynamic>>> _userProfileCache = {};
  void Function(FirestoreRequestTrace trace)? onRequest;

  Future<QuerySnapshot<Map<String, dynamic>>> _getCollectionFast(
    Query<Map<String, dynamic>> query,
  ) async {
    try {
      return await query
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(milliseconds: 500));
    } catch (_) {
      return await query.get(const GetOptions(source: Source.cache));
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getDocumentFast(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    try {
      return await ref
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(milliseconds: 500));
    } catch (_) {
      return await ref.get(const GetOptions(source: Source.cache));
    }
  }

  bool _hasValidProgressIdentity(String userId, String surahId) {
    return userId.trim().isNotEmpty && surahId.trim().isNotEmpty;
  }

  Map<String, dynamic> _defaultProgressData(String userId, String surahId) {
    return {
      'userId': userId,
      'surahId': surahId,
      'completedVerses': 0,
      'currentVerse': 1,
      'points': 0,
    };
  }

  void clearCache() {
    _surahCache.clear();
    _surahListCache.clear();
    _userProgressCache.clear();
    _userProfileCache.clear();
  }

  Future<void> saveUserProfile({
    required String userId,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    await _db.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _userProfileCache[userId] = _CacheEntry({
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
    }, _defaultCacheDuration);
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final cached = _userProfileCache[userId];
    if (cached?.isValid == true) {
      return cached!.data;
    }
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data != null) {
      _userProfileCache[userId] = _CacheEntry(
        Map<String, dynamic>.from(data),
        _defaultCacheDuration,
      );
    }
    return data;
  }

  // Generic method to add or update a Surah with multi-language support
  Future<void> _addOrUpdateSurah({
    required String surahId,
    required Map<String, dynamic> surahInfo,
    required List<Map<String, dynamic>> verses,
  }) async {
    final surahRef = _db.collection('surahs').doc(surahId);

    // Set Surah Document
    surahInfo['updatedAt'] = FieldValue.serverTimestamp();
    await surahRef.set(surahInfo, SetOptions(merge: true));

    // Set Verses in Subcollection
    final batch = _db.batch();
    for (var verse in verses) {
      final verseRef = surahRef
          .collection('verses')
          .doc(verse['id'].toString());
      verse['updatedAt'] = FieldValue.serverTimestamp();
      batch.set(verseRef, verse, SetOptions(merge: true));
    }
    await batch.commit();
  }

  // Seed a set of sample surahs (idempotent)
  Future<void> ensureSampleSurahsSeeded() async {
    for (final sample in _SampleSurah.samples) {
      final surahRef = _db.collection('surahs').doc(sample.id);
      final snapshot = await _getDocumentFast(surahRef);

      if (snapshot.exists) {
        continue;
      }

      final info = {
        ...sample.info,
        'id': sample.id,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _addOrUpdateSurah(
        surahId: sample.id,
        surahInfo: info,
        verses: sample.verses,
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllSurahs({
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'all_surahs';
    if (!forceRefresh &&
        _surahListCache[cacheKey]?.isValid == true &&
        _surahListCache[cacheKey]?.data != null) {
      _emitTrace(
        FirestoreRequestTrace(
          operation: 'fetchAllSurahs',
          cacheHit: true,
          source: 'cache',
        ),
      );
      return _surahListCache[cacheKey]!.data;
    }

    final trace = FirestoreRequestTrace(
      operation: 'fetchAllSurahs',
      cacheHit: false,
      source: 'server',
    );
    final stopwatch = Stopwatch()..start();
    final snapshot = await _getCollectionFast(_db.collection('surahs'));
    stopwatch.stop();
    trace.duration = stopwatch.elapsed;
    _emitTrace(trace);
    final surahs = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Map<String, dynamic>.from(data);
    }).toList();

    _surahListCache[cacheKey] = _CacheEntry(surahs, _defaultCacheDuration);
    return surahs;
  }

  // Initialize User Progress
  Future<void> initUserProgress(String userId, String surahId) async {
    if (!_hasValidProgressIdentity(userId, surahId)) {
      return;
    }
    final progressRef = _db
        .collection('user_progress')
        .doc('${userId}_$surahId');
    final snapshot = await progressRef.get();

    if (!snapshot.exists) {
      await progressRef.set({
        'userId': userId,
        'surahId': surahId,
        'completedVerses': 0,
        'currentVerse': 1,
        'points': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Get Surah Data including verses
  Future<Map<String, dynamic>> getSurahData(
    String surahId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _surahCache[surahId]?.isValid == true &&
        _surahCache[surahId]?.data != null) {
      _emitTrace(
        FirestoreRequestTrace(
          operation: 'getSurahData',
          identifier: surahId,
          cacheHit: true,
          source: 'cache',
        ),
      );
      return _surahCache[surahId]!.data;
    }

    final trace = FirestoreRequestTrace(
      operation: 'getSurahData',
      identifier: surahId,
      cacheHit: false,
      source: 'server',
    );
    final stopwatch = Stopwatch()..start();
    final surahRef = _db.collection('surahs').doc(surahId);
    final surahDoc = await _getDocumentFast(surahRef);

    final versesSnapshot = await _getCollectionFast(
      surahRef.collection('verses').orderBy('verseNumber'),
    );
    final verses = versesSnapshot.docs.map((doc) => doc.data()).toList();

    stopwatch.stop();
    trace.duration = stopwatch.elapsed;
    _emitTrace(trace);
    final surahData = {'surah': surahDoc.data(), 'verses': verses};
    _surahCache[surahId] = _CacheEntry(surahData, _defaultCacheDuration);
    return surahData;
  }

  // Get User Progress
  Future<Map<String, dynamic>> getUserProgress(
    String userId,
    String surahId, {
    bool forceRefresh = false,
  }) async {
    if (!_hasValidProgressIdentity(userId, surahId)) {
      return _defaultProgressData(userId, surahId);
    }
    final cacheKey = '${userId}_$surahId';
    if (!forceRefresh &&
        _userProgressCache[cacheKey]?.isValid == true &&
        _userProgressCache[cacheKey]?.data != null) {
      _emitTrace(
        FirestoreRequestTrace(
          operation: 'getUserProgress',
          identifier: cacheKey,
          cacheHit: true,
          source: 'cache',
        ),
      );
      return _userProgressCache[cacheKey]!.data;
    }

    final trace = FirestoreRequestTrace(
      operation: 'getUserProgress',
      identifier: cacheKey,
      cacheHit: false,
      source: 'server',
    );
    final stopwatch = Stopwatch()..start();
    final progressRef = _db.collection('user_progress').doc(cacheKey);
    final snapshot = await _getDocumentFast(progressRef);
    stopwatch.stop();
    trace.duration = stopwatch.elapsed;
    _emitTrace(trace);
    final data = snapshot.data() ?? {};
    _userProgressCache[cacheKey] = _CacheEntry(data, _defaultCacheDuration);
    return data;
  }

  Future<void> updateUserProgress(
    String userId,
    String surahId,
    int completedVerses,
    int currentVerse, {
    int? points,
  }) async {
    if (!_hasValidProgressIdentity(userId, surahId)) {
      return;
    }
    updateUserProgressLocal(
      userId,
      surahId,
      completedVerses,
      currentVerse,
      points: points,
    );
    final progressRef = _db
        .collection('user_progress')
        .doc('${userId}_$surahId');

    final updateData = <String, dynamic>{
      'completedVerses': completedVerses,
      'currentVerse': currentVerse,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (points != null) {
      updateData['points'] = points;
    }

    progressRef.update(updateData).catchError((_) {});
  }

  void updateUserProgressLocal(
    String userId,
    String surahId,
    int completedVerses,
    int currentVerse, {
    int? points,
  }) {
    if (!_hasValidProgressIdentity(userId, surahId)) {
      return;
    }
    final cacheKey = '${userId}_$surahId';
    final existingData = _userProgressCache[cacheKey]?.data ?? {};
    final updatedPoints = points ?? existingData['points'] ?? 0;

    _userProgressCache[cacheKey] = _CacheEntry({
      ...existingData,
      'userId': userId,
      'surahId': surahId,
      'completedVerses': completedVerses,
      'currentVerse': currentVerse,
      'points': updatedPoints,
      'updatedAt': DateTime.now().toIso8601String(),
    }, _defaultCacheDuration);
  }

  Future<void> incrementUserPoints(String userId, String surahId) async {
    if (!_hasValidProgressIdentity(userId, surahId)) {
      return;
    }
    final cacheKey = '${userId}_$surahId';
    final existingData = _userProgressCache[cacheKey]?.data ?? {};
    int currentPoints = existingData['points'] as int? ?? 0;

    updateUserProgressLocal(
      userId,
      surahId,
      existingData['completedVerses'] as int? ?? 0,
      existingData['currentVerse'] as int? ?? 1,
      points: currentPoints + 1,
    );

    final progressRef = _db
        .collection('user_progress')
        .doc('${userId}_$surahId');
    progressRef
        .update({
          'points': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        })
        .catchError((_) {});
  }

  // Clear User Progress (For testing)
  Future<void> clearUserProgress(String userId, String surahId) async {
    if (!_hasValidProgressIdentity(userId, surahId)) {
      return;
    }
    final cacheKey = '${userId}_$surahId';
    int existingPoints = 0;
    final cachedData = _userProgressCache[cacheKey]?.data;
    if (cachedData != null) {
      existingPoints = cachedData['points'] as int? ?? 0;
    } else {
      final snapshot = await _db
          .collection('user_progress')
          .doc(cacheKey)
          .get();
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          existingPoints = data['points'] as int? ?? 0;
        }
      }
    }

    updateUserProgressLocal(userId, surahId, 0, 1, points: existingPoints);
    final progressRef = _db
        .collection('user_progress')
        .doc('${userId}_$surahId');
    progressRef
        .update({
          'completedVerses': 0,
          'currentVerse': 1,
          'updatedAt': FieldValue.serverTimestamp(),
        })
        .catchError((_) {});
  }

  void _emitTrace(FirestoreRequestTrace trace) {
    if (onRequest != null) {
      onRequest!(trace);
      return;
    }

    final buffer = StringBuffer('[Firestore] ${trace.operation}');
    if (trace.identifier != null) {
      buffer.write(' (${trace.identifier})');
    }
    buffer.write(' ${trace.source.toUpperCase()}');
    if (trace.duration != null) {
      buffer.write(' ${trace.duration!.inMilliseconds}ms');
    }
  }
}

class FirestoreRequestTrace {
  final String operation;
  final String? identifier;
  final bool cacheHit;
  final String source;
  Duration? duration;

  FirestoreRequestTrace({
    required this.operation,
    this.identifier,
    required this.cacheHit,
    required this.source,
    this.duration,
  });
}

class _SampleSurah {
  static List<_SampleSurah> samples = [
    _SampleSurah(
      id: 'al_falaq',
      info: {
        'totalVerses': 5,
        'juzNumber': 30,
        'surahNumber': 113,
        'names': {'en': 'Al-Falaq', 'ar': 'سورة الفلق'},
        'placeOfRevelation': {'en': 'Mecca (Meccan)', 'ar': 'مكة (مكية)'},
        'position': {
          'en': "20th from the end of the Qur'an",
          'ar': 'العشرون من نهاية القرآن',
        },
        'otherNames': {'en': "Al-Mu'awwidhatayn", 'ar': 'المعوِّذتان'},
        'briefContext': {
          'en':
              'This surah teaches believers to seek refuge in Allah from all forms of evil.',
          'ar': 'تعلم هذه السورة المؤمنين الاستعاذة بالله من جميع أنواع الشر.',
        },
      },
      verses: [
        {
          'id': '1',
          'verseNumber': 1,
          'arabic': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
          'translations': {
            'en': 'Say: I seek refuge with the Lord of the daybreak',
          },
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6226.mp3',
          'words': [
            {
              'arabic': 'قُلْ',
              'translation': {'en': 'Say'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6226.mp3',
            },
            {
              'arabic': 'أَعُوذُ',
              'translation': {'en': 'I seek refuge'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6226.mp3',
            },
            {
              'arabic': 'بِرَبِّ',
              'translation': {'en': 'in the Lord'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6226.mp3',
            },
            {
              'arabic': 'الْفَلَقِ',
              'translation': {'en': 'of the daybreak'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6226.mp3',
            },
          ],
        },
        {
          'id': '2',
          'verseNumber': 2,
          'arabic': 'مِن شَرِّ مَا خَلَقَ',
          'translations': {'en': 'From the evil of what He has created'},
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6227.mp3',
          'words': [
            {
              'arabic': 'مِن',
              'translation': {'en': 'From'},
              'audioUrl':
                  'https://firebasestorage.googleapis.com/v0/b/fehim-66711.firebasestorage.app/o/falak%2Fmn.wav?alt=media&token=82cb00fb-9f62-4fba-ad7b-00b94ad67511',
            },
            {
              'arabic': 'شَرِّ',
              'translation': {'en': 'the evil'},
              'audioUrl':
                  'https://firebasestorage.googleapis.com/v0/b/fehim-66711.firebasestorage.app/o/falak%2Fshar.wav?alt=media&token=baf45b73-9cce-46a8-8e1c-47bff337c5df',
            },
            {
              'arabic': 'مَا',
              'translation': {'en': 'of what'},
              'audioUrl':
                  'https://firebasestorage.googleapis.com/v0/b/fehim-66711.firebasestorage.app/o/falak%2Fma.wav?alt=media&token=b1574c2c-4de2-4bd6-bd34-3425222b3433',
            },
            {
              'arabic': 'خَلَقَ',
              'translation': {'en': 'He created'},
              'audioUrl':
                  'https://firebasestorage.googleapis.com/v0/b/fehim-66711.firebasestorage.app/o/falak%2Fkhalak.wav?alt=media&token=ccfae960-e908-49d6-b35d-cbc2e87a4d0f',
            },
          ],
        },
        {
          'id': '3',
          'verseNumber': 3,
          'arabic': 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
          'translations': {'en': 'And from the evil of the darkening night'},
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6228.mp3',
          'words': [
            {
              'arabic': 'وَمِن',
              'translation': {'en': 'And from'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6228.mp3',
            },
            {
              'arabic': 'شَرِّ',
              'translation': {'en': 'the evil'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6228.mp3',
            },
            {
              'arabic': 'غَاسِقٍ',
              'translation': {'en': 'of darkness'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6228.mp3',
            },
            {
              'arabic': 'إِذَا',
              'translation': {'en': 'when'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6228.mp3',
            },
            {
              'arabic': 'وَقَبَ',
              'translation': {'en': 'it settles'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6228.mp3',
            },
          ],
        },
        {
          'id': '4',
          'verseNumber': 4,
          'arabic': 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
          'translations': {'en': 'And from the evil of the blowers in knots'},
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6229.mp3',
          'words': [
            {
              'arabic': 'وَمِن',
              'translation': {'en': 'And from'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6229.mp3',
            },
            {
              'arabic': 'شَرِّ',
              'translation': {'en': 'the evil'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6229.mp3',
            },
            {
              'arabic': 'النَّفَّاثَاتِ',
              'translation': {'en': 'the blowers'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6229.mp3',
            },
            {
              'arabic': 'فِي',
              'translation': {'en': 'in'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6229.mp3',
            },
            {
              'arabic': 'الْعُقَدِ',
              'translation': {'en': 'the knots'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6229.mp3',
            },
          ],
        },
        {
          'id': '5',
          'verseNumber': 5,
          'arabic': 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
          'translations': {
            'en': 'And from the evil of the envier when he envies',
          },
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6230.mp3',
          'words': [
            {
              'arabic': 'وَمِن',
              'translation': {'en': 'And from'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6230.mp3',
            },
            {
              'arabic': 'شَرِّ',
              'translation': {'en': 'the evil'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6230.mp3',
            },
            {
              'arabic': 'حَاسِدٍ',
              'translation': {'en': 'an envier'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6230.mp3',
            },
            {
              'arabic': 'إِذَا',
              'translation': {'en': 'when'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6230.mp3',
            },
            {
              'arabic': 'حَسَدَ',
              'translation': {'en': 'he envies'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6230.mp3',
            },
          ],
        },
      ],
    ),
  ];

  final String id;
  final Map<String, dynamic> info;
  final List<Map<String, dynamic>> verses;

  _SampleSurah({required this.id, required this.info, required this.verses});
}
