// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ur locale. All the
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
  String get localeName => 'ur';

  static String m0(count) =>
      "${Intl.plural(count, one: '+${count} آیت', other: '+${count} آیات')}";

  static String m1(audioUrl) => "آڈیو آف لائن دستیاب نہیں: ${audioUrl}";

  static String m2(audioUrl) =>
      "آڈیو کو آف لائن کیش کرنے کے لیے دستیاب نہیں: ${audioUrl}";

  static String m3(error) => "آڈیو چلانے میں خرابی: ${error}";

  static String m4(message) => "خرابی: ${message}";

  static String m5(error) => "گوگل میں سائن ان کرتے وقت خرابی: ${error}";

  static String m6(error) => "سورہ کا ڈیٹا لوڈ نہیں ہو سکا: ${error}";

  static String m7(error) => "پیش رفت اپ ڈیٹ نہ ہو سکی: ${error}";

  static String m8(error) => "پیش رفت ری سیٹ نہ ہو سکی: ${error}";

  static String m9(juzNumber, surahNumber, totalVerses) =>
      "جز ${juzNumber} - سورہ نمبر ${surahNumber} - آیات ${totalVerses}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "arrangePuzzleCongratsTitle":
            MessageLookupByLibrary.simpleMessage("مبارک ہو"),
        "arrangePuzzleEarnedHighlight": m0,
        "arrangePuzzleEarnedPrefix":
            MessageLookupByLibrary.simpleMessage("آپ نے حاصل کیا "),
        "arrangePuzzleEarnedSuffix":
            MessageLookupByLibrary.simpleMessage(" اپنے دل میں۔"),
        "arrangePuzzleFinish":
            MessageLookupByLibrary.simpleMessage("مکمل کریں"),
        "arrangePuzzleGoBack":
            MessageLookupByLibrary.simpleMessage("واپس جائیں"),
        "arrangePuzzleMissingData": MessageLookupByLibrary.simpleMessage(
            "پزل کا ڈیٹا دستیاب نہیں۔ براہ کرم پہلے لرننگ پاتھ مکمل کریں۔"),
        "arrangePuzzleNextVerse":
            MessageLookupByLibrary.simpleMessage("اگلی آیت"),
        "arrangePuzzleSubtitle":
            MessageLookupByLibrary.simpleMessage("آئیے ٹکڑوں کو اکٹھا کریں"),
        "arrangePuzzleTitle":
            MessageLookupByLibrary.simpleMessage("پزل ترتیب دیں"),
        "audioNotAvailableMessage": m1,
        "audioNotCachedMessage": m2,
        "audioPlaybackError": m3,
        "ayahLearningEmptyMessage": MessageLookupByLibrary.simpleMessage(
            "اس آیت کے لیے الفاظ کا ڈیٹا دستیاب نہیں۔"),
        "ayahLearningSubtitle":
            MessageLookupByLibrary.simpleMessage("آئیے ہر لفظ کو دیکھیں"),
        "ayahLearningTitle":
            MessageLookupByLibrary.simpleMessage("الفاظ دریافت کریں"),
        "commonCancel": MessageLookupByLibrary.simpleMessage("منسوخ"),
        "commonContinue": MessageLookupByLibrary.simpleMessage("جاری رکھیں"),
        "commonErrorWithMessage": m4,
        "commonHome": MessageLookupByLibrary.simpleMessage("ہوم"),
        "commonLogout": MessageLookupByLibrary.simpleMessage("لاگ آؤٹ"),
        "commonNext": MessageLookupByLibrary.simpleMessage("اگلا"),
        "connectMeaningSubtitle": MessageLookupByLibrary.simpleMessage(
            "الفاظ کو ان کے معنی سے جوڑیں"),
        "connectMeaningTitle":
            MessageLookupByLibrary.simpleMessage("معانی ملائیں"),
        "fillGapsSubtitle":
            MessageLookupByLibrary.simpleMessage("گم شدہ حصوں کو مکمل کریں"),
        "fillGapsTitle":
            MessageLookupByLibrary.simpleMessage("خالی جگہیں پُر کریں"),
        "languageArabic": MessageLookupByLibrary.simpleMessage("عربی"),
        "languageEnglish": MessageLookupByLibrary.simpleMessage("انگریزی"),
        "languageFrench": MessageLookupByLibrary.simpleMessage("فرانسیسی"),
        "languageTurkish": MessageLookupByLibrary.simpleMessage("ترکی"),
        "languageUrdu": MessageLookupByLibrary.simpleMessage("اردو"),
        "loginFailedAuth":
            MessageLookupByLibrary.simpleMessage("گوگل سے تصدیق ناکام ہوگئی۔"),
        "loginGenericError": m5,
        "loginGoogleButton":
            MessageLookupByLibrary.simpleMessage("گوگل کے ذریعے لاگ ان کریں"),
        "loginGreeting":
            MessageLookupByLibrary.simpleMessage("دوبارہ خوش آمدید!"),
        "loginUnsupportedDeviceMessage": MessageLookupByLibrary.simpleMessage(
            "یہ ڈیوائس سائن ان کے لیے درکار گوگل سروسز کو سپورٹ نہیں کرتی۔"),
        "profileDefaultName": MessageLookupByLibrary.simpleMessage("صارف"),
        "profileLogoutDialogMessage": MessageLookupByLibrary.simpleMessage(
            "کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟"),
        "profileLogoutDialogTitle":
            MessageLookupByLibrary.simpleMessage("لاگ آؤٹ کریں؟"),
        "resetProgressAction": MessageLookupByLibrary.simpleMessage("ری سیٹ"),
        "resetProgressMessage": MessageLookupByLibrary.simpleMessage(
            "یہ اس سورہ کی موجودہ پیش رفت کو ری سیٹ کر دے گا۔ کیا آپ پُر اعتماد ہیں؟"),
        "resetProgressTitle":
            MessageLookupByLibrary.simpleMessage("پیش رفت ری سیٹ کریں"),
        "splashTagline": MessageLookupByLibrary.simpleMessage(
            "قرآن کو آسان اور دلچسپ طریقے سے سیکھیں"),
        "submit": MessageLookupByLibrary.simpleMessage("جمع کریں"),
        "surahInfoBriefContextTitle":
            MessageLookupByLibrary.simpleMessage("مختصر پس منظر"),
        "surahInfoOtherNameTitle":
            MessageLookupByLibrary.simpleMessage("دوسرا نام"),
        "surahInfoPlaceTitle":
            MessageLookupByLibrary.simpleMessage("نزول کی جگہ"),
        "surahInfoPositionTitle": MessageLookupByLibrary.simpleMessage("مقام"),
        "surahSelectionBriefContextFallback":
            MessageLookupByLibrary.simpleMessage("مختصر پس منظر"),
        "surahSelectionBriefContextTitle":
            MessageLookupByLibrary.simpleMessage("مختصر پس منظر"),
        "surahSelectionDefaultName":
            MessageLookupByLibrary.simpleMessage("سورہ"),
        "surahSelectionLanguageHint":
            MessageLookupByLibrary.simpleMessage("زبان"),
        "surahSelectionLessInfo":
            MessageLookupByLibrary.simpleMessage("کم معلومات"),
        "surahSelectionLoadFailed": m6,
        "surahSelectionLoadingMessage": MessageLookupByLibrary.simpleMessage(
            "قرآن کے اعداد و شمار لوڈ ہو رہے ہیں..."),
        "surahSelectionMoreInfo":
            MessageLookupByLibrary.simpleMessage("مزید معلومات"),
        "surahSelectionOtherNameFallback":
            MessageLookupByLibrary.simpleMessage("المعوذتان"),
        "surahSelectionOtherNameTitle":
            MessageLookupByLibrary.simpleMessage("دوسرا نام"),
        "surahSelectionPlaceFallback":
            MessageLookupByLibrary.simpleMessage("مکہ (مکی)"),
        "surahSelectionPlaceTitle":
            MessageLookupByLibrary.simpleMessage("نزول کی جگہ"),
        "surahSelectionPositionFallback":
            MessageLookupByLibrary.simpleMessage("قرآن کے آخر سے 20واں"),
        "surahSelectionPositionTitle":
            MessageLookupByLibrary.simpleMessage("مقام"),
        "surahSelectionProgressUpdateFailed": m7,
        "surahSelectionResetFailed": m8,
        "surahSelectionRetryButton":
            MessageLookupByLibrary.simpleMessage("دوبارہ کوشش کریں"),
        "surahSelectionSelectSurahHint":
            MessageLookupByLibrary.simpleMessage("سورہ منتخب کریں"),
        "surahSelectionSummary": m9
      };
}
