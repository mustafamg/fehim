import 'package:flutter/material.dart';
import 'package:holy_quran/generated/l10n.dart';
import 'package:holy_quran/screens/components/custom_app_bar.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../services/audio_cache_service.dart';
import '../../values/color_manager.dart';
import '../../values/values_manager.dart';
import '../connect_meaning/connect_meaning_screen.dart';
import 'ayah_learning_path_view_model.dart';

class AyahLearningPathScreen extends StatelessWidget {
  final Map<String, dynamic> verse;
  const AyahLearningPathScreen({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AyahLearningPathViewModel(verse, getIt<AudioCacheService>()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: _Body(verse: verse)),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final Map<String, dynamic> verse;
  const _Body({required this.verse});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late PageController _pageController;

  Future<bool> _onWillPop(AyahLearningPathViewModel viewModel) async {
    if (viewModel.currentIndex > 0) {
      await _pageController.previousPage(
        duration: Duration(milliseconds: AppDuration.d300),
        curve: Curves.easeInOut,
      );
      return false;
    }
    return true;
  }

  void _handleBackPress(
    BuildContext context,
    AyahLearningPathViewModel viewModel,
  ) {
    if (viewModel.currentIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: AppDuration.d300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: AppRatio.r0_65);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.animateToPage(
        0,
        duration: Duration(milliseconds: AppDuration.d1),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AyahLearningPathViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.words.isEmpty) {
          return Center(child: Text(S.current.ayahLearningEmptyMessage));
        }

        return WillPopScope(
          onWillPop: () => _onWillPop(viewModel),
          child: Column(
            children: [
              CustomAppBar(
                title: S.current.ayahLearningTitle,
                subtitle: S.current.ayahLearningSubtitle,
                showBackButton: false,
                showProgress: true,
                currentStep: viewModel.currentIndex,
                totalSteps: viewModel.words.length,
                onBackPressed: () => _handleBackPress(context, viewModel),
              ),
              _WordProgressDots(viewModel: viewModel),
              SizedBox(height: AppPadding.p40),
              Expanded(
                child: _WordCarousel(
                  controller: _pageController,
                  viewModel: viewModel,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppPadding.p20),
                child: _AyahNextButton(
                  enabled: viewModel.isWordFinished(viewModel.currentIndex),
                  onPressed: () {
                    if (!viewModel.isWordFinished(viewModel.currentIndex))
                      return;
                    if (viewModel.currentIndex < viewModel.words.length - 1) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: AppDuration.d300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ConnectMeaningScreen(verse: widget.verse),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WordProgressDots extends StatelessWidget {
  final AyahLearningPathViewModel viewModel;
  const _WordProgressDots({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(viewModel.words.length, (index) {
        if (index < viewModel.currentIndex || viewModel.isWordFinished(index)) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.p4),
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: AppPadding.p24,
            ),
          );
        } else if (index == viewModel.currentIndex) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.p4),
            child: Container(
              width: AppPadding.p24,
              height: AppPadding.p24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: AppSize.s2,
                ),
              ),
              child: Center(
                child: Container(
                  width: AppPadding.p12,
                  height: AppPadding.p12,
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.p4),
            child: Container(
              width: AppPadding.p24,
              height: AppPadding.p24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: AppSize.s2,
                ),
              ),
            ),
          );
        }
      }),
    );
  }
}

class _WordCarousel extends StatelessWidget {
  final PageController controller;
  final AyahLearningPathViewModel viewModel;
  const _WordCarousel({required this.controller, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      physics: viewModel.isWordFinished(viewModel.currentIndex)
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      onPageChanged: viewModel.setCurrentIndex,
      itemCount: viewModel.words.length,
      itemBuilder: (context, index) {
        final word = viewModel.words[index];
        final isCurrent = index == viewModel.currentIndex;
        final isPlayed = viewModel.isWordFinished(index);
        final isPlaying = isCurrent && viewModel.isPlaying;

        final topColor = (isPlayed || (isCurrent && isPlaying))
            ? Colors.green
            : Colors.blueGrey.shade600;

        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            double value = (viewModel.currentIndex - index).toDouble();
            if (controller.hasClients && controller.position.haveDimensions) {
              final page = controller.page;
              if (page != null) value = page - index;
            }

            final rotationZ = value * AppRatio.r0_15;
            final translateY = value.abs() * AppSize.s30;
            final scale = (1 - (value.abs() * AppRatio.r0_15)).clamp(
              AppRatio.r0_8,
              1.0,
            );
            final opacity = (1 - (value.abs() * AppRatio.r0_5)).clamp(0.0, 1.0);

            return Center(
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(AppSize.s0, translateY, AppSize.s0)
                  ..rotateZ(rotationZ)
                  ..scale(scale),
                alignment: Alignment.center,
                child: Opacity(
                  opacity: opacity,
                  child: SizedBox(
                    height: AppSize.s350,
                    width: AppSize.s280,
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: _WordCard(
            word: word,
            topColor: topColor,
            isPlaying: isPlaying,
            isCurrent: isCurrent,
            viewModel: viewModel,
          ),
        );
      },
    );
  }
}

class _WordCard extends StatelessWidget {
  final Map<String, dynamic> word;
  final Color topColor;
  final bool isPlaying;
  final bool isCurrent;
  final AyahLearningPathViewModel viewModel;

  const _WordCard({
    required this.word,
    required this.topColor,
    required this.isPlaying,
    required this.isCurrent,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppPadding.p12,
        vertical: AppPadding.p20,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppPadding.p16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(AppOpacity.a20),
            blurRadius: AppSize.s10,
            offset: Offset(AppSize.s0, AppSize.s4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: AppCount.c3,
            child: GestureDetector(
              onTap: () {
                if (isPlaying) {
                  viewModel.pauseCurrentWordAudio();
                } else if (isCurrent) {
                  viewModel.playCurrentWordAudio();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: topColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppPadding.p16),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: AppPadding.p16,
                      left: AppPadding.p16,
                      child: Container(
                        padding: EdgeInsets.all(AppPadding.p4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: viewModel.isAudioLoading
                            ? SizedBox(
                                width: AppPadding.p16,
                                height: AppPadding.p16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    topColor,
                                  ),
                                ),
                              )
                            : Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: topColor,
                                size: AppPadding.p16,
                              ),
                      ),
                    ),
                    Center(
                      child: Text(
                        word['arabic'] ?? '',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Uthmanic',
                              fontSize: AppSize.s32,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: AppCount.c2,
            child: Center(
              child: Text(
                word['translation']?['en'] ?? '',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AyahNextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;
  const _AyahNextButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: AppPadding.p16),
        decoration: BoxDecoration(
          color: enabled ? ColorManager.primary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(AppPadding.p12),
        ),
        alignment: Alignment.center,
        child: Text(
          S.current.commonNext,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: enabled ? Colors.white : Colors.grey.shade500,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
