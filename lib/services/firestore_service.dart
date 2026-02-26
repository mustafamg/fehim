import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
      final snapshot = await surahRef.get();

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

  Future<List<Map<String, dynamic>>> fetchAllSurahs() async {
    final snapshot = await _db.collection('surahs').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Map<String, dynamic>.from(data);
    }).toList();
  }

  // Initialize User Progress
  Future<void> initUserProgress(String userId, String surahId) async {
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
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Get Surah Data including verses
  Future<Map<String, dynamic>> getSurahData(String surahId) async {
    final surahRef = _db.collection('surahs').doc(surahId);
    final surahDoc = await surahRef.get();

    final versesSnapshot = await surahRef
        .collection('verses')
        .orderBy('verseNumber')
        .get();
    final verses = versesSnapshot.docs.map((doc) => doc.data()).toList();

    return {'surah': surahDoc.data(), 'verses': verses};
  }

  // Get User Progress
  Future<Map<String, dynamic>> getUserProgress(
    String userId,
    String surahId,
  ) async {
    final progressRef = _db
        .collection('user_progress')
        .doc('${userId}_$surahId');
    final snapshot = await progressRef.get();
    return snapshot.data() ?? {};
  }

  // Update User Progress
  Future<void> updateUserProgress(
    String userId,
    String surahId,
    int completedVerses,
    int currentVerse,
  ) async {
    final progressRef = _db
        .collection('user_progress')
        .doc('${userId}_$surahId');
    await progressRef.update({
      'completedVerses': completedVerses,
      'currentVerse': currentVerse,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Clear User Progress (For testing)
  Future<void> clearUserProgress(String userId, String surahId) async {
    final progressRef = _db
        .collection('user_progress')
        .doc('${userId}_$surahId');
    await progressRef.update({
      'completedVerses': 0,
      'currentVerse': 1,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
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
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6227.mp3',
            },
            {
              'arabic': 'شَرِّ',
              'translation': {'en': 'the evil'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6227.mp3',
            },
            {
              'arabic': 'مَا',
              'translation': {'en': 'of what'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6227.mp3',
            },
            {
              'arabic': 'خَلَقَ',
              'translation': {'en': 'He created'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6227.mp3',
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
