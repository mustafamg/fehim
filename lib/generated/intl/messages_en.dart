// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m9(count) =>
      "${Intl.plural(count, one: '+${count} verse', other: '+${count} verses')}";

  static String m0(audioUrl) => "Audio not available offline: ${audioUrl}";

  static String m1(audioUrl) =>
      "Audio not available offline for caching: ${audioUrl}";

  static String m2(error) => "Audio playback error: ${error}";

  static String m3(message) => "Error: ${message}";

  static String m4(error) => "Error during Google sign in: ${error}";

  static String m5(error) => "Failed to load surah data: ${error}";

  static String m6(error) => "Failed to update progress: ${error}";

  static String m7(error) => "Failed to reset progress: ${error}";

  static String m8(juzNumber, surahNumber, totalVerses) =>
      "Juz\' ${juzNumber} - Surah Number ${surahNumber} - Verses ${totalVerses}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "arrangePuzzleCongratsTitle": MessageLookupByLibrary.simpleMessage(
      "Congratulations",
    ),
    "arrangePuzzleEarnedHighlight": m9,
    "arrangePuzzleEarnedPrefix": MessageLookupByLibrary.simpleMessage(
      "You\'ve earned ",
    ),
    "arrangePuzzleEarnedSuffix": MessageLookupByLibrary.simpleMessage(
      " in your heart.",
    ),
    "arrangePuzzleFinish": MessageLookupByLibrary.simpleMessage("Finish"),
    "arrangePuzzleGoBack": MessageLookupByLibrary.simpleMessage("Go Back"),
    "arrangePuzzleMissingData": MessageLookupByLibrary.simpleMessage(
      "Missing puzzle data. Please complete the learning path first.",
    ),
    "arrangePuzzleNextVerse": MessageLookupByLibrary.simpleMessage(
      "Next Verse",
    ),
    "arrangePuzzleSubtitle": MessageLookupByLibrary.simpleMessage(
      "Let\'s put the pieces together",
    ),
    "arrangePuzzleTitle": MessageLookupByLibrary.simpleMessage(
      "Arrange the Puzzle",
    ),
    "audioNotAvailableMessage": m0,
    "audioNotCachedMessage": m1,
    "audioPlaybackError": m2,
    "ayahLearningEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "No word data available for this verse.",
    ),
    "ayahLearningSubtitle": MessageLookupByLibrary.simpleMessage(
      "Let\'s explore each word",
    ),
    "ayahLearningTitle": MessageLookupByLibrary.simpleMessage(
      "Discover the Words",
    ),
    "commonCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "commonContinue": MessageLookupByLibrary.simpleMessage("Continue"),
    "commonErrorWithMessage": m3,
    "commonHome": MessageLookupByLibrary.simpleMessage("Home"),
    "commonLogout": MessageLookupByLibrary.simpleMessage("Logout"),
    "commonNext": MessageLookupByLibrary.simpleMessage("Next"),
    "connectMeaningSubtitle": MessageLookupByLibrary.simpleMessage(
      "Link words to their meanings",
    ),
    "connectMeaningTitle": MessageLookupByLibrary.simpleMessage(
      "Connect Meanings",
    ),
    "fillGapsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Complete the missing parts",
    ),
    "fillGapsTitle": MessageLookupByLibrary.simpleMessage("Fill the Gaps"),
    "languageArabic": MessageLookupByLibrary.simpleMessage("Arabic"),
    "languageEnglish": MessageLookupByLibrary.simpleMessage("English"),
    "languageFrench": MessageLookupByLibrary.simpleMessage("French"),
    "languageTurkish": MessageLookupByLibrary.simpleMessage("Turkish"),
    "languageUrdu": MessageLookupByLibrary.simpleMessage("Urdu"),
    "loginFailedAuth": MessageLookupByLibrary.simpleMessage(
      "Failed to authenticate with Google.",
    ),
    "loginGenericError": m4,
    "loginGoogleButton": MessageLookupByLibrary.simpleMessage(
      "Login with Google",
    ),
    "loginGreeting": MessageLookupByLibrary.simpleMessage("Hello Again!"),
    "loginUnsupportedDeviceMessage": MessageLookupByLibrary.simpleMessage(
      "This device doesn\'t support Google services required for sign in.",
    ),
    "profileDefaultName": MessageLookupByLibrary.simpleMessage("User"),
    "profileLogoutDialogMessage": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out?",
    ),
    "profileLogoutDialogTitle": MessageLookupByLibrary.simpleMessage(
      "Log out?",
    ),
    "resetProgressAction": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetProgressMessage": MessageLookupByLibrary.simpleMessage(
      "This will reset your current progress for this surah. Are you sure?",
    ),
    "resetProgressTitle": MessageLookupByLibrary.simpleMessage(
      "Reset Progress",
    ),
    "splashTagline": MessageLookupByLibrary.simpleMessage(
      "Learn Quran the Easy & Fun Way",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "surahSelectionBriefContextFallback": MessageLookupByLibrary.simpleMessage(
      "Brief Context",
    ),
    "surahSelectionBriefContextTitle": MessageLookupByLibrary.simpleMessage(
      "Brief context",
    ),
    "surahSelectionDefaultName": MessageLookupByLibrary.simpleMessage("Surah"),
    "surahSelectionLanguageHint": MessageLookupByLibrary.simpleMessage(
      "Language",
    ),
    "surahSelectionLessInfo": MessageLookupByLibrary.simpleMessage(
      "Less Information",
    ),
    "surahSelectionLoadFailed": m5,
    "surahSelectionLoadingMessage": MessageLookupByLibrary.simpleMessage(
      "Loading Quran data...",
    ),
    "surahSelectionMoreInfo": MessageLookupByLibrary.simpleMessage(
      "More Information",
    ),
    "surahSelectionOtherNameFallback": MessageLookupByLibrary.simpleMessage(
      "Al-Mu\'awwidhatayn",
    ),
    "surahSelectionOtherNameTitle": MessageLookupByLibrary.simpleMessage(
      "Other Name",
    ),
    "surahSelectionPlaceFallback": MessageLookupByLibrary.simpleMessage(
      "Mecca (Meccan)",
    ),
    "surahSelectionPlaceTitle": MessageLookupByLibrary.simpleMessage(
      "Place of Revelation",
    ),
    "surahSelectionPositionFallback": MessageLookupByLibrary.simpleMessage(
      "20th from the end of the Qur\'an",
    ),
    "surahSelectionPositionTitle": MessageLookupByLibrary.simpleMessage(
      "Position",
    ),
    "surahSelectionProgressUpdateFailed": m6,
    "surahSelectionResetFailed": m7,
    "surahSelectionRetryButton": MessageLookupByLibrary.simpleMessage("Retry"),
    "surahSelectionSelectSurahHint": MessageLookupByLibrary.simpleMessage(
      "Select surah",
    ),
    "surahSelectionSummary": m8,
  };
}
