import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:holy_quran/main.dart';
import 'package:holy_quran/screens/home/components/stepper/quran_custom_stepper.dart';
import 'package:holy_quran/screens/home/surah_selection_view_model.dart';
import 'package:holy_quran/screens/surah_learning_path/surah_learning_path_screen.dart';
import 'package:holy_quran/values/assets_manager.dart';
import 'package:holy_quran/values/color_manager.dart';
import 'package:holy_quran/values/font_manager.dart';
import 'package:holy_quran/values/values_manager.dart';
import 'package:provider/provider.dart';

class SurahSelectionScreen extends StatefulWidget {
  const SurahSelectionScreen({super.key});

  @override
  State<SurahSelectionScreen> createState() => _SurahSelectionScreenState();
}

class _SurahSelectionScreenState extends State<SurahSelectionScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground, refresh data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final viewModel = Provider.of<SurahSelectionScreenViewModel>(
            context,
            listen: false,
          );
          viewModel.refresh();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => getIt<SurahSelectionScreenViewModel>(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: WidgetWidth.w16),
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      SizedBox(
                        width: WidgetWidth.w40,
                        height: WidgetHeight.h40,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: ColorManager.iconBackgroundColors,
                            borderRadius: BorderRadius.circular(
                              WidgetBorderRadius.b12,
                            ),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              SvgAssets.arrowLeft,
                              width: WidgetWidth.w10,
                              height: WidgetHeight.h10,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      Consumer<SurahSelectionScreenViewModel>(
                        builder: (context, viewModel, child) {
                          return Text(
                            viewModel.surahName.isNotEmpty
                                ? viewModel.surahName
                                : 'Surah',
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: FontSizeManager.s14,
                                ),
                          );
                        },
                      ),

                      const Spacer(),

                      SizedBox(width: WidgetWidth.w40),
                    ],
                  ),
                ),

                SizedBox(height: WidgetHeight.h20),

                const Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => __BodyState();
}

class __BodyState extends State<_Body> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SurahSelectionScreenViewModel>(
        context,
        listen: false,
      );
      viewModel.initialize();
    });
  }

  List<StepperStepData> _buildStepperSteps(
    SurahSelectionScreenViewModel viewModel,
  ) {
    return viewModel.verses.map((verse) {
      final verseNumber = verse['verseNumber'] as int;
      final isCompleted = verseNumber <= viewModel.completedVerses;
      final isCurrent = verseNumber == viewModel.currentVerse && !isCompleted;

      return StepperStepData(
        arabicText: verse['arabic'] as String,
        translationText: viewModel.verseTranslation(verse),
        isCompleted: isCompleted,
        isCurrent: isCurrent,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SurahSelectionScreenViewModel>(
      builder: (context, viewModel, child) {
        // Show loading indicator
        if (viewModel.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading Quran data...'),
              ],
            ),
          );
        }

        // Show error if any
        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 64),
                SizedBox(height: 16),
                Text('Error: ${viewModel.error}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: viewModel.refresh,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Show main content
        return SingleChildScrollView(
          child: Column(
            children: [
              _QuranInformation(),
              SizedBox(height: WidgetHeight.h16),
              _Line(),
              SizedBox(height: WidgetHeight.h16),
              QuranCustomStepper(
                steps: _buildStepperSteps(viewModel),
                onContinue: () {
                  // Navigate to current verse without updating progress
                  // Progress will be updated only in ArrangePuzzleScreen
                  if (viewModel.currentVerse <= viewModel.totalVerses) {
                    final currentVerseData = viewModel.verses
                        .where(
                          (v) => v['verseNumber'] == viewModel.currentVerse,
                        )
                        .first;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SurahLearningPathScreen(verse: currentVerseData),
                      ),
                    ).then((_) {
                      // Refresh when returning from learning path
                      if (mounted) {
                        viewModel.refresh();
                      }
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

String _languageLabel(String code) {
  switch (code.toLowerCase()) {
    case 'en':
      return 'English';
    case 'ar':
      return 'Arabic';
    case 'fr':
      return 'French';
    case 'ur':
      return 'Urdu';
    case 'tr':
      return 'Turkish';
    default:
      return code.toUpperCase();
  }
}

class _QuranInformation extends StatelessWidget {
  const _QuranInformation();

  @override
  Widget build(BuildContext context) {
    return Consumer<SurahSelectionScreenViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: WidgetHeight.h12,
          children: [
            _NameOfSurah(viewModel: viewModel),
            if (viewModel.isShowMore) ...[
              _SurahInformation(viewModel: viewModel),
              _LessInfo(),
            ] else ...[
              _MoreInfo(),
            ],
            _SurahProgressBar(
              progress: viewModel.progressPercentage,
              percentage: viewModel.progressText,
            ),
          ],
        );
      },
    );
  }
}

class _NameOfSurah extends StatelessWidget {
  const _NameOfSurah({required this.viewModel});

  final SurahSelectionScreenViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: viewModel.availableSurahs.isNotEmpty
                    ? viewModel.selectedSurahId
                    : null,
                icon: SvgPicture.asset(
                  SvgAssets.arrowDown,
                  width: WidgetWidth.w6,
                  height: WidgetHeight.h6,
                  fit: BoxFit.contain,
                ),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: FontSizeManager.s14,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.textColor,
                ),
                hint: Text(
                  'Select surah',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: FontSizeManager.s14,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.textColor,
                  ),
                ),
                items: viewModel.availableSurahs
                    .map(
                      (surah) => DropdownMenuItem<String>(
                        value: surah['id'] as String,
                        child: Text(
                          (surah['names']?['en'] ??
                                  surah['names']?['ar'] ??
                                  'Surah')
                              .toString(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    viewModel.selectSurah(value);
                  }
                },
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: viewModel.availableLanguages.isNotEmpty
                    ? viewModel.languageCode
                    : null,
                icon: SvgPicture.asset(
                  SvgAssets.arrowDown,
                  width: WidgetWidth.w6,
                  height: WidgetHeight.h6,
                  fit: BoxFit.contain,
                ),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: FontSizeManager.s14,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.textColor,
                ),
                hint: Text(
                  'Language',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: FontSizeManager.s14,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.textColor,
                  ),
                ),
                items: viewModel.availableLanguages
                    .map(
                      (code) => DropdownMenuItem<String>(
                        value: code,
                        child: Text(_languageLabel(code)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    viewModel.selectLanguage(value);
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: WidgetHeight.h8),
        Text(
          'Juz\' ${viewModel.juzNumber} - Surah Number ${viewModel.surahNumber} - Verses ${viewModel.totalVerses}',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: FontSizeManager.s12,
            fontWeight: FontWeight.w500,
            color: ColorManager.subTextColor,
          ),
        ),
      ],
    );
  }
}

class _SurahInformation extends StatelessWidget {
  const _SurahInformation({required this.viewModel});

  final SurahSelectionScreenViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: WidgetHeight.h12,
      children: [
        _SurahInfoItem(
          title: 'Place of Revelation',
          subTitle: viewModel.placeOfRevelation.isNotEmpty
              ? viewModel.placeOfRevelation
              : 'Mecca (Meccan)',
        ),
        _SurahInfoItem(
          title: 'Position',
          subTitle: viewModel.position.isNotEmpty
              ? viewModel.position
              : '20th from the end of the Qur\'an',
        ),
        _SurahInfoItem(
          title: 'Other Name',
          subTitle: viewModel.otherName.isNotEmpty
              ? viewModel.otherName
              : 'Al-Mu\'awwidhatayn',
        ),
        _SurahInfoItem(
          title: 'Brief context',
          subTitle: viewModel.briefContext.isNotEmpty
              ? viewModel.briefContext
              : 'Brief Context',
        ),
      ],
    );
  }
}

