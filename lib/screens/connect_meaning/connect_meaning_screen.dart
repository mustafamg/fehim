import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../values/assets_manager.dart';
import '../../values/color_manager.dart';
import '../../values/values_manager.dart';
import '../arrange_puzzle/arrange_puzzle_screen.dart';
import 'connnect_meaning_view_model.dart';

class ConnectMeaningScreen extends StatelessWidget {
  const ConnectMeaningScreen({super.key, required this.verse});

  final Map<String, dynamic> verse;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = ConnnectMeaningViewModel();
        if (verse.containsKey('words') && verse['words'] is List) {
          viewModel.init(List<Map<String, dynamic>>.from(verse['words']));
        }
        return viewModel;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: _Body(verse: verse)),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final Map<String, dynamic> verse;

  const _Body({required this.verse});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnnectMeaningViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            // Top App Bar Area
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
                          widthFactor: viewModel.matchedWords.isEmpty
                              ? 0.0
                              : viewModel.matchedWords.values
                                        .where((v) => v != null)
                                        .length /
                                    viewModel.matchedWords.length,
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

            // Title
            Text(
              'Connect Meanings',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
            SizedBox(height: AppPadding.p4),
            Text(
              'Link words to their meanings',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: ColorManager.primary),
            ),

            // Progress Indicators (Dots)
            SizedBox(height: AppPadding.p20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                bool isCompleted = viewModel.isAllMatched;
                bool isCurrent = index == 0;

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: AppPadding.p4),
                  width: isCompleted ? AppSize.s20 : AppSize.s24,
                  height: isCompleted ? AppSize.s20 : AppSize.s24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? Colors.green : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? Colors.green
                          : (isCurrent
                                ? Colors.grey.shade300
                                : Colors.grey.shade300),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: AppSize.s14,
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

            // Draggable and DragTarget Area
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p20),
                child: Column(
                  children: [
                    // Target List (English Words)
                    Expanded(
                      flex: 3,
                      child: ListView.builder(
                        itemCount: viewModel.matchedWords.length,
                        itemBuilder: (context, index) {
                          String englishWord = viewModel.matchedWords.keys
                              .elementAt(index);
                          String? matchedArabicWord =
                              viewModel.matchedWords[englishWord];
                          bool isError =
                              viewModel.failedDragTargetEnglishWord ==
                              englishWord;

                          return Padding(
                            padding: EdgeInsets.only(bottom: AppPadding.p16),
                            child: Row(
                              children: [
                                // English Word Container (Left side puzzle piece)
                                Expanded(
                                  flex: 1,
                                  child: Stack(
                                    children: [
                                      CustomPaint(
                                        size: Size(
                                          double.infinity,
                                          AppSize.s50,
                                        ),
                                        painter: _PuzzlePiecePainter(
                                          color: matchedArabicWord != null
                                              ? Colors.green
                                              : (isError
                                                    ? Colors.red
                                                    : Colors.blueGrey.shade500),
                                          isLeftPiece: true,
                                        ),
                                      ),
                                      Container(
                                        height: AppSize.s50,
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.only(
                                          left: AppPadding.p20,
                                          right: AppPadding.p16,
                                        ),
                                        child: Text(
                                          englishWord,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Drag Target (Right side puzzle piece space)
                                Expanded(
                                  flex: 1,
                                  child: Transform.translate(
                                    offset: Offset(
                                      -AppSize.s12,
                                      0,
                                    ), // Shift left to make pieces snap together
                                    child: DragTarget<String>(
                                      builder:
                                          (
                                            context,
                                            candidateData,
                                            rejectedData,
                                          ) {
                                            return Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                CustomPaint(
                                                  size: Size(
                                                    double.infinity,
                                                    AppSize.s50,
                                                  ),
                                                  painter: _PuzzlePiecePainter(
                                                    color:
                                                        matchedArabicWord !=
                                                            null
                                                        ? Colors.green
                                                        : (isError
                                                              ? Colors.red
                                                              : Colors
                                                                    .grey
                                                                    .shade100),
                                                    isLeftPiece: false,
                                                    hasBorder:
                                                        matchedArabicWord ==
                                                        null,
                                                    borderColor:
                                                        candidateData.isNotEmpty
                                                        ? ColorManager.primary
                                                        : Colors.transparent,
                                                  ),
                                                ),
                                                if (matchedArabicWord != null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      left: AppSize.s16,
                                                    ), // Offset for the tab
                                                    child: Text(
                                                      matchedArabicWord,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.copyWith(
                                                            color: Colors.white,
                                                            fontFamily:
                                                                'Uthmanic',
                                                          ),
                                                    ),
                                                  ),
                                                if (matchedArabicWord != null)
                                                  Positioned(
                                                    left:
                                                        AppSize.s12 -
                                                        (AppSize.s24 / 2),
                                                    child: SvgPicture.asset(
                                                      SvgAssets.rubElHizb,
                                                      width: AppSize.s24,
                                                      height: AppSize.s24,
                                                      colorFilter:
                                                          const ColorFilter.mode(
                                                            Colors.white,
                                                            BlendMode.srcIn,
                                                          ),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                      onWillAcceptWithDetails: (data) =>
                                          matchedArabicWord == null,
                                      onAcceptWithDetails: (details) {
                                        viewModel.onWordDropped(
                                          details.data,
                                          englishWord,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Draggable List (Arabic Words)
                    Expanded(
                      flex: 2,
                      child: Wrap(
                        spacing: AppPadding.p16,
                        runSpacing: AppPadding.p16,
                        alignment: WrapAlignment.center,
                        children: viewModel.availableDraggableWords.map((
                          arabicWord,
                        ) {
                          return Draggable<String>(
                            data: arabicWord,
                            feedback: _ArabicWordWidget(
                              word: arabicWord,
                              isDragging: true,
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _ArabicWordWidget(word: arabicWord),
                            ),
                            child: _ArabicWordWidget(word: arabicWord),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Next Button
            Padding(
              padding: EdgeInsets.all(AppPadding.p20),
              child: GestureDetector(
                onTap: viewModel.isAllMatched
                    ? () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ArrangePuzzleScreen(verse: verse),
                          ),
                        );
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: AppPadding.p16),
                  decoration: BoxDecoration(
                    color: viewModel.isAllMatched
                        ? ColorManager.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(AppPadding.p12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Next',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: viewModel.isAllMatched
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

class _ArabicWordWidget extends StatelessWidget {
  final String word;
  final bool isDragging;

  const _ArabicWordWidget({required this.word, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: AppSize.s50,
        width: AppSize.s120,
        decoration: isDragging
            ? BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: AppSize.s8,
                    offset: Offset(0, 4),
                  ),
                ],
              )
            : null,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(AppSize.s120, AppSize.s50),
              painter: _PuzzlePiecePainter(
                color: Colors.blueGrey.shade600,
                isLeftPiece: false,
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                left: AppSize.s16,
              ), // Offset for the cutout
              child: Text(
                word,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontFamily: 'Uthmanic',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PuzzlePiecePainter extends CustomPainter {
  final Color color;
  final bool isLeftPiece;
  final bool hasBorder;
  final Color borderColor;

  _PuzzlePiecePainter({
    required this.color,
    required this.isLeftPiece,
    this.hasBorder = false,
    this.borderColor = Colors.transparent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final tabRadius = height * 0.25;
    final cornerRadius = AppSize.s16;

    if (isLeftPiece) {
      // Left piece (English word) - has a tab sticking out on the right
      path.moveTo(cornerRadius, 0);
      path.lineTo(width - tabRadius, 0);

      // Right edge with tab
      path.lineTo(width - tabRadius, height / 2 - tabRadius);
      path.arcToPoint(
        Offset(width - tabRadius, height / 2 + tabRadius),
        radius: Radius.circular(tabRadius),
        clockwise: true, // Protrudes outward
      );
      path.lineTo(width - tabRadius, height);

      // Bottom edge
      path.lineTo(cornerRadius, height);
      path.arcToPoint(
        Offset(0, height - cornerRadius),
        radius: Radius.circular(cornerRadius),
      );

      // Left edge
      path.lineTo(0, cornerRadius);
      path.arcToPoint(
        Offset(cornerRadius, 0),
        radius: Radius.circular(cornerRadius),
      );
    } else {
      // Right piece (Arabic word / Target) - has a cutout on the left
      path.moveTo(tabRadius, 0);

      // Top edge
      path.lineTo(width - cornerRadius, 0);
      path.arcToPoint(
        Offset(width, cornerRadius),
        radius: Radius.circular(cornerRadius),
      );

      // Right edge
      path.lineTo(width, height - cornerRadius);
      path.arcToPoint(
        Offset(width - cornerRadius, height),
        radius: Radius.circular(cornerRadius),
      );

      // Bottom edge
      path.lineTo(tabRadius, height);

      // Left edge with cutout
      path.lineTo(tabRadius, height / 2 + tabRadius);
      path.arcToPoint(
        Offset(tabRadius, height / 2 - tabRadius),
        radius: Radius.circular(tabRadius),
        clockwise: true, // Cutout goes inward
      );
      path.lineTo(tabRadius, 0);
    }

    canvas.drawPath(path, paint);
    if (hasBorder) {
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PuzzlePiecePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isLeftPiece != isLeftPiece ||
        oldDelegate.hasBorder != hasBorder ||
        oldDelegate.borderColor != borderColor;
  }
}
