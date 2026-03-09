// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a tr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'tr';

  static String m0(count) =>
      "${Intl.plural(count, one: '+${count} ayet', other: '+${count} ayet')}";

  static String m1(audioUrl) => "Ses çevrimdışı kullanılamıyor: ${audioUrl}";

  static String m2(audioUrl) =>
      "Ses çevrimdışı önbelleğe alma için kullanılamıyor: ${audioUrl}";

  static String m3(error) => "Ses oynatma hatası: ${error}";

  static String m4(message) => "Hata: ${message}";

  static String m5(error) => "Google ile giriş sırasında hata: ${error}";

  static String m6(error) => "Sure verileri yüklenemedi: ${error}";

  static String m7(error) => "İlerleme güncellenemedi: ${error}";

  static String m8(error) => "İlerleme sıfırlanamadı: ${error}";

  static String m9(juzNumber, surahNumber, totalVerses) =>
      "Cüz ${juzNumber} - Sure Numarası ${surahNumber} - Ayet ${totalVerses}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "arrangePuzzleCongratsTitle":
            MessageLookupByLibrary.simpleMessage("Tebrikler"),
        "arrangePuzzleEarnedHighlight": m0,
        "arrangePuzzleEarnedPrefix":
            MessageLookupByLibrary.simpleMessage("Kazandınız "),
        "arrangePuzzleEarnedSuffix":
            MessageLookupByLibrary.simpleMessage(" kalbinizde."),
        "arrangePuzzleFinish": MessageLookupByLibrary.simpleMessage("Bitir"),
        "arrangePuzzleGoBack": MessageLookupByLibrary.simpleMessage("Geri dön"),
        "arrangePuzzleMissingData": MessageLookupByLibrary.simpleMessage(
            "Yapboz verileri eksik. Lütfen önce öğrenme yolunu tamamlayın."),
        "arrangePuzzleNextVerse":
            MessageLookupByLibrary.simpleMessage("Sonraki ayet"),
        "arrangePuzzleSubtitle":
            MessageLookupByLibrary.simpleMessage("Parçaları birleştirelim"),
        "arrangePuzzleTitle":
            MessageLookupByLibrary.simpleMessage("Yapbozu düzenle"),
        "audioNotAvailableMessage": m1,
        "audioNotCachedMessage": m2,
        "audioPlaybackError": m3,
        "ayahLearningEmptyMessage": MessageLookupByLibrary.simpleMessage(
            "Bu ayet için kelime verisi yok."),
        "ayahLearningSubtitle": MessageLookupByLibrary.simpleMessage(
            "Hadi her kelimeyi inceleyelim"),
        "ayahLearningTitle":
            MessageLookupByLibrary.simpleMessage("Kelimeleri keşfet"),
        "commonCancel": MessageLookupByLibrary.simpleMessage("İptal"),
        "commonContinue": MessageLookupByLibrary.simpleMessage("Devam"),
        "commonErrorWithMessage": m4,
        "commonHome": MessageLookupByLibrary.simpleMessage("Ana sayfa"),
        "commonLogout": MessageLookupByLibrary.simpleMessage("Çıkış"),
        "commonNext": MessageLookupByLibrary.simpleMessage("İleri"),
        "connectMeaningSubtitle": MessageLookupByLibrary.simpleMessage(
            "Kelimeleri anlamlarıyla eşleştir"),
        "connectMeaningTitle":
            MessageLookupByLibrary.simpleMessage("Anlamları eşleştir"),
        "fillGapsSubtitle":
            MessageLookupByLibrary.simpleMessage("Eksik kısımları tamamla"),
        "fillGapsTitle":
            MessageLookupByLibrary.simpleMessage("Boşlukları doldur"),
        "languageArabic": MessageLookupByLibrary.simpleMessage("Arapça"),
        "languageEnglish": MessageLookupByLibrary.simpleMessage("İngilizce"),
        "languageFrench": MessageLookupByLibrary.simpleMessage("Fransızca"),
        "languageTurkish": MessageLookupByLibrary.simpleMessage("Türkçe"),
        "languageUrdu": MessageLookupByLibrary.simpleMessage("Urduca"),
        "loginFailedAuth": MessageLookupByLibrary.simpleMessage(
            "Google ile kimlik doğrulama başarısız oldu."),
        "loginGenericError": m5,
        "loginGoogleButton":
            MessageLookupByLibrary.simpleMessage("Google ile giriş yap"),
        "loginGreeting":
            MessageLookupByLibrary.simpleMessage("Tekrar hoş geldiniz!"),
        "loginUnsupportedDeviceMessage": MessageLookupByLibrary.simpleMessage(
            "Bu cihaz giriş için gereken Google hizmetlerini desteklemiyor."),
        "profileDefaultName": MessageLookupByLibrary.simpleMessage("Kullanıcı"),
        "profileLogoutDialogMessage": MessageLookupByLibrary.simpleMessage(
            "Çıkış yapmak istediğinizden emin misiniz?"),
        "profileLogoutDialogTitle":
            MessageLookupByLibrary.simpleMessage("Çıkış yapılsın mı?"),
        "resetProgressAction": MessageLookupByLibrary.simpleMessage("Sıfırla"),
        "resetProgressMessage": MessageLookupByLibrary.simpleMessage(
            "Bu işlem bu suredeki mevcut ilerlemenizi sıfırlayacak. Emin misiniz?"),
        "resetProgressTitle":
            MessageLookupByLibrary.simpleMessage("İlerlemeyi sıfırla"),
        "splashTagline": MessageLookupByLibrary.simpleMessage(
            "Kur\'an\'ı kolay ve eğlenceli yoldan öğrenin"),
        "submit": MessageLookupByLibrary.simpleMessage("Gönder"),
        "surahInfoBriefContextTitle":
            MessageLookupByLibrary.simpleMessage("Kısa bağlam"),
        "surahInfoOtherNameTitle":
            MessageLookupByLibrary.simpleMessage("Diğer isim"),
        "surahInfoPlaceTitle":
            MessageLookupByLibrary.simpleMessage("Nüzul yeri"),
        "surahInfoPositionTitle": MessageLookupByLibrary.simpleMessage("Sıra"),
        "surahSelectionBriefContextFallback":
            MessageLookupByLibrary.simpleMessage("Kısa bağlam"),
        "surahSelectionBriefContextTitle":
            MessageLookupByLibrary.simpleMessage("Kısa bağlam"),
        "surahSelectionDefaultName":
            MessageLookupByLibrary.simpleMessage("Sure"),
        "surahSelectionLanguageHint":
            MessageLookupByLibrary.simpleMessage("Dil"),
        "surahSelectionLessInfo":
            MessageLookupByLibrary.simpleMessage("Daha az bilgi"),
        "surahSelectionLoadFailed": m6,
        "surahSelectionLoadingMessage": MessageLookupByLibrary.simpleMessage(
            "Kur\'an verileri yükleniyor..."),
        "surahSelectionMoreInfo":
            MessageLookupByLibrary.simpleMessage("Daha fazla bilgi"),
        "surahSelectionOtherNameFallback":
            MessageLookupByLibrary.simpleMessage("El-Mu\'awwidhatayn"),
        "surahSelectionOtherNameTitle":
            MessageLookupByLibrary.simpleMessage("Diğer isim"),
        "surahSelectionPlaceFallback":
            MessageLookupByLibrary.simpleMessage("Mekke (Mekkî)"),
        "surahSelectionPlaceTitle":
            MessageLookupByLibrary.simpleMessage("Nüzul yeri"),
        "surahSelectionPositionFallback": MessageLookupByLibrary.simpleMessage(
            "Kur\'an\'ın sonundan 20. sırada"),
        "surahSelectionPositionTitle":
            MessageLookupByLibrary.simpleMessage("Sıra"),
        "surahSelectionProgressUpdateFailed": m7,
        "surahSelectionResetFailed": m8,
        "surahSelectionRetryButton":
            MessageLookupByLibrary.simpleMessage("Tekrar dene"),
        "surahSelectionSelectSurahHint":
            MessageLookupByLibrary.simpleMessage("Sure seç"),
        "surahSelectionSummary": m9
      };
}
