import 'package:flutter/material.dart';
import 'package:holy_quran/screens/components/custom_app_bar.dart';
import 'package:provider/provider.dart';

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
      create: (_) => AyahLearningPathViewModel(verse),
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
          return const Center(
            child: Text('No word data available for this verse.'),
          );
        }

        return Column(
          children: [
            CustomAppBar(
              title: 'Discover the Words',
              subtitle: "Let's explore each word",
              showBackButton: false,
              showProgress: true,
              currentStep: viewModel.currentIndex,
              totalSteps: viewModel.words.length,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(viewModel.words.length, (index) {
                if (index < viewModel.currentIndex ||
                    viewModel.isWordFinished(index)) {
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
                          width: 2,
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
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }
              }),
            ),
            SizedBox(height: AppPadding.p40),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: viewModel.isWordFinished(viewModel.currentIndex)
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  viewModel.setCurrentIndex(index);
                },
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
                    animation: _pageController,
                    builder: (context, child) {
                      double value = (viewModel.currentIndex - index)
                          .toDouble();
                      if (_pageController.hasClients &&
                          _pageController.position.haveDimensions) {
                        final page = _pageController.page;
                        if (page != null) value = page - index;
                      }

                      final rotationZ = value * AppRatio.r0_15;
                      final translateY = value.abs() * AppSize.s30;
                      final scale = (1 - (value.abs() * AppRatio.r0_15)).clamp(
                        AppRatio.r0_8,
                        1.0,
                      );
                      final opacity = (1 - (value.abs() * AppRatio.r0_5)).clamp(
                        0.0,
                        1.0,
                      );

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
                    child: Container(
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
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(topColor),
                                                ),
                                              )
                                            : Icon(
                                                isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                color: topColor,
                                                size: AppPadding.p16,
                                              ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        word['arabic'] ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
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
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(color: Colors.black87),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppPadding.p20),
              child: GestureDetector(
                onTap: viewModel.isWordFinished(viewModel.currentIndex)
                    ? () {
                        if (viewModel.currentIndex <
                            viewModel.words.length - AppCount.c1) {
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
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: AppPadding.p16),
                  decoration: BoxDecoration(
                    color: viewModel.isWordFinished(viewModel.currentIndex)
                        ? ColorManager.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(AppPadding.p12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Next',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: viewModel.isWordFinished(viewModel.currentIndex)
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
}
