import 'package:flutter/material.dart';
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
    _pageController = PageController(viewportFraction: 0.65);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set initial page to trigger the animation
      _pageController.animateToPage(
        0,
        duration: Duration(milliseconds: 1),
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
          return Center(child: Text('No word data available for this verse.'));
        }

        return Column(
          children: [
            // Top Bar (Close Button + Progress Bar)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.p20,
                vertical: AppPadding.p16,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      size: AppPadding.p24,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: AppPadding.p16),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor:
                            (viewModel.currentIndex + 1) /
                            viewModel.words.length,
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorManager.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppPadding.p32),

            // Titles
            Center(
              child: Column(
                children: [
                  Text(
                    'Discover the Words',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: AppPadding.p4),
                  Text(
                    "Let's explore each word",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ColorManager.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppPadding.p24),

            // Dot Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(viewModel.words.length, (index) {
                if (index < viewModel.currentIndex ||
                    viewModel.isWordFinished(index)) {
                  // Completed word
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppPadding.p4),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: AppPadding.p24,
                    ),
                  );
                } else if (index == viewModel.currentIndex) {
                  // Current word
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
                  // Upcoming word
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

            // Word Cards PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: viewModel.isWordFinished(viewModel.currentIndex)
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(), // Disable swipe if not finished
                onPageChanged: (index) {
                  viewModel.setCurrentIndex(index);
                },
                itemCount: viewModel.words.length,
                itemBuilder: (context, index) {
                  final word = viewModel.words[index];
                  final isCurrent = index == viewModel.currentIndex;
                  final isPlayed = viewModel.isWordFinished(index);
                  final isPlaying = isCurrent && viewModel.isPlaying;

                  // Color logic based on your request: Green if played/playing, Grey if not played
                  final topColor = (isPlayed || (isCurrent && isPlaying))
                      ? Colors.green
                      : Colors.blueGrey.shade600;

                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 0.0;

                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                      }

                      // We want cards on the left (index < current page, so value > 0) to rotate slightly clockwise (positive Z).
                      // Cards on the right (index > current page, so value < 0) to rotate slightly counter-clockwise (negative Z).
                      double rotationZ =
                          value * 0.15; // Invert to get the inward tilt

                      // Push side cards down
                      double translateY = value.abs() * 30.0;

                      // Scale them down a bit
                      double scale = (1 - (value.abs() * 0.15)).clamp(0.8, 1.0);

                      return Center(
                        child: Transform(
                          transform: Matrix4.identity()
                            ..translate(0.0, translateY, 0.0)
                            ..rotateZ(rotationZ)
                            ..scale(scale),
                          alignment: Alignment.center,
                          child: Opacity(
                            opacity: (1 - (value.abs() * 0.5)).clamp(0.5, 1.0),
                            child: SizedBox(
                              height: 350,
                              width: 280, // slightly narrower
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
                            color: Colors.black.withAlpha(20),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Half (Arabic)
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: topColor,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(AppPadding.p16),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Play button
                                  Positioned(
                                    top: AppPadding.p16,
                                    left: AppPadding.p16,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (isPlaying) {
                                          viewModel.pauseCurrentWordAudio();
                                        } else if (isCurrent) {
                                          viewModel.playCurrentWordAudio();
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(AppPadding.p4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          (isPlaying)
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: topColor,
                                          size: AppPadding.p16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Arabic text
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
                                            fontSize: 32.0,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Bottom Half (Translation)
                          Expanded(
                            flex: 2,
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

            // Next Button
            Padding(
              padding: EdgeInsets.all(AppPadding.p20),
              child: GestureDetector(
                onTap: viewModel.isWordFinished(viewModel.currentIndex)
                    ? () {
                        if (viewModel.currentIndex <
                            viewModel.words.length - 1) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // Reached the end of words
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ConnectMeaningScreen(verse: widget.verse),
                            ),
                          );
                        }
                      }
                    : null, // Disable button if not finished
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
