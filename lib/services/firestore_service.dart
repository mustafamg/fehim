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
        'placeOfRevelation': {'en': 'Mecca (Meccan)', 'ar': 'مكية'},
        'position': {
          'en': '20th from the end of the Qur\'an',
          'ar': 'الـ 20 من نهاية القرآن',
        },
        'otherNames': {'en': 'Al-Mu\'awwidhatayn', 'ar': 'المعوذتين'},
        'briefContext': {
          'en':
              'Surah Al-Falaq was revealed in Mecca during a difficult period...',
          'ar': 'نزلت سورة الفلق في مكة في فترة صعبة...',
        },
      },
      verses: [
        {
          'id': '1',
          'verseNumber': 1,
          'arabic': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
          'translations': {
            'en': 'Say: "I seek refuge with the Lord of the daybreak"',
            'ar':
                'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ', // Optional if you need tafseer
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
              'arabic': 'بِرَبِّ',
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
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6226.mp3',
            },
            {
              'arabic': 'شَرِّ',
              'translation': {'en': 'the evil'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6226.mp3',
            },
            {
              'arabic': 'مَا',
              'translation': {'en': 'of what'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6226.mp3',
            },
            {
              'arabic': 'خَلَقَ',
              'translation': {'en': 'He has created'},
              'audioUrl':
                  'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6226.mp3',
            },
          ],
        },
        {
          'id': '3',
          'verseNumber': 3,
          'arabic': 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
          'translations': {
            'en':
                'And from the evil of the darkening (night) as it comes with its darkness',
          },
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6228.mp3',
        },
        {
          'id': '4',
          'verseNumber': 4,
          'arabic': 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
          'translations': {'en': 'And from the evil of the blowers in knots'},
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6229.mp3',
        },
        {
          'id': '5',
          'verseNumber': 5,
          'arabic': 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
          'translations': {
            'en': 'And from the evil of the envious when he envies',
          },
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6230.mp3',
        },
      ],
    ),
    _SampleSurah(
      id: 'an_nas',
      info: {
        'totalVerses': 6,
        'juzNumber': 30,
        'surahNumber': 114,
        'names': {'en': 'An-Nas', 'ar': 'سورة الناس'},
        'placeOfRevelation': {'en': 'Mecca (Meccan)', 'ar': 'مكية'},
        'position': {
          'en': '21st from the end of the Qur\'an',
          'ar': 'الـ 21 من نهاية القرآن',
        },
        'otherNames': {'en': 'Al-Mu\'awwidhatayn', 'ar': 'المعوذتين'},
        'briefContext': {
          'en':
              'Surah An-Nas was revealed in Mecca during a difficult period...',
          'ar': 'نزلت سورة الناس في مكة في فترة صعبة...',
        },
      },
      verses: [
        {
          'id': '1',
          'verseNumber': 1,
          'arabic': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
          'translations': {
            'en': 'Say: "I seek refuge with the Lord of mankind"',
            'ar':
                'قُلْ أَعُوذُ بِرَبِّ النَّاسِ', // Optional if you need tafseer
          },
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/64/ar.alafasy/6231.mp3',
        },
        {
          'id': '2',
          'verseNumber': 2,
          'arabic': 'مَلِكِ النَّاسِ',
          'translations': {'en': 'The King of mankind'},
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/64/ar.alafasy/6232.mp3',
        },
        {
          'id': '3',
          'verseNumber': 3,
          'arabic': 'إِلَٰهِ النَّاسِ',
          'translations': {'en': 'The God of mankind'},
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6233.mp3',
        },
        {
          'id': '4',
          'verseNumber': 4,
          'arabic': 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
          'translations': {
            'en': 'From the evil of the whisperer who withdraws',
          },
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6234.mp3',
        },
        {
          'id': '5',
          'verseNumber': 5,
          'arabic': 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
          'translations': {'en': 'Who whispers into the breasts of mankind'},
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6235.mp3',
        },
        {
          'id': '6',
          'verseNumber': 6,
          'arabic': 'مِنَ الْجِنَّةِ وَ النَّاسِ',
          'translations': {'en': 'From among the jinn and mankind'},
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6236.mp3"',
        },
      ],
    ),
    _SampleSurah(
      id: 'al_ikhlas',
      info: {
        'totalVerses': 4,
        'juzNumber': 30,
        'surahNumber': 112,
        'names': {'en': 'Al-Ikhlas', 'ar': 'سورة الإخلاص'},
        'placeOfRevelation': {'en': 'Mecca (Meccan)', 'ar': 'مكية'},
        'position': {
          'en': '22nd from the end of the Qur\'an',
          'ar': 'الـ 22 من نهاية القرآن',
        },
        'otherNames': {'en': 'Al-Tawhid', 'ar': 'التوحيد'},
        'briefContext': {
          'en':
              'Surah Al-Ikhlas was revealed in Mecca during a difficult period...',
          'ar': 'نزلت سورة الإخلاص في مكة في فترة صعبة...',
        },
      },
      verses: [
        {
          'id': '1',
          'verseNumber': 1,
          'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          'translations': {
            'en': 'Say: "He is Allah, the One"',
            'ar': 'قُلْ هُوَ اللَّهُ أَحَدٌ', // Optional if you need tafseer
          },
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6222.mp3',
        },
        {
          'id': '2',
          'verseNumber': 2,
          'arabic': 'اللَّهُ الصَّمَدُ',
          'translations': {'en': 'Allah, the Self-Sufficient'},
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6223.mp3',
        },
        {
          'id': '3',
          'verseNumber': 3,
          'arabic': 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
          'translations': {'en': 'He begets not, nor was He begotten'},
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6224.mp3',
        },
        {
          'id': '4',
          'verseNumber': 4,
          'arabic': 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
          'translations': {
            'en': 'And there is none co-equal or comparable unto Him',
          },
          'audioUrl':
              'https://cdn.islamic.network/quran/audio/128/ar.alafasy/6225.mp3',
        },
      ],
    ),
  ];

  final String id;
  final Map<String, dynamic> info;
  final List<Map<String, dynamic>> verses;

  _SampleSurah({required this.id, required this.info, required this.verses});
}
