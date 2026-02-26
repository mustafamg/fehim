import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../values/color_manager.dart';
import '../../values/font_manager.dart';
import '../../values/values_manager.dart';
import '../ayah_learning_path/ayah_learning_path_screen.dart';
import 'surah_learning_path_view_model.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class SurahLearningPathScreen extends StatelessWidget {
  final Map<String, dynamic> verse;

  const SurahLearningPathScreen({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SurahLearningPathViewModel(),
      child: Scaffold(body: _Body(verse: verse)),
    );
  }
}

class _Body extends StatefulWidget {
  final Map<String, dynamic> verse;
  const _Body({required this.verse});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SurahLearningPathViewModel>().loadVerseData(
        arabicText: widget.verse['arabic'] as String,
        translationText:
            (widget.verse['translations'] as Map<String, dynamic>)['en']
                as String? ??
            '',
        audioUrl: widget.verse['audioUrl'] as String,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {
    // Called when returning from AyahLearningPathScreen
    context.read<SurahLearningPathViewModel>().resetAudio();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SurahLearningPathViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            // Center Content (Arabic and English words)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Arabic Words
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSize.s8,
                      runSpacing: AppSize.s8,
                      textDirection: TextDirection.rtl,
                      children: List.generate(viewModel.arabicWords.length, (
                        index,
                      ) {
                        final isHighlighted =
                            index == viewModel.currentHighlightedWordIndex;
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppPadding.p4,
                            vertical: AppPadding.p2,
                          ),
                          decoration: BoxDecoration(
                            color: isHighlighted
                                ? ColorManager.secondary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppSize.s4),
                          ),
                          child: Text(
                            viewModel.arabicWords[index],
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontFamily:
                                      'Amiri', // Or your preferred Arabic font
                                  fontSize: FontSizeManager
                                      .s24, // Fallback from s32 to s24
                                  fontWeight: FontWeight.w700,
                                  color: isHighlighted
                                      ? Colors.white
                                      : Colors.black,
                                ),
                            textDirection: TextDirection.rtl,
                          ),
                        );
                      }),
                    ),
                    SizedBox(
                      height: AppSize
                          .s8, // Fallback to existing s8, will adjust spacing differently
                    ),
                    // English Words
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSize.s4,
                      runSpacing: AppSize.s4,
                      children: List.generate(viewModel.englishWords.length, (
                        index,
                      ) {
                        // Assuming a 1-to-1 mapping or we highlight a block of English text
                        // For the design, "of what" is highlighted together.
                        final isHighlighted =
                            index ==
                            viewModel.currentHighlightedTranslationIndex;
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppPadding.p4,
                            vertical: AppPadding.p2,
                          ),
                          decoration: BoxDecoration(
                            color: isHighlighted
                                ? ColorManager.secondary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppSize.s4),
                          ),
                          child: Text(
                            viewModel.englishWords[index],
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: FontSizeManager.s18, // s18 exists
                                  fontWeight: FontWeight.w400,
                                  color: isHighlighted
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Controls
            Positioned(
              left: AppPadding.p20,
              right: AppPadding.p20,
              bottom: AppPadding.p40,
              child: Column(
                children: [
                  // Audio Player Bar
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppPadding.p16,
                      vertical: AppPadding.p8,
                    ),
                    decoration: BoxDecoration(
                      color: viewModel.isPlaying
                          ? ColorManager.secondary
                          : Colors
                                .grey, // Grey when paused, primary when playing
                      borderRadius: BorderRadius.circular(AppPadding.p12),
                    ),
                    child: Row(
                      children: [
                        // Play/Pause Button
                        GestureDetector(
                          onTap: () {
                            if (viewModel.isPlaying) {
                              viewModel.pauseAudio();
                            } else {
                              viewModel.playAudio();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(AppPadding.p8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              viewModel.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: viewModel.isPlaying
                                  ? ColorManager.secondary
                                  : Colors.grey,
                              size: AppPadding.p20,
                            ),
                          ),
                        ),
                        SizedBox(width: AppPadding.p16),
                        // Progress Slider
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white.withAlpha(
                                76,
                              ), // ~0.3 opacity
                              thumbColor: Colors.white,
                              trackHeight: 2.0,
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 6.0,
                              ),
                              overlayShape: RoundSliderOverlayShape(
                                overlayRadius: 12.0,
                              ),
                            ),
                            child: Slider(
                              value: viewModel
                                  .currentAudioPosition
                                  .inMilliseconds
                                  .toDouble(),
                              min: 0.0,
                              max:
                                  viewModel.totalAudioDuration.inMilliseconds
                                          .toDouble() >
                                      0
                                  ? viewModel.totalAudioDuration.inMilliseconds
                                        .toDouble()
                                  : 1.0,
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
                  SizedBox(
                    height: AppPadding.p24,
                  ), // Gap between player and next button
                  // Next Button
                  GestureDetector(
                    onTap: viewModel.hasFinishedPlaying
                        ? () {
                            // Stop audio before navigating
                            viewModel.pauseAudio();
                            // Navigate to AyahLearningPathScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AyahLearningPathScreen(verse: widget.verse),
                              ),
                            );
                          }
                        : null, // Disabled if audio hasn't finished
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: AppPadding.p12),
                      decoration: BoxDecoration(
                        color: viewModel.hasFinishedPlaying
                            ? ColorManager.primary
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(AppPadding.p8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Next',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: viewModel.hasFinishedPlaying
                                  ? Colors.white
                                  : Colors.grey.shade500,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
