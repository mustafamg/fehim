import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holy_quran/generated/l10n.dart';
import 'package:holy_quran/main.dart';
import 'package:holy_quran/routes/routes_manager.dart';
import 'package:holy_quran/screens/components/reset_progress_dialog.dart';
import 'package:holy_quran/screens/home/components/stepper/quran_custom_stepper.dart';
import 'package:holy_quran/screens/home/surah_selection_view_model.dart';
import 'package:holy_quran/screens/surah_learning_path/surah_learning_path_screen.dart';
import 'package:holy_quran/utils/helper/shared_pref.dart';
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
    with WidgetsBindingObserver, RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and the current route shows up.
    // e.g., Returning from learning path screens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final viewModel = Provider.of<SurahSelectionScreenViewModel>(
            context,
            listen: false,
          );
          viewModel.refresh();
        } catch (_) {}
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            final viewModel = Provider.of<SurahSelectionScreenViewModel>(
              context,
              listen: false,
            );
            viewModel.refresh();
          } catch (_) {
            // Provider might not be available in this context yet
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = getIt<SurahSelectionScreenViewModel>();
        // Start loading immediately when creating the ViewModel
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!viewModel.isInitialized) {
            viewModel.initialize();
          }
        });
        return viewModel;
      },
      child: Builder(
        builder: (context) => Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final shouldReset = await showDialog<bool>(
                context: context,
                builder: (_) => const ResetProgressDialog(),
              );

              if (shouldReset == true && context.mounted) {
                final viewModel = context.read<SurahSelectionScreenViewModel>();
                await viewModel.resetProgress();
              }
            },
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: WidgetWidth.w16),
              child: Column(
                children: [
                  SizedBox(
                    height: 56.h,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RoutesManager.profileRoute,
                            );
                          },
                          child: SizedBox(
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
                                  SvgAssets.userCircle,
                                  width: WidgetWidth.w30,
                                  height: WidgetHeight.h30,
                                ),
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
                                  : S.current.surahSelectionDefaultName,
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
        verseNumber: verseNumber,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SurahSelectionScreenViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(S.current.surahSelectionLoadingMessage),
              ],
            ),
          );
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(S.current.commonErrorWithMessage(viewModel.error!)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: viewModel.refresh,
                  child: Text(S.current.surahSelectionRetryButton),
                ),
              ],
            ),
          );
        }

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
                  if (viewModel.currentVerse <= viewModel.totalVerses) {
                    final currentVerseData = Map<String, dynamic>.from(
                      viewModel.verses
                          .where(
                            (v) => v['verseNumber'] == viewModel.currentVerse,
                          )
                          .first,
                    );
                    currentVerseData['surahId'] = viewModel.selectedSurahId;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurahLearningPathScreen(
                          verse: currentVerseData,
                          languageCode: viewModel.languageCode,
                        ),
                      ),
                    ).then((_) {
                      if (mounted) {
                        viewModel.refresh();
                      }
                    });
                  }
                },
                onStepTap: (verseNumber) {
                  final verseData = Map<String, dynamic>.from(
                    viewModel.verses
                        .where((v) => v['verseNumber'] == verseNumber)
                        .first,
                  );
                  verseData['surahId'] = viewModel.selectedSurahId;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahLearningPathScreen(
                        verse: verseData,
                        languageCode: viewModel.languageCode,
                      ),
                    ),
                  ).then((_) {
                    if (mounted) {
                      viewModel.refresh();
                    }
                  });
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
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 350),
              crossFadeState: viewModel.isShowMore
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              sizeCurve: Curves.easeInOut,
              firstChild: _MoreInfo(key: const ValueKey('more_info_button')),
              secondChild: Column(
                key: const ValueKey('more_info_content'),
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: WidgetHeight.h12,
                children: const [_SurahInformationWrapper(), _LessInfo()],
              ),
            ),
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

class _SurahInformationWrapper extends StatelessWidget {
  const _SurahInformationWrapper();

  @override
  Widget build(BuildContext context) {
    return Consumer<SurahSelectionScreenViewModel>(
      builder: (context, viewModel, _) =>
          _SurahInformation(viewModel: viewModel),
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
                  S.current.surahSelectionSelectSurahHint,
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
                          viewModel.localizedSurahName(
                            Map<String, dynamic>.from(surah),
                          ),
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
                  S.current.surahSelectionLanguageHint,
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
                    final isSupportedLocale = S.delegate.supportedLocales.any(
                      (locale) => locale.languageCode == value,
                    );
                    if (isSupportedLocale) {
                      Get.updateLocale(Locale(value));
                      SharedPrefrencesHelper.saveString(
                        key: SharedPrefrencesHelper.languageCodeKey,
                        value: value,
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: WidgetHeight.h8),
        Text(
          S.current.surahSelectionSummary(
            viewModel.juzNumber,
            viewModel.surahNumber,
            viewModel.totalVerses,
          ),
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
          title: S.current.surahInfoPlaceTitle,
          subTitle: viewModel.placeOfRevelation.isNotEmpty
              ? viewModel.placeOfRevelation
              : '',
        ),
        _SurahInfoItem(
          title: S.current.surahInfoPositionTitle,
          subTitle: viewModel.position.isNotEmpty ? viewModel.position : "",
        ),
        _SurahInfoItem(
          title: S.current.surahInfoOtherNameTitle,
          subTitle: viewModel.otherName.isNotEmpty ? viewModel.otherName : "",
        ),
        _SurahInfoItem(
          title: S.current.surahInfoBriefContextTitle,
          subTitle: viewModel.briefContext.isNotEmpty
              ? viewModel.briefContext
              : '',
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
            S.current.surahSelectionLessInfo,
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

        leftPos = leftPos.clamp(0.0, constraints.maxWidth - thumbWidth);
        return SizedBox(
          height: WidgetHeight.h30,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: constraints.maxWidth,
                height: WidgetHeight.h10,
                decoration: BoxDecoration(
                  color: ColorManager.iconBackgroundColors,
                  borderRadius: BorderRadius.circular(WidgetBorderRadius.b10),
                ),
              ),

              Container(
                width: constraints.maxWidth * progress,
                height: WidgetHeight.h10,
                decoration: BoxDecoration(
                  color: ColorManager.primary,
                  borderRadius: BorderRadius.circular(WidgetBorderRadius.b10),
                ),
              ),

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
  const _MoreInfo({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<SurahSelectionScreenViewModel>(
      builder: (context, viewModel, child) {
        return GestureDetector(
          onTap: () => viewModel.toggleShowMore(),
          child: Text(
            S.current.surahSelectionMoreInfo,
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
