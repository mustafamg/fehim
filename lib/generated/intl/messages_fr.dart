// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(count) =>
      "${Intl.plural(count, one: '+${count} verset', other: '+${count} versets')}";

  static String m1(audioUrl) => "Audio non disponible hors ligne : ${audioUrl}";

  static String m2(audioUrl) =>
      "Audio non disponible hors ligne pour la mise en cache : ${audioUrl}";

  static String m3(error) => "Erreur de lecture audio : ${error}";

  static String m4(message) => "Erreur : ${message}";

  static String m5(error) => "Erreur lors de la connexion Google : ${error}";

  static String m6(error) =>
      "Échec du chargement des données de la sourate : ${error}";

  static String m7(error) =>
      "Échec de la mise à jour de la progression : ${error}";

  static String m8(error) =>
      "Échec de la réinitialisation de la progression : ${error}";

  static String m9(juzNumber, surahNumber, totalVerses) =>
      "Juz\' ${juzNumber} - Sourate numéro ${surahNumber} - Versets ${totalVerses}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "arrangePuzzleCongratsTitle":
            MessageLookupByLibrary.simpleMessage("Félicitations"),
        "arrangePuzzleEarnedHighlight": m0,
        "arrangePuzzleEarnedPrefix":
            MessageLookupByLibrary.simpleMessage("Vous avez gagné "),
        "arrangePuzzleEarnedSuffix":
            MessageLookupByLibrary.simpleMessage(" dans votre cœur."),
        "arrangePuzzleFinish": MessageLookupByLibrary.simpleMessage("Terminer"),
        "arrangePuzzleGoBack": MessageLookupByLibrary.simpleMessage("Retour"),
        "arrangePuzzleMissingData": MessageLookupByLibrary.simpleMessage(
            "Données du puzzle manquantes. Veuillez terminer le parcours d\'apprentissage d\'abord."),
        "arrangePuzzleNextVerse":
            MessageLookupByLibrary.simpleMessage("Verset suivant"),
        "arrangePuzzleSubtitle":
            MessageLookupByLibrary.simpleMessage("Assemblons les pièces"),
        "arrangePuzzleTitle":
            MessageLookupByLibrary.simpleMessage("Assembler le puzzle"),
        "audioNotAvailableMessage": m1,
        "audioNotCachedMessage": m2,
        "audioPlaybackError": m3,
        "ayahLearningEmptyMessage": MessageLookupByLibrary.simpleMessage(
            "Aucune donnée de mots disponible pour ce verset."),
        "ayahLearningSubtitle":
            MessageLookupByLibrary.simpleMessage("Explorons chaque mot"),
        "ayahLearningTitle":
            MessageLookupByLibrary.simpleMessage("Découvrir les mots"),
        "commonCancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "commonContinue": MessageLookupByLibrary.simpleMessage("Continuer"),
        "commonErrorWithMessage": m4,
        "commonHome": MessageLookupByLibrary.simpleMessage("Accueil"),
        "commonLogout": MessageLookupByLibrary.simpleMessage("Déconnexion"),
        "commonNext": MessageLookupByLibrary.simpleMessage("Suivant"),
        "connectMeaningSubtitle": MessageLookupByLibrary.simpleMessage(
            "Associez les mots à leurs sens"),
        "connectMeaningTitle":
            MessageLookupByLibrary.simpleMessage("Relier les significations"),
        "fillGapsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Remplissez les parties manquantes"),
        "fillGapsTitle":
            MessageLookupByLibrary.simpleMessage("Compléter les lacunes"),
        "languageArabic": MessageLookupByLibrary.simpleMessage("Arabe"),
        "languageEnglish": MessageLookupByLibrary.simpleMessage("Anglais"),
        "languageFrench": MessageLookupByLibrary.simpleMessage("Français"),
        "languageTurkish": MessageLookupByLibrary.simpleMessage("Turc"),
        "languageUrdu": MessageLookupByLibrary.simpleMessage("Ourdou"),
        "loginFailedAuth": MessageLookupByLibrary.simpleMessage(
            "Échec de l\'authentification Google."),
        "loginGenericError": m5,
        "loginGoogleButton":
            MessageLookupByLibrary.simpleMessage("Se connecter avec Google"),
        "loginGreeting":
            MessageLookupByLibrary.simpleMessage("Content de vous revoir !"),
        "loginUnsupportedDeviceMessage": MessageLookupByLibrary.simpleMessage(
            "Cet appareil ne prend pas en charge les services Google requis pour la connexion."),
        "profileDefaultName":
            MessageLookupByLibrary.simpleMessage("Utilisateur"),
        "profileLogoutDialogMessage": MessageLookupByLibrary.simpleMessage(
            "Voulez-vous vraiment vous déconnecter ?"),
        "profileLogoutDialogTitle":
            MessageLookupByLibrary.simpleMessage("Se déconnecter ?"),
        "resetProgressAction":
            MessageLookupByLibrary.simpleMessage("Réinitialiser"),
        "resetProgressMessage": MessageLookupByLibrary.simpleMessage(
            "Cela réinitialisera votre progression actuelle pour cette sourate. Êtes-vous sûr ?"),
        "resetProgressTitle": MessageLookupByLibrary.simpleMessage(
            "Réinitialiser la progression"),
        "splashTagline": MessageLookupByLibrary.simpleMessage(
            "Apprenez le Coran de manière simple et ludique"),
        "submit": MessageLookupByLibrary.simpleMessage("Envoyer"),
        "surahInfoBriefContextTitle":
            MessageLookupByLibrary.simpleMessage("Contexte bref"),
        "surahInfoOtherNameTitle":
            MessageLookupByLibrary.simpleMessage("Autre nom"),
        "surahInfoPlaceTitle":
            MessageLookupByLibrary.simpleMessage("Lieu de révélation"),
        "surahInfoPositionTitle":
            MessageLookupByLibrary.simpleMessage("Position"),
        "surahSelectionBriefContextFallback":
            MessageLookupByLibrary.simpleMessage("Contexte bref"),
        "surahSelectionBriefContextTitle":
            MessageLookupByLibrary.simpleMessage("Contexte bref"),
        "surahSelectionDefaultName":
            MessageLookupByLibrary.simpleMessage("Sourate"),
        "surahSelectionLanguageHint":
            MessageLookupByLibrary.simpleMessage("Langue"),
        "surahSelectionLessInfo":
            MessageLookupByLibrary.simpleMessage("Moins d\'informations"),
        "surahSelectionLoadFailed": m6,
        "surahSelectionLoadingMessage": MessageLookupByLibrary.simpleMessage(
            "Chargement des données du Coran..."),
        "surahSelectionMoreInfo":
            MessageLookupByLibrary.simpleMessage("Plus d\'informations"),
        "surahSelectionOtherNameFallback":
            MessageLookupByLibrary.simpleMessage("Al-Mu\'awwidhatayn"),
        "surahSelectionOtherNameTitle":
            MessageLookupByLibrary.simpleMessage("Autre nom"),
        "surahSelectionPlaceFallback":
            MessageLookupByLibrary.simpleMessage("La Mecque (mekkoise)"),
        "surahSelectionPlaceTitle":
            MessageLookupByLibrary.simpleMessage("Lieu de révélation"),
        "surahSelectionPositionFallback": MessageLookupByLibrary.simpleMessage(
            "20ᵉ à partir de la fin du Coran"),
        "surahSelectionPositionTitle":
            MessageLookupByLibrary.simpleMessage("Position"),
        "surahSelectionProgressUpdateFailed": m7,
        "surahSelectionResetFailed": m8,
        "surahSelectionRetryButton":
            MessageLookupByLibrary.simpleMessage("Réessayer"),
        "surahSelectionSelectSurahHint":
            MessageLookupByLibrary.simpleMessage("Choisir une sourate"),
        "surahSelectionSummary": m9
      };
}
