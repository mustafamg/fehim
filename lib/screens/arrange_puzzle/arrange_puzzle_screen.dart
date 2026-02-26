import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holy_quran/main.dart';
import 'package:holy_quran/services/firestore_service.dart';
import 'package:holy_quran/values/assets_manager.dart';
import 'package:provider/provider.dart';

import '../../values/color_manager.dart';
import '../../values/values_manager.dart';
import '../home/surah_selection_view_model.dart';
import 'arrange_puzzle_view_model.dart';

class ArrangePuzzleScreen extends StatefulWidget {
  final Map<String, dynamic> verse;
  const ArrangePuzzleScreen({super.key, required this.verse});
  @override
  State<ArrangePuzzleScreen> createState() => _ArrangePuzzleScreenState();
}

class _ArrangePuzzleScreenState extends State<ArrangePuzzleScreen> {
  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshHomeScreen();
    });
    super.dispose();
  }

  void _refreshHomeScreen() {
    Future.delayed(const Duration(milliseconds: AppDuration.d100), () async {
      try {
        final homeViewModel = getIt<SurahSelectionScreenViewModel>();
        await homeViewModel.refresh();
      } catch (e) {}
    });
  }

  Future<String> _getAudioUrl() async {
    String audioUrl = widget.verse['audioUrl'] ?? '';
    if (audioUrl.isEmpty) {
      try {
        final firestoreService = FirestoreService();
        final surahData = await firestoreService.getSurahData('al_falaq');
        final verses = List<Map<String, dynamic>>.from(
          surahData['verses'] ?? [],
        );
        final currentVerse = verses.firstWhere(
          (v) => v['verseNumber'] == widget.verse['verseNumber'],
          orElse: () {
            return <String, dynamic>{};
          },
        );
        audioUrl = currentVerse['audioUrl'] ?? currentVerse['audio'] ?? '';
      } catch (e) {}
    }
    return audioUrl;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getAudioUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final audioUrl = snapshot.data ?? '';
        return ChangeNotifierProvider(
          create: (_) {
            final viewModel = ArrangePuzzleViewModel();
            if (widget.verse.containsKey('words') &&
                widget.verse['words'] is List) {
              final wordsList = List<Map<String, dynamic>>.from(
                widget.verse['words'],
              );
              viewModel.init(
                wordsList,
                audioUrl,
                userId: widget.verse['userId'],
                surahId: widget.verse['surahId'],
                verseNumber: widget.verse['verseNumber'],
              );
            } else {
              viewModel.setError(
                'Missing puzzle data. Please complete the learning path first.',
              );
            }
            return viewModel;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(child: _Body(verse: widget.verse)),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final Map<String, dynamic> verse;
  const _Body({required this.verse});
  @override
  Widget build(BuildContext context) {
    return Consumer<ArrangePuzzleViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.error != null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppPadding.p20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: AppSize.s64,
                    color: Colors.red,
                  ),
                  SizedBox(height: AppPadding.p16),
                  Text(
                    viewModel.error!,
                    style: TextStyle(
                      fontSize: AppSize.s16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppPadding.p16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.p20,
                vertical: AppPadding.p16,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: AppSize.s24,
                      color: Colors.black87,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
                      child: Container(
                        height: AppSize.s8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(AppSize.s4),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: viewModel.matchedWords.isEmpty
                              ? AppSize.s0
                              : viewModel.matchedWords
                                        .where((w) => w != null)
                                        .length /
                                    viewModel.matchedWords.length,
                          child: Container(
                            decoration: BoxDecoration(
                              color: ColorManager.primary,
                              borderRadius: BorderRadius.circular(AppSize.s4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppPadding.p16),
            Text(
              'Arrange the Puzzle',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
            SizedBox(height: AppPadding.p4),
            Text(
              "Let's put the pieces together",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: ColorManager.primary),
            ),
            SizedBox(height: AppPadding.p20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(AppCount.c4, (index) {
                int totalWords = viewModel.matchedWords.length;
                int matchedCount = viewModel.matchedWords
                    .where((w) => w != null)
                    .length;
                double progressRatio = totalWords == AppSize.s0
                    ? AppSize.s0
                    : matchedCount / totalWords;
                int dotsToFill = (progressRatio * AppCount.c4).floor();
                bool isCompleted = index < dotsToFill;
                bool isCurrent = index == dotsToFill;
                if (viewModel.isAllMatched) {
                  isCompleted = true;
                  isCurrent = false;
                }
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: AppPadding.p4),
                  width: isCompleted ? AppSize.s24 : AppSize.s24,
                  height: isCompleted ? AppSize.s24 : AppSize.s24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? ColorManager.green
                        : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? ColorManager.green
                          : (isCurrent
                                ? Colors.grey.shade300
                                : Colors.grey.shade300),
                      width: AppSize.s1_5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: AppSize.s16,
                        )
                      : (isCurrent
                            ? Container(
                                width: AppSize.s12,
                                height: AppSize.s12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ColorManager.primary,
                                ),
                              )
                            : null),
                );
              }),
            ),
            SizedBox(height: AppPadding.p40),
            SizedBox(
              height: context.height * AppRatio.r0_3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(AppPadding.p16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(AppPadding.p20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Wrap(
                                    spacing: AppPadding.p8,
                                    runSpacing: AppPadding.p8,
                                    alignment: WrapAlignment.center,
                                    children: List.generate(
                                      viewModel.matchedWords.length,
                                      (index) {
                                        int displayIndex =
                                            viewModel.matchedWords.length -
                                            1 -
                                            index;
                                        String? matchedWord = viewModel
                                            .matchedWords[displayIndex];
                                        bool isError =
                                            viewModel.failedIndex ==
                                            displayIndex;
                                        return DragTarget<String>(
                                          builder: (context, candidateData, rejectedData) {
                                            return Container(
                                              width: WidgetWidth.w66,
                                              height: WidgetHeight.h40,
                                              padding: EdgeInsets.all(
                                                AppSize.s4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: matchedWord != null
                                                    ? ColorManager.green
                                                    : (isError
                                                          ? ColorManager.red
                                                          : Color(0xFFF3F5F5)),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppSize.s4,
                                                    ),
                                                border: Border.all(
                                                  color: matchedWord != null
                                                      ? ColorManager.green
                                                      : (candidateData
                                                                .isNotEmpty
                                                            ? ColorManager
                                                                  .primary
                                                            : (isError
                                                                  ? ColorManager
                                                                        .red
                                                                  : Color(
                                                                      0xFFD9DBE1,
                                                                    ))),
                                                  width: AppRatio.r0_6,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child:
                                                  matchedWord != null ||
                                                      (isError &&
                                                          viewModel
                                                                  .failedWord !=
                                                              null)
                                                  ? Text(
                                                      matchedWord ??
                                                          viewModel.failedWord!,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color:
                                                                matchedWord !=
                                                                    null
                                                                ? Colors.white
                                                                : (isError
                                                                      ? Colors
                                                                            .white
                                                                      : Colors
                                                                            .black87),
                                                            fontFamily:
                                                                'Uthmanic',
                                                          ),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: AppCount.c1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : null,
                                            );
                                          },
                                          onWillAcceptWithDetails: (data) =>
                                              matchedWord == null,
                                          onAcceptWithDetails: (details) {
                                            viewModel.onWordDropped(
                                              details.data,
                                              displayIndex,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: AppPadding.p24),
                                Center(
                                  child: Wrap(
                                    spacing: AppPadding.p8,
                                    runSpacing: AppPadding.p8,
                                    alignment: WrapAlignment.center,
                                    children: viewModel.draggableWords.map((
                                      word,
                                    ) {
                                      return Draggable<String>(
                                        data: word,
                                        feedback: _DraggableWordWidget(
                                          word: word,
                                          isDragging: true,
                                        ),
                                        childWhenDragging: Opacity(
                                          opacity: AppOpacity.o0_3,
                                          child: _DraggableWordWidget(
                                            word: word,
                                          ),
                                        ),
                                        child: _DraggableWordWidget(word: word),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppPadding.p16,
                            vertical: AppPadding.p12,
                          ),
                          decoration: BoxDecoration(
                            color: viewModel.isPlaying
                                ? ColorManager.secondary
                                : Colors.grey.shade500,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(AppPadding.p16),
                              bottomRight: Radius.circular(AppPadding.p16),
                            ),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => viewModel.toggleAudio(),
                                child: Icon(
                                  viewModel.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: AppSize.s28,
                                ),
                              ),
                              SizedBox(width: AppPadding.p12),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: AppSize.s4,
                                    thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: AppSize.s8,
                                    ),
                                    overlayShape: RoundSliderOverlayShape(
                                      overlayRadius: AppSize.s16,
                                    ),
                                    activeTrackColor: Colors.white,
                                    inactiveTrackColor: Colors.white.withValues(
                                      alpha: AppOpacity.a0_3,
                                    ),
                                    thumbColor: Colors.white,
                                    overlayColor: Colors.white.withValues(
                                      alpha: AppOpacity.a0_1,
                                    ),
                                  ),
                                  child: Slider(
                                    value: viewModel
                                        .currentPosition
                                        .inMilliseconds
                                        .toDouble(),
                                    min: AppSize.s0,
                                    max:
                                        viewModel.totalDuration.inMilliseconds >
                                            0
                                        ? viewModel.totalDuration.inMilliseconds
                                              .toDouble()
                                        : AppSize.s1,
                                    onChanged: (value) {
                                      viewModel.seekAudio(
                                        Duration(milliseconds: value.toInt()),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppPadding.p20),
              child: GestureDetector(
                onTap: viewModel.isAllMatched
                    ? () => _showFinishDialog(context)
                    : null,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: AppPadding.p16),
                  decoration: BoxDecoration(
                    color: viewModel.isAllMatched
                        ? ColorManager.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(AppPadding.p12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Finish',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: viewModel.isAllMatched
                          ? Colors.white
                          : Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFinishDialog(BuildContext context) async {
    final viewModel = Provider.of<ArrangePuzzleViewModel>(
      context,
      listen: false,
    );
    final homeViewModel = getIt<SurahSelectionScreenViewModel>();
    if (homeViewModel.totalVerses == AppSize.s0) {
      await homeViewModel.initialize();
    }
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSize.s24),
              topRight: Radius.circular(AppSize.s24),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + AppPadding.p20,
            left: AppPadding.p20,
            right: AppPadding.p20,
            top: AppPadding.p40,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: -AppSize.s80,
                child: Container(
                  width: AppSize.s100,
                  height: AppSize.s100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(AppPadding.p8),
                  child: SvgPicture.asset(
                    SvgAssets.confetti,
                    fit: BoxFit.contain,
                    width: AppSize.s40,
                    height: AppSize.s40,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Congratulations',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppPadding.p8),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                      children: [
                        const TextSpan(text: "You've earned "),
                        TextSpan(
                          text: "+1 verse",
                          style: TextStyle(color: ColorManager.green),
                        ),
                        const TextSpan(text: " in your heart."),
                      ],
                    ),
                  ),
                  SizedBox(height: AppPadding.p24),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppPadding.p16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorManager.secondary.withValues(
                            alpha: AppOpacity.a0_8,
                          ),
                          ColorManager.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSize.s16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Surah Al-Falaq',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'سورة الفلق',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontFamily: 'Uthmanic',
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppPadding.p16),

                        Builder(
                          builder: (context) {
                            final totalVerses = homeViewModel.totalVerses;
                            if (totalVerses == AppSize.s0) {
                              return const SizedBox();
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ...List.generate(totalVerses, (index) {
                                  final verseNumber = index + AppCount.c1;

                                  final isCompleted =
                                      verseNumber <
                                          homeViewModel.currentVerse ||
                                      verseNumber <=
                                          homeViewModel.completedVerses;
                                  final isCurrent =
                                      verseNumber == homeViewModel.currentVerse;
                                  return Expanded(
                                    child: Row(
                                      children: [
                                        _buildProgressDot(
                                          context,
                                          isCompleted,
                                          verseNumber.toString(),
                                          isCurrent: isCurrent,
                                        ),
                                        if (index < totalVerses - 1) ...[
                                          Expanded(child: _buildDottedLine()),
                                        ],
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: AppPadding.p16),
                        Text(
                          '${verse['verseNumber']} - ${verse['translation'] ?? ''} - ${verse['arabic'] ?? ''}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                        SizedBox(height: AppPadding.p24),

                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () async {
                                  await viewModel.updateProgress();
                                  if (!context.mounted) return;

                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.2,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppPadding.p16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSize.s12,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Home',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppSize.s16,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: AppPadding.p16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await viewModel.updateProgress();
                                  if (!context.mounted) return;

                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppPadding.p16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSize.s12,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Next Verse',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppSize.s16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressDot(
    BuildContext context,
    bool isCompleted,
    String number, {
    bool isCurrent = false,
  }) {
    return Container(
      width: AppSize.s28,
      height: AppSize.s28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? Colors.white : Colors.transparent,
        border: Border.all(
          color: isCurrent ? Colors.white : Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? Icon(Icons.check, color: ColorManager.secondary, size: AppSize.s16)
          : Text(
              number,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildDottedLine() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dashWidth = 4.0;
          final dashSpace = 3.0;
          final dashCount = (constraints.maxWidth / (dashWidth + dashSpace))
              .floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (index) {
              return Container(
                width: dashWidth,
                height: 2,
                color: Colors.white.withValues(alpha: 0.5),
              );
            }),
          );
        },
      ),
    );
  }
}

class _DraggableWordWidget extends StatelessWidget {
  final String word;
  final bool isDragging;
  const _DraggableWordWidget({required this.word, this.isDragging = false});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 66.w,
        height: 40.h,
        padding: EdgeInsets.all(AppSize.s4),
        decoration: BoxDecoration(
          color: Color(0xFFF3F5F5),
          borderRadius: BorderRadius.circular(AppSize.s4),
          border: Border.all(color: Color(0xFFD9DBE1), width: 0.6),
          boxShadow: isDragging
              ? [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          word,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black87,
            fontFamily: 'Uthmanic',
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
