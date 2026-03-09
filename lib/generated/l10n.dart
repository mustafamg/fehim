// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Audio not available offline for caching: {audioUrl}`
  String audioNotCachedMessage(String audioUrl) {
    return Intl.message(
      'Audio not available offline for caching: $audioUrl',
      name: 'audioNotCachedMessage',
      desc: '',
      args: [audioUrl],
    );
  }

  /// `Audio not available offline: {audioUrl}`
  String audioNotAvailableMessage(String audioUrl) {
    return Intl.message(
      'Audio not available offline: $audioUrl',
      name: 'audioNotAvailableMessage',
      desc: '',
      args: [audioUrl],
    );
  }

  /// `Learn Quran the Easy & Fun Way`
  String get splashTagline {
    return Intl.message(
      'Learn Quran the Easy & Fun Way',
      name: 'splashTagline',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get profileDefaultName {
    return Intl.message('User', name: 'profileDefaultName', desc: '', args: []);
  }

  /// `Log out?`
  String get profileLogoutDialogTitle {
    return Intl.message(
      'Log out?',
      name: 'profileLogoutDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get profileLogoutDialogMessage {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'profileLogoutDialogMessage',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get commonCancel {
    return Intl.message('Cancel', name: 'commonCancel', desc: '', args: []);
  }

  /// `Logout`
  String get commonLogout {
    return Intl.message('Logout', name: 'commonLogout', desc: '', args: []);
  }

  /// `Next`
  String get commonNext {
    return Intl.message('Next', name: 'commonNext', desc: '', args: []);
  }

  /// `Continue`
  String get commonContinue {
    return Intl.message('Continue', name: 'commonContinue', desc: '', args: []);
  }

  /// `Error: {message}`
  String commonErrorWithMessage(String message) {
    return Intl.message(
      'Error: $message',
      name: 'commonErrorWithMessage',
      desc: '',
      args: [message],
    );
  }

  /// `Hello Again!`
  String get loginGreeting {
    return Intl.message(
      'Hello Again!',
      name: 'loginGreeting',
      desc: '',
      args: [],
    );
  }

  /// `Login with Google`
  String get loginGoogleButton {
    return Intl.message(
      'Login with Google',
      name: 'loginGoogleButton',
      desc: '',
      args: [],
    );
  }

  /// `Failed to authenticate with Google.`
  String get loginFailedAuth {
    return Intl.message(
      'Failed to authenticate with Google.',
      name: 'loginFailedAuth',
      desc: '',
      args: [],
    );
  }

  /// `Error during Google sign in: {error}`
  String loginGenericError(String error) {
    return Intl.message(
      'Error during Google sign in: $error',
      name: 'loginGenericError',
      desc: '',
      args: [error],
    );
  }

  /// `This device doesn't support Google services required for sign in.`
  String get loginUnsupportedDeviceMessage {
    return Intl.message(
      'This device doesn\'t support Google services required for sign in.',
      name: 'loginUnsupportedDeviceMessage',
      desc: '',
      args: [],
    );
  }

  /// `Surah`
  String get surahSelectionDefaultName {
    return Intl.message(
      'Surah',
      name: 'surahSelectionDefaultName',
      desc: '',
      args: [],
    );
  }

  /// `Loading Quran data...`
  String get surahSelectionLoadingMessage {
    return Intl.message(
      'Loading Quran data...',
      name: 'surahSelectionLoadingMessage',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get surahSelectionRetryButton {
    return Intl.message(
      'Retry',
      name: 'surahSelectionRetryButton',
      desc: '',
      args: [],
    );
  }

  /// `Select surah`
  String get surahSelectionSelectSurahHint {
    return Intl.message(
      'Select surah',
      name: 'surahSelectionSelectSurahHint',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get surahSelectionLanguageHint {
    return Intl.message(
      'Language',
      name: 'surahSelectionLanguageHint',
      desc: '',
      args: [],
    );
  }

  /// `Juz' {juzNumber} - Surah Number {surahNumber} - Verses {totalVerses}`
  String surahSelectionSummary(
    int juzNumber,
    int surahNumber,
    int totalVerses,
  ) {
    return Intl.message(
      'Juz\' $juzNumber - Surah Number $surahNumber - Verses $totalVerses',
      name: 'surahSelectionSummary',
      desc: '',
      args: [juzNumber, surahNumber, totalVerses],
    );
  }

  /// `Place of Revelation`
  String get surahSelectionPlaceTitle {
    return Intl.message(
      'Place of Revelation',
      name: 'surahSelectionPlaceTitle',
      desc: '',
      args: [],
    );
  }

  /// `Mecca (Meccan)`
  String get surahSelectionPlaceFallback {
    return Intl.message(
      'Mecca (Meccan)',
      name: 'surahSelectionPlaceFallback',
      desc: '',
      args: [],
    );
  }

  /// `Position`
  String get surahSelectionPositionTitle {
    return Intl.message(
      'Position',
      name: 'surahSelectionPositionTitle',
      desc: '',
      args: [],
    );
  }

  /// `20th from the end of the Qur'an`
  String get surahSelectionPositionFallback {
    return Intl.message(
      '20th from the end of the Qur\'an',
      name: 'surahSelectionPositionFallback',
      desc: '',
      args: [],
    );
  }

  /// `Other Name`
  String get surahSelectionOtherNameTitle {
    return Intl.message(
      'Other Name',
      name: 'surahSelectionOtherNameTitle',
      desc: '',
      args: [],
    );
  }

  /// `Al-Mu'awwidhatayn`
  String get surahSelectionOtherNameFallback {
    return Intl.message(
      'Al-Mu\'awwidhatayn',
      name: 'surahSelectionOtherNameFallback',
      desc: '',
      args: [],
    );
  }

  /// `Brief context`
  String get surahSelectionBriefContextTitle {
    return Intl.message(
      'Brief context',
      name: 'surahSelectionBriefContextTitle',
      desc: '',
      args: [],
    );
  }

  /// `Brief Context`
  String get surahSelectionBriefContextFallback {
    return Intl.message(
      'Brief Context',
      name: 'surahSelectionBriefContextFallback',
      desc: '',
      args: [],
    );
  }

  /// `Less Information`
  String get surahSelectionLessInfo {
    return Intl.message(
      'Less Information',
      name: 'surahSelectionLessInfo',
      desc: '',
      args: [],
    );
  }

  /// `More Information`
  String get surahSelectionMoreInfo {
    return Intl.message(
      'More Information',
      name: 'surahSelectionMoreInfo',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update progress: {error}`
  String surahSelectionProgressUpdateFailed(String error) {
    return Intl.message(
      'Failed to update progress: $error',
      name: 'surahSelectionProgressUpdateFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Failed to reset progress: {error}`
  String surahSelectionResetFailed(String error) {
    return Intl.message(
      'Failed to reset progress: $error',
      name: 'surahSelectionResetFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Failed to load surah data: {error}`
  String surahSelectionLoadFailed(String error) {
    return Intl.message(
      'Failed to load surah data: $error',
      name: 'surahSelectionLoadFailed',
      desc: '',
      args: [error],
    );
  }

  /// `English`
  String get languageEnglish {
    return Intl.message('English', name: 'languageEnglish', desc: '', args: []);
  }

  /// `Arabic`
  String get languageArabic {
    return Intl.message('Arabic', name: 'languageArabic', desc: '', args: []);
  }

  /// `French`
  String get languageFrench {
    return Intl.message('French', name: 'languageFrench', desc: '', args: []);
  }

  /// `Urdu`
  String get languageUrdu {
    return Intl.message('Urdu', name: 'languageUrdu', desc: '', args: []);
  }

  /// `Turkish`
  String get languageTurkish {
    return Intl.message('Turkish', name: 'languageTurkish', desc: '', args: []);
  }

  /// `Fill the Gaps`
  String get fillGapsTitle {
    return Intl.message(
      'Fill the Gaps',
      name: 'fillGapsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Complete the missing parts`
  String get fillGapsSubtitle {
    return Intl.message(
      'Complete the missing parts',
      name: 'fillGapsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Connect Meanings`
  String get connectMeaningTitle {
    return Intl.message(
      'Connect Meanings',
      name: 'connectMeaningTitle',
      desc: '',
      args: [],
    );
  }

  /// `Link words to their meanings`
  String get connectMeaningSubtitle {
    return Intl.message(
      'Link words to their meanings',
      name: 'connectMeaningSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Discover the Words`
  String get ayahLearningTitle {
    return Intl.message(
      'Discover the Words',
      name: 'ayahLearningTitle',
      desc: '',
      args: [],
    );
  }

  /// `Let's explore each word`
  String get ayahLearningSubtitle {
    return Intl.message(
      'Let\'s explore each word',
      name: 'ayahLearningSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `No word data available for this verse.`
  String get ayahLearningEmptyMessage {
    return Intl.message(
      'No word data available for this verse.',
      name: 'ayahLearningEmptyMessage',
      desc: '',
      args: [],
    );
  }

  /// `Audio playback error: {error}`
  String audioPlaybackError(String error) {
    return Intl.message(
      'Audio playback error: $error',
      name: 'audioPlaybackError',
      desc: '',
      args: [error],
    );
  }

  /// `Arrange the Puzzle`
  String get arrangePuzzleTitle {
    return Intl.message(
      'Arrange the Puzzle',
      name: 'arrangePuzzleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Let's put the pieces together`
  String get arrangePuzzleSubtitle {
    return Intl.message(
      'Let\'s put the pieces together',
      name: 'arrangePuzzleSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Missing puzzle data. Please complete the learning path first.`
  String get arrangePuzzleMissingData {
    return Intl.message(
      'Missing puzzle data. Please complete the learning path first.',
      name: 'arrangePuzzleMissingData',
      desc: '',
      args: [],
    );
  }

  /// `Go Back`
  String get arrangePuzzleGoBack {
    return Intl.message(
      'Go Back',
      name: 'arrangePuzzleGoBack',
      desc: '',
      args: [],
    );
  }

  /// `Finish`
  String get arrangePuzzleFinish {
    return Intl.message(
      'Finish',
      name: 'arrangePuzzleFinish',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations`
  String get arrangePuzzleCongratsTitle {
    return Intl.message(
      'Congratulations',
      name: 'arrangePuzzleCongratsTitle',
      desc: '',
      args: [],
    );
  }

  /// `You've earned `
  String get arrangePuzzleEarnedPrefix {
    return Intl.message(
      'You\'ve earned ',
      name: 'arrangePuzzleEarnedPrefix',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one {+{count} verse} other {+{count} verses}}`
  String arrangePuzzleEarnedHighlight(int count) {
    return Intl.plural(
      count,
      one: '+$count verse',
      other: '+$count verses',
      name: 'arrangePuzzleEarnedHighlight',
      desc: '',
      args: [count],
    );
  }

  /// ` in your heart.`
  String get arrangePuzzleEarnedSuffix {
    return Intl.message(
      ' in your heart.',
      name: 'arrangePuzzleEarnedSuffix',
      desc: '',
      args: [],
    );
  }

  /// `Next Verse`
  String get arrangePuzzleNextVerse {
    return Intl.message(
      'Next Verse',
      name: 'arrangePuzzleNextVerse',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get commonHome {
    return Intl.message('Home', name: 'commonHome', desc: '', args: []);
  }

  /// `Reset Progress`
  String get resetProgressTitle {
    return Intl.message(
      'Reset Progress',
      name: 'resetProgressTitle',
      desc: '',
      args: [],
    );
  }

  /// `This will reset your current progress for this surah. Are you sure?`
  String get resetProgressMessage {
    return Intl.message(
      'This will reset your current progress for this surah. Are you sure?',
      name: 'resetProgressMessage',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get resetProgressAction {
    return Intl.message(
      'Reset',
      name: 'resetProgressAction',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
