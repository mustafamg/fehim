import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:holy_quran/generated/l10n.dart';
import 'package:holy_quran/main.dart';
import 'package:holy_quran/screens/components/custom_app_bar.dart';
import 'package:holy_quran/services/firestore_service.dart';
import 'package:holy_quran/values/assets_manager.dart';
import 'package:holy_quran/values/values_manager.dart';
import 'package:provider/provider.dart';

import '../../values/color_manager.dart';
import '../home/surah_selection_view_model.dart';
import '../surah_learning_path/surah_learning_path_screen.dart';
import 'arrange_puzzle_view_model.dart';

class ArrangePuzzleScreen extends StatefulWidget {
  final Map<String, dynamic> verse;
  final String? languageCode;
  const ArrangePuzzleScreen({
    super.key,
    required this.verse,
    this.languageCode,
  });
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
        if (getIt.isRegistered<SurahSelectionScreenViewModel>()) {
          final homeViewModel = getIt<SurahSelectionScreenViewModel>();
          await homeViewModel.safeRefresh();
        }
      } catch (e) {
        // Ignore refresh errors
      }
    });
  }

  Future<String> _getAudioUrl() async {
    String audioUrl = widget.verse['audioUrl'] ?? '';
    if (audioUrl.isEmpty) {
      try {
        final firestoreService = FirestoreService();
        final surahId = widget.verse['surahId'] ?? 'al_falaq';
        final surahData = await firestoreService.getSurahData(surahId);
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
      } catch (e) {
        // Ignore errors
      }
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
            final viewModel = getIt<ArrangePuzzleViewModel>();
            if (widget.verse.containsKey('words') &&
                widget.verse['words'] is List) {
              final wordsList = List<Map<String, dynamic>>.from(
                widget.verse['words'],
              );
              viewModel.init(
                wordsList,
                audioUrl,
                surahId: widget.verse['surahId'],
                verseNumber: widget.verse['verseNumber'],
              );
            } else {
              viewModel.setError(S.current.arrangePuzzleMissingData);
            }
            return viewModel;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: _Body(
                verse: widget.verse,
                languageCode: widget.languageCode,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArrangePuzzleProgressDots extends StatelessWidget {
  final ArrangePuzzleViewModel viewModel;
  const _ArrangePuzzleProgressDots({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final pageMatchedWords = viewModel.currentPageMatchedWords;
    final activeIndex = pageMatchedWords.indexWhere((word) => word == null);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageMatchedWords.length, (index) {
        final isCompleted = pageMatchedWords[index] != null;
        final isCurrent =
            !isCompleted && (activeIndex == -1 ? false : index == activeIndex);
        final isFullyCompleted = viewModel.isCurrentPageComplete;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: AppPadding.p4),
          width: isFullyCompleted ? AppSize.s24 : AppSize.s24,
          height: isFullyCompleted ? AppSize.s24 : AppSize.s24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? ColorManager.green : Colors.transparent,
            border: Border.all(
              color: isCompleted ? ColorManager.green : Colors.grey.shade300,
              width: AppSize.s1_5,
            ),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? Icon(Icons.check, color: Colors.white, size: AppSize.s16)
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
    );
  }
}

class _PuzzleBoard extends StatelessWidget {
  final ArrangePuzzleViewModel viewModel;
  final String? languageCode;
  const _PuzzleBoard({required this.viewModel, this.languageCode});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.height * AppRatio.r0_3,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.p20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(AppPadding.p16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppPadding.p20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MatchedSlots(
                        viewModel: viewModel,
                        languageCode: languageCode,
                      ),
                      SizedBox(height: AppPadding.p24),
                      _DraggableWordsWrap(viewModel: viewModel),
                    ],
                  ),
                ),
              ),
              _AudioControlsBar(viewModel: viewModel),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchedSlots extends StatelessWidget {
  final ArrangePuzzleViewModel viewModel;
  final String? languageCode;
  const _MatchedSlots({required this.viewModel, this.languageCode});

  @override
  Widget build(BuildContext context) {
    final slots = viewModel.currentPageMatchedWords;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Wrap(
          spacing: AppPadding.p8,
          runSpacing: AppPadding.p8,
          alignment: WrapAlignment.center,
          children: List.generate(slots.length, (index) {
            final displayIndex = index;
            final matchedWord = slots[displayIndex];
            final isError = viewModel.failedIndex == displayIndex;
            return DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: WidgetWidth.w60,
                  height: WidgetHeight.h40,
                  padding: EdgeInsets.all(AppSize.s4),
                  decoration: BoxDecoration(
                    color: matchedWord != null
                        ? ColorManager.green
                        : (isError
                              ? ColorManager.red
                              : const Color(0xFFF3F5F5)),
                    borderRadius: BorderRadius.circular(AppSize.s4),
                    border: Border.all(
                      color: matchedWord != null
                          ? ColorManager.green
                          : (candidateData.isNotEmpty
                                ? ColorManager.primary
                                : (isError
                                      ? ColorManager.red
                                      : const Color(0xFFD9DBE1))),
                      width: AppRatio.r0_6,
                    ),
                  ),
                  alignment: Alignment.center,
                  child:
                      matchedWord != null ||
                          (isError && viewModel.failedWord != null)
                      ? Text(
                          matchedWord ?? viewModel.failedWord!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontFamily: 'Uthmanic',
                              ),
                          textAlign: TextAlign.center,
                          maxLines: AppCount.c1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                );
              },
              onWillAcceptWithDetails: (_) => matchedWord == null,
              onAcceptWithDetails: (details) {
                viewModel.onWordDropped(details.data, displayIndex);
              },
            );
          }),
        ),
      ),
    );
  }
}

