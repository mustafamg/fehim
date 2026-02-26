import 'dart:math';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../values/color_manager.dart';

enum SegmentType { text, gapWord }

class GapWordModel {
  final String fullWord;
  final int missingIndex;
  final String expectedLetter;
  String currentLetter = '';
  late GapWordController controller;
  final bool isArabic;
  final String placeholder;

  GapWordModel({
    required this.fullWord,
    required this.missingIndex,
    required this.isArabic,
  }) : expectedLetter = fullWord[missingIndex],
       placeholder = isArabic ? 'ـ' : '_' {
    controller = GapWordController(
      fullWord: fullWord,
      missingIndex: missingIndex,
      placeholder: placeholder,
    );
    controller.text = fullWord.replaceRange(
      missingIndex,
      missingIndex + 1,
      placeholder,
    );
  }

  bool get isCompleted =>
      currentLetter.toLowerCase() == expectedLetter.toLowerCase();
}

class GapWordController extends TextEditingController {
  final String fullWord;
  final int missingIndex;
  final String placeholder;

  GapWordController({
    required this.fullWord,
    required this.missingIndex,
    required this.placeholder,
  });

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    List<TextSpan> children = [];
    for (int i = 0; i < text.length; i++) {
      if (i == missingIndex) {
        bool isPlaceholder = text[i] == placeholder;
        bool isCorrect = false;
        if (!isPlaceholder) {
          isCorrect =
              text[i].toLowerCase() == fullWord[missingIndex].toLowerCase();
        }
        children.add(
          TextSpan(
            text: text[i],
            style: style?.copyWith(
              color: isPlaceholder
                  ? Colors.grey
                  : (isCorrect ? ColorManager.green : ColorManager.red),
            ),
          ),
        );
      } else {
        children.add(
          TextSpan(
            text: text[i],
            style: style?.copyWith(color: Colors.black),
          ),
        );
      }
    }
    return TextSpan(style: style, children: children);
  }
}

class TextSegment {
  final String text;
  final SegmentType type;
  final GapWordModel? gap;

  TextSegment.text(this.text) : type = SegmentType.text, gap = null;
  TextSegment.gapWord(
    String fullWord,
    int missingIndex, {
    required bool isArabic,
  }) : type = SegmentType.gapWord,
       text = fullWord,
       gap = GapWordModel(
         fullWord: fullWord,
         missingIndex: missingIndex,
         isArabic: isArabic,
       );
}

@Injectable()
class FillGapsViewModel extends ChangeNotifier {
  List<TextSegment> arabicSegments = [];
  List<TextSegment> englishSegments = [];

  bool get isAllCompleted {
    if (arabicSegments.isEmpty && englishSegments.isEmpty) return false;
    bool arabicDone = arabicSegments
        .where((s) => s.type == SegmentType.gapWord)
        .every((s) => s.gap!.isCompleted);
    bool englishDone = englishSegments
        .where((s) => s.type == SegmentType.gapWord)
        .every((s) => s.gap!.isCompleted);
    return arabicDone && englishDone;
  }

  int get totalGapsCount {
    int ar = arabicSegments.where((s) => s.type == SegmentType.gapWord).length;
    int en = englishSegments.where((s) => s.type == SegmentType.gapWord).length;
    return ar + en;
  }

  int get completedGapsCount {
    int ar = arabicSegments
        .where((s) => s.type == SegmentType.gapWord && s.gap!.isCompleted)
        .length;
    int en = englishSegments
        .where((s) => s.type == SegmentType.gapWord && s.gap!.isCompleted)
        .length;
    return ar + en;
  }

  int _getRandomBaseCharIndex(String word, Random random) {
    List<int> baseIndices = [];
    for (int i = 0; i < word.length; i++) {
      int code = word.codeUnitAt(i);
      // Arabic letters or English letters
      if ((code >= 0x0621 && code <= 0x064A) ||
          (code >= 0x0041 && code <= 0x005A) ||
          (code >= 0x0061 && code <= 0x007A)) {
        baseIndices.add(i);
      }
    }
    if (baseIndices.isEmpty) return 0;
    return baseIndices[random.nextInt(baseIndices.length)];
  }

  void init(Map<String, dynamic> verse) {
    List<dynamic> wordsList = verse['words'] ?? [];
    if (wordsList.isEmpty) return;

    final random = Random();
    List<int> candidateIndices = List.generate(wordsList.length, (i) => i);
    candidateIndices.shuffle(random);

    int gapsPerLang = wordsList.length > 3 ? 2 : 1;
    List<int> arabicGapIndices = candidateIndices.take(gapsPerLang).toList();
    candidateIndices.shuffle(random);
    List<int> englishGapIndices = candidateIndices.take(gapsPerLang).toList();

    for (int i = 0; i < wordsList.length; i++) {
      String arWord = wordsList[i]['arabic'] ?? '';
      if (arabicGapIndices.contains(i) && arWord.isNotEmpty) {
        int missingIdx = _getRandomBaseCharIndex(arWord, random);
        arabicSegments.add(
          TextSegment.gapWord(arWord, missingIdx, isArabic: true),
        );
      } else {
        arabicSegments.add(TextSegment.text(arWord));
      }

      String enWord = wordsList[i]['translation']?['en'] ?? '';
      if (enWord.isNotEmpty) {
        if (englishGapIndices.contains(i) && enWord.isNotEmpty) {
          int missingIdx = _getRandomBaseCharIndex(enWord, random);
          englishSegments.add(
            TextSegment.gapWord(enWord, missingIdx, isArabic: false),
          );
        } else {
          englishSegments.add(TextSegment.text(enWord));
        }
      }
    }
    notifyListeners();
  }

  void onGapChanged(GapWordModel gap, String value) {
    if (gap.isCompleted) return;

    String prefix = gap.fullWord.substring(0, gap.missingIndex);
    String suffix = gap.fullWord.substring(gap.missingIndex + 1);
    String expectedOldText =
        prefix +
        (gap.currentLetter.isEmpty ? gap.placeholder : gap.currentLetter) +
        suffix;

    if (value == expectedOldText) return;

    String newChar = gap.currentLetter;

    if (value.length < expectedOldText.length) {
      // They deleted something
      newChar = '';
    } else if (value.length > expectedOldText.length) {
      // They typed something
      int diffIndex = -1;
      for (int i = 0; i < expectedOldText.length; i++) {
        if (i >= value.length || value[i] != expectedOldText[i]) {
          diffIndex = i;
          break;
        }
      }
      if (diffIndex == -1) {
        diffIndex = expectedOldText.length;
      }
      newChar = value[diffIndex];
    } else {
      // Replaced exactly one character
      int diffIndex = -1;
      for (int i = 0; i < expectedOldText.length; i++) {
        if (value[i] != expectedOldText[i]) {
          diffIndex = i;
          break;
        }
      }
      if (diffIndex != -1) {
        newChar = value[diffIndex];
      }
    }

    gap.currentLetter = newChar;

    if (gap.isCompleted) {
      gap.currentLetter = gap.expectedLetter;
    }

    String nextText =
        prefix +
        (gap.currentLetter.isEmpty ? gap.placeholder : gap.currentLetter) +
        suffix;

    gap.controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(
        offset: gap.isCompleted
            ? nextText.length
            : prefix.length +
                  (gap.currentLetter.isEmpty
                      ? gap.placeholder.length
                      : gap.currentLetter.length),
      ),
    );

    notifyListeners();
  }
}
