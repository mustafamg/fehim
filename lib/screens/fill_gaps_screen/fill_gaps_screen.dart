import 'package:flutter/material.dart';
import 'package:holy_quran/generated/l10n.dart';
import 'package:holy_quran/screens/components/custom_app_bar.dart';
import 'package:holy_quran/values/spacing_manager.dart';
import 'package:provider/provider.dart';

import '../../values/color_manager.dart';
import '../../values/font_manager.dart';
import '../../values/values_manager.dart';
import '../arrange_puzzle/arrange_puzzle_screen.dart';
import 'fill_gaps_view_model.dart';

class FillGapsScreen extends StatelessWidget {
  final Map<String, dynamic> verse;
  const FillGapsScreen({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = FillGapsViewModel();
        viewModel.init(verse);
        return viewModel;
      },
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
  State<_Body> createState() => __BodyState();
}

class __BodyState extends State<_Body> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FillGapsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.arabicSegments.isEmpty &&
            viewModel.englishSegments.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            CustomAppBar(
              title: S.current.fillGapsTitle,
              subtitle: S.current.fillGapsSubtitle,
              showBackButton: false,
              showProgress: true,
              currentStep: viewModel.completedGapsCount,
              totalSteps: viewModel.totalGapsCount,
            ),
            _FillGapsProgressDots(viewModel: viewModel),
            SizedBox(height: AppPadding.p40),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p20),
                child: Column(
                  children: [
                    SizedBox(height: AppSize.s40),
                    _SegmentsWrap(
                      segments: viewModel.arabicSegments,
                      isArabic: true,
                      viewModel: viewModel,
                    ),
                    SizedBox(height: AppSize.s40),
                    _SegmentsWrap(
                      segments: viewModel.englishSegments,
                      isArabic: false,
                      viewModel: viewModel,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppPadding.p20),
              child: _NextButton(
                enabled: viewModel.isAllCompleted,
                onPressed: viewModel.isAllCompleted
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ArrangePuzzleScreen(verse: widget.verse),
                          ),
                        );
                      }
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FillGapsProgressDots extends StatelessWidget {
  final FillGapsViewModel viewModel;
  const _FillGapsProgressDots({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final totalGaps = viewModel.totalGapsCount;
    final completedGaps = viewModel.completedGapsCount;
    final progressRatio = totalGaps == 0 ? 0.0 : completedGaps / totalGaps;
    final dotsToFill = (progressRatio * 4).floor();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isCompleted = index < dotsToFill;
        bool isCurrent = index == dotsToFill;
        if (viewModel.isAllCompleted) {
          isCompleted = true;
          isCurrent = false;
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: AppPadding.p4),
          width: AppSize.s24,
          height: AppSize.s24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? ColorManager.green : Colors.transparent,
            border: Border.all(
              color: isCompleted ? ColorManager.green : Colors.grey.shade300,
              width: AppSize.s1,
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

class _SegmentsWrap extends StatelessWidget {
  final List<TextSegment> segments;
  final bool isArabic;
  final FillGapsViewModel viewModel;

  const _SegmentsWrap({
    required this.segments,
    required this.isArabic,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: segments.map((segment) {
        if (segment.type == SegmentType.text) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.p4),
            child: Text(
              segment.text,
              style: TextStyle(
                fontSize: isArabic ? FontSizeManager.s24 : FontSizeManager.s18,
                fontWeight: isArabic
                    ? FontWeight.bold
                    : FontWeightManager.reqular,
                color: isArabic ? Colors.black : Colors.black87,
                fontFamily: isArabic ? 'Uthmanic' : null,
              ),
            ),
          );
        }
        return _GapInputWidget(
          gap: segment.gap!,
          viewModel: viewModel,
          isArabic: isArabic,
        );
      }).toList(),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;
  const _NextButton({required this.enabled, this.onPressed});

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

class _GapInputWidget extends StatelessWidget {
  final GapWordModel gap;
  final FillGapsViewModel viewModel;
  final bool isArabic;

  const _GapInputWidget({
    required this.gap,
    required this.viewModel,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isArabic ? FontSizeManager.s24 : FontSizeManager.s18,
      fontWeight: isArabic ? FontWeight.bold : FontWeight.normal,
      fontFamily: isArabic ? 'Uthmanic' : null,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: HorizontalSpacing.xSmall4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hidden text to determine the exact required width for the word
          Opacity(
            opacity: 0.0,
            child: Text(
              '${gap.fullWord} ', // Add a slight padding space to ensure text field doesn't clip
              style: style,
            ),
          ),
          Positioned.fill(
            child: TextField(
              controller: gap.controller,
              enabled: !gap.isCompleted,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              textAlign: TextAlign.center,
              autocorrect: false,
              enableSuggestions: false,
              style: style,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
              onChanged: (value) => viewModel.onGapChanged(gap, value),
            ),
          ),
        ],
      ),
    );
  }
}