class _DraggableWordsWrap extends StatelessWidget {
  final ArrangePuzzleViewModel viewModel;
  const _DraggableWordsWrap({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: AppPadding.p8,
        runSpacing: AppPadding.p8,
        alignment: WrapAlignment.center,
        children: viewModel.draggableWords.map((word) {
          return Draggable<String>(
            data: word,
            feedback: _DraggableWordWidget(word: word, isDragging: true),
            childWhenDragging: Opacity(
              opacity: AppOpacity.o0_3,
              child: _DraggableWordWidget(word: word),
            ),
            child: _DraggableWordWidget(word: word),
          );
        }).toList(),
      ),
    );
  }
}

class _AudioControlsBar extends StatelessWidget {
  final ArrangePuzzleViewModel viewModel;
  const _AudioControlsBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            onTap: viewModel.toggleAudio,
            child: viewModel.isAudioLoading
                ? SizedBox(
                    width: AppSize.s28,
                    height: AppSize.s28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Icon(
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
                overlayColor: Colors.white.withValues(alpha: AppOpacity.a0_1),
              ),
              child: Slider(
                value: viewModel.currentPosition.inMilliseconds.toDouble(),
                min: AppSize.s0,
                max: viewModel.totalDuration.inMilliseconds > 0
                    ? viewModel.totalDuration.inMilliseconds.toDouble()
                    : AppSize.s1,
                onChanged: (value) {
                  viewModel.seekAudio(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrangePrimaryButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onPressed;
  final String label;
  const _ArrangePrimaryButton({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled && !isLoading ? onPressed : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: AppPadding.p16),
        decoration: BoxDecoration(
          color: enabled ? ColorManager.primary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(AppPadding.p12),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: enabled ? Colors.white : Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isLoading)
              Positioned(
                right: AppPadding.p24,
                child: SizedBox(
                  width: AppSize.s18,
                  height: AppSize.s18,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final Map<String, dynamic> verse;
  final String? languageCode;
  const _Body({required this.verse, this.languageCode});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  String? _lastErrorWord;
  int _lastErrorTick = 0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0.0);
    HapticFeedback.heavyImpact();
    HapticFeedback.vibrate();
  }

  void _handleBackPress(ArrangePuzzleViewModel viewModel) {
    if (viewModel.canGoPrevious) {
      viewModel.goToPreviousPage();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArrangePuzzleViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final currentError = viewModel.errorWord;
          final tick = viewModel.errorTick;
          if (currentError != null &&
              (currentError != _lastErrorWord || tick != _lastErrorTick)) {
            _lastErrorWord = currentError;
            _lastErrorTick = tick;
            _triggerShake();
          } else if (currentError == null) {
            _lastErrorWord = null;
            _lastErrorTick = 0;
          }
        });

        if (viewModel.error != null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppPadding.p20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
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
                    child: Text(S.current.arrangePuzzleGoBack),
                  ),
                ],
              ),
            ),
          );
        }