class _SurahInfoItem extends StatelessWidget {
  final String title;
  final String subTitle;
  const _SurahInfoItem({required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: FontSizeManager.s12,
            color: ColorManager.textColor2.withValues(alpha: 0.7),
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: WidgetHeight.h4),
        SizedBox(
          width: context.width * 0.85,
          child: Text(
            subTitle,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: FontSizeManager.s12,
              color: ColorManager.textColor2,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _LessInfo extends StatelessWidget {
  const _LessInfo();

  @override
  Widget build(BuildContext context) {
    return Consumer<SurahSelectionScreenViewModel>(
      builder: (context, viewModel, child) {
        return GestureDetector(
          onTap: () => viewModel.toggleShowMore(),
          child: Text(
            "Less Information",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: FontSizeManager.s12,
              color: ColorManager.subTextColor,
            ),
          ),
        );
      },
    );
  }
}

class _SurahProgressBar extends StatelessWidget {
  final double progress;
  final String percentage;

  const _SurahProgressBar({required this.progress, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double thumbWidth = WidgetWidth.w52;
        double leftPos = (constraints.maxWidth * progress) - (thumbWidth / 2);
        // Clamp to prevent the thumb from overflowing the edges
        leftPos = leftPos.clamp(0.0, constraints.maxWidth - thumbWidth);

        return SizedBox(
          height: WidgetHeight.h30,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background track
              Container(
                width: constraints.maxWidth,
                height: WidgetHeight.h10,
                decoration: BoxDecoration(
                  color: ColorManager.iconBackgroundColors,
                  borderRadius: BorderRadius.circular(WidgetBorderRadius.b10),
                ),
              ),
              // Filled track
              Container(
                width: constraints.maxWidth * progress,
                height: WidgetHeight.h10,
                decoration: BoxDecoration(
                  color: ColorManager.primary,
                  borderRadius: BorderRadius.circular(WidgetBorderRadius.b10),
                ),
              ),
              // Thumb with percentage
              Positioned(
                left: leftPos,
                child: Container(
                  width: thumbWidth,
                  height: WidgetHeight.h26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(WidgetBorderRadius.b24),
                  ),
                  child: Text(
                    percentage,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                      fontSize: FontSizeManager.s14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MoreInfo extends StatelessWidget {
  const _MoreInfo();

  @override
  Widget build(BuildContext context) {
    return Consumer<SurahSelectionScreenViewModel>(
      builder: (context, viewModel, child) {
        return GestureDetector(
          onTap: () => viewModel.toggleShowMore(),
          child: Text(
            "More Information",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: FontSizeManager.s12,
              color: ColorManager.secondary,
            ),
          ),
        );
      },
    );
  }
}

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 0.7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ColorManager.lineColor,
          borderRadius: BorderRadius.circular(WidgetBorderRadius.b1),
        ),
      ),
    );
  }
}
