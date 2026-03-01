import 'package:flutter/material.dart';

import '../../values/color_manager.dart';
import '../../values/values_manager.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? trailing;
  final bool showProgress;
  final int currentStep;
  final int totalSteps;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.trailing,
    this.showProgress = false,
    this.currentStep = 0,
    this.totalSteps = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.p20,
        vertical: AppPadding.p16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (showBackButton)
                GestureDetector(
                  onTap: onBackPressed ?? () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    size: AppPadding.p24,
                    color: Colors.black87,
                  ),
                )
              else
                GestureDetector(
                  onTap: onBackPressed ?? () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: AppPadding.p24,
                    color: Colors.black87,
                  ),
                ),
              SizedBox(width: AppPadding.p16),
              if (showProgress)
                Expanded(
                  child: Container(
                    height: AppSize.s8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (currentStep + 1) / totalSteps,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorManager.primary,
                          borderRadius: BorderRadius.circular(AppSize.s4),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ?trailing,
            ],
          ),
          SizedBox(height: AppPadding.p24),

          if (showProgress) ...[
            SizedBox(height: AppPadding.p16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
            SizedBox(height: AppPadding.p4),
            Text(
              subtitle ?? title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ColorManager.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppPadding.p24),
          ],
        ],
      ),
    );
  }
}