        return AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final dx = math.sin(_shakeController.value * math.pi * 6) * 8;
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: PopScope(
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                _handleBackPress(viewModel);
              }
            },
            child: Column(
              children: [
                CustomAppBar(
                  title: S.current.arrangePuzzleTitle,
                  subtitle: S.current.arrangePuzzleSubtitle,
                  showBackButton: false,
                  showProgress: true,
                  currentStep: viewModel.matchedCount,
                  totalSteps: viewModel.matchedWords.length,
                  onBackPressed: () => _handleBackPress(viewModel),
                ),
                SizedBox(height: AppPadding.p8),
                _ArrangePuzzleProgressDots(viewModel: viewModel),
                SizedBox(height: AppPadding.p40),
                Expanded(
                  child: _PuzzleBoard(
                    viewModel: viewModel,
                    languageCode: widget.languageCode,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(AppPadding.p20),
                  child: Builder(
                    builder: (context) {
                      final canFinish = viewModel.isAllMatched;
                      final canAdvancePage =
                          viewModel.isCurrentPageComplete &&
                          viewModel.canGoNext;
                      final buttonLabel = canFinish
                          ? S.current.arrangePuzzleFinish
                          : S.current.commonNext;
                      final showLoader = canFinish && viewModel.isFinishLoading;
                      final enabled = canFinish
                          ? !viewModel.isFinishLoading
                          : canAdvancePage;
                      final action = canFinish
                          ? (enabled ? _handleFinishTap : null)
                          : (enabled ? viewModel.goToNextPage : null);

                      return _ArrangePrimaryButton(
                        label: buttonLabel,
                        enabled: enabled,
                        isLoading: showLoader,
                        onPressed: action,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleFinishTap() async {
    final viewModel = context.read<ArrangePuzzleViewModel>();
    if (viewModel.isFinishLoading) return;
    viewModel.setFinishLoading(true);
    try {
      await _showFinishDialog();
    } finally {
      viewModel.setFinishLoading(false);
    }
  }

  Future<void> _showFinishDialog() async {
    final viewModel = context.read<ArrangePuzzleViewModel>();
    final homeViewModel = getIt<SurahSelectionScreenViewModel>();
    if (homeViewModel.totalVerses == AppSize.s0) {
      await homeViewModel.initialize();
    }
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
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
                  child: Center(
                    child: SvgPicture.asset(
                      IconAssets.congrats,
                      width: AppSize.s40,
                      height: AppSize.s40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.current.arrangePuzzleCongratsTitle,
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
                        TextSpan(text: S.current.arrangePuzzleEarnedPrefix),
                        TextSpan(
                          text: S.current.arrangePuzzleEarnedHighlight(1),
                          style: TextStyle(color: ColorManager.green),
                        ),
                        TextSpan(text: S.current.arrangePuzzleEarnedSuffix),
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
                              homeViewModel.surahName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              homeViewModel.arabicName,
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
                          '${widget.verse['verseNumber']} - ${_resolveTranslation(widget.verse['translations'], widget.languageCode)} - ${widget.verse['arabic'] ?? ''}',
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
                                  S.current.commonHome,
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

                                  await homeViewModel.refresh();
                                  if (!context.mounted) return;
                                  final nextVerseNumber =
                                      homeViewModel.currentVerse;
                                  if (nextVerseNumber <=
                                      homeViewModel.totalVerses) {
                                    final nextVerse = Map<String, dynamic>.from(
                                      homeViewModel.verses.firstWhere(
                                        (verse) =>
                                            verse['verseNumber'] ==
                                            nextVerseNumber,
                                        orElse: () => widget.verse,
                                      ),
                                    );
                                    nextVerse['surahId'] =
                                        homeViewModel.selectedSurahId;

                                    if (!context.mounted) return;
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SurahLearningPathScreen(
                                              verse: nextVerse,
                                              languageCode:
                                                  homeViewModel.languageCode,
                                            ),
                                      ),
                                    );
                                  } else {
                                    if (!context.mounted) return;
                                    Navigator.of(
                                      context,
                                    ).popUntil((route) => route.isFirst);
                                  }
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
                                  S.current.arrangePuzzleNextVerse,
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
  return LayoutBuilder(
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
  );
}

String _resolveTranslation(dynamic translations, String? preferred) {
  if (translations == null) return '';
  if (translations is Map) {
    final map = translations.map((key, value) => MapEntry('$key', '$value'));
    final preferredValue = preferred != null ? map[preferred] : null;
    if (preferredValue is String && preferredValue.trim().isNotEmpty) {
      return preferredValue.trim();
    }
    final englishValue = map['en'];
    if (englishValue is String && englishValue.trim().isNotEmpty) {
      return englishValue.trim();
    }
    try {
      final fallback = map.values.firstWhere(
        (value) => value.trim().isNotEmpty,
        orElse: () => '',
      );
      return fallback.trim();
    } catch (_) {
      return '';
    }
  }
  if (translations is String) {
    return translations.trim();
  }
  return '';
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
        width: 60.w,
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
