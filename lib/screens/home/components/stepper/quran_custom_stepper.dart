import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:holy_quran/values/assets_manager.dart';
import 'package:holy_quran/values/color_manager.dart';
import 'package:holy_quran/values/font_manager.dart';
import 'package:holy_quran/values/values_manager.dart';

class StepperStepData {
  final String arabicText;
  final String translationText;
  final bool isCompleted;
  final bool isCurrent;

  StepperStepData({
    required this.arabicText,
    required this.translationText,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

class QuranCustomStepper extends StatelessWidget {
  final List<StepperStepData> steps;
  final VoidCallback? onContinue;

  const QuranCustomStepper({super.key, required this.steps, this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        return _buildStep(
          context,
          steps[index],
          index,
          index == steps.length - 1,
        );
      }),
    );
  }

  Widget _buildStep(
    BuildContext context,
    StepperStepData step,
    int index,
    bool isLast,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side: Indicator and Line
          SizedBox(
            width: WidgetWidth.w40,
            child: Column(
              children: [
                _buildIndicator(step),
                if (!isLast)
                  Expanded(child: _buildDottedLine(step.isCompleted)),
              ],
            ),
          ),

          SizedBox(width: WidgetWidth.w12),

          // Right side: Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Take minimum height
              children: [
                // Arabic text
                Text(
                  step.arabicText,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: FontSizeManager.s18,
                    fontWeight: FontWeight.w600,
                    color: step.isCompleted || step.isCurrent
                        ? ColorManager.textColor2
                        : ColorManager.subTextColor,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: WidgetHeight.h4),
                // Translation text
                Text(
                  step.translationText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: FontSizeManager.s14,
                    fontWeight: FontWeight.w400,
                    color: step.isCompleted
                        ? ColorManager.subTextColor
                        : (step.isCurrent
                              ? ColorManager.textColor2
                              : ColorManager.subTextColor.withValues(
                                  alpha: 0.5,
                                )),
                  ),
                ),
                // Continue Button
                if (step.isCurrent && onContinue != null) ...[
                  SizedBox(height: WidgetHeight.h16),
                  _buildContinueButton(context),
                  SizedBox(
                    height: WidgetHeight.h24,
                  ), // Extra padding after button
                ] else ...[
                  SizedBox(
                    height: WidgetHeight.h24,
                  ), // Standard padding between steps
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(StepperStepData step) {
    if (step.isCompleted) {
      return Container(
        width: WidgetWidth.w24,
        height: WidgetHeight.h24,
        decoration: BoxDecoration(
          color: ColorManager.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, color: Colors.white, size: WidgetWidth.w16),
      );
    } else if (step.isCurrent) {
      return Container(
        width: WidgetWidth.w24,
        height: WidgetHeight.h24,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: ColorManager.lineColor, width: 1.5),
        ),
        child: Center(
          child: Container(
            width: WidgetWidth.w12,
            height: WidgetHeight.h12,
            decoration: BoxDecoration(
              color: ColorManager.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      // Disabled/Future state
      return Container(
        width: WidgetWidth.w24,
        height: WidgetHeight.h24,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: ColorManager.lineColor, width: 1.5),
        ),
      );
    }
  }

  Widget _buildDottedLine(bool isCompleted) {
    return SizedBox(
      width: WidgetWidth.w3,
      height:
          WidgetHeight.h50, // Slightly taller line to match image proportions
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          // 5 dots exactly as shown in the reference image
          return Container(
            width: WidgetWidth.w3,
            height: WidgetHeight.h6, // Taller pill shape
            decoration: BoxDecoration(
              color: isCompleted
                  ? ColorManager.primary
                  : ColorManager.lineColor,
              borderRadius: BorderRadius.circular(100), // Pill shape
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return GestureDetector(
      onTap: onContinue,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: WidgetWidth.w24,
          vertical: WidgetHeight.h10,
        ),
        decoration: BoxDecoration(
          color: ColorManager.secondary, // The golden/olive color
          borderRadius: BorderRadius.circular(WidgetBorderRadius.b24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              SvgAssets.quran,
              width: WidgetWidth.w18,
              height: WidgetHeight.h18,
            ),
            SizedBox(width: WidgetWidth.w4),
            Text(
              "Continue",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontSize: FontSizeManager.s14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
