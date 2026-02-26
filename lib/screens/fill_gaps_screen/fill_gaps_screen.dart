import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../values/color_manager.dart';
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
                          widthFactor: viewModel.totalGapsCount == 0
                              ? 0.0
                              : viewModel.completedGapsCount /
                                    viewModel.totalGapsCount,
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
              'Fill the Gaps',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
            SizedBox(height: AppPadding.p4),
            Text(
              'Complete the missing parts',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: ColorManager.primary),
            ),
            SizedBox(height: AppPadding.p20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                int totalGaps = viewModel.totalGapsCount;
                int completedGaps = viewModel.completedGapsCount;
                double progressRatio = totalGaps == 0
                    ? 0.0
                    : completedGaps / totalGaps;
                int dotsToFill = (progressRatio * 4).floor();

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
                    color: isCompleted
                        ? ColorManager.green
                        : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? ColorManager.green
                          : Colors.grey.shade300,
                      width: 1.5,
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p20),
                child: Column(
                  children: [
                    SizedBox(height: AppSize.s40),
                    // Arabic Text
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      textDirection: TextDirection.rtl,
                      children: viewModel.arabicSegments.map((segment) {
                        if (segment.type == SegmentType.text) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              segment.text,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Uthmanic',
                              ),
                            ),
                          );
                        } else {
                          return _GapInputWidget(
                            gap: segment.gap!,
                            viewModel: viewModel,
                            isArabic: true,
                          );
                        }
                      }).toList(),
                    ),
                    SizedBox(height: AppSize.s40),
                    // English Text
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: viewModel.englishSegments.map((segment) {
                        if (segment.type == SegmentType.text) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              segment.text,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        } else {
                          return _GapInputWidget(
                            gap: segment.gap!,
                            viewModel: viewModel,
                            isArabic: false,
                          );
                        }
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppPadding.p20),
              child: GestureDetector(
                onTap: viewModel.isAllCompleted
                    ? () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ArrangePuzzleScreen(verse: widget.verse),
                          ),
                        );
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: AppPadding.p16),
                  decoration: BoxDecoration(
                    color: viewModel.isAllCompleted
                        ? ColorManager.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(AppPadding.p12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Next',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: viewModel.isAllCompleted
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
      fontSize: isArabic ? 24 : 18,
      fontWeight: isArabic ? FontWeight.bold : FontWeight.normal,
      fontFamily: isArabic ? 'Uthmanic' : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
