import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:holy_quran/generated/l10n.dart';
import 'package:holy_quran/screens/components/custom_app_bar.dart';
import 'package:provider/provider.dart';

import '../../values/assets_manager.dart';
import '../../values/color_manager.dart';
import '../../values/values_manager.dart';
import '../fill_gaps_screen/fill_gaps_screen.dart';
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

class _Body extends StatefulWidget {
  final Map<String, dynamic> verse;
  const _Body({required this.verse});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  String? _lastErrorKey;
  int _lastErrorTick = 0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnnectMeaningViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final currentError = viewModel.failedDragTargetEnglishWord;
          final tick = viewModel.errorTick;
          if (currentError != null &&
              (currentError != _lastErrorKey || tick != _lastErrorTick)) {
            _lastErrorKey = currentError;
            _lastErrorTick = tick;
            _triggerShake();
          } else if (currentError == null) {
            _lastErrorKey = null;
            _lastErrorTick = 0;
          }
        });

        return AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final dx = math.sin(_shakeController.value * math.pi * 6) * 8;
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: Column(
            children: [
              CustomAppBar(
                title: S.current.connectMeaningTitle,
                subtitle: S.current.connectMeaningSubtitle,
                showBackButton: false,
                showProgress: true,
                currentStep: viewModel.matchedWords.values
                    .where((v) => v != null)
                    .length,
                totalSteps: viewModel.matchedWords.length,
              ),
              SizedBox(height: AppPadding.p8),
              _ProgressDots(viewModel: viewModel),
              SizedBox(height: AppPadding.p40),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.p20),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _MatchedPairsList(viewModel: viewModel),
                      ),
                      Expanded(
                        flex: 2,
                        child: _AvailableWordsWrap(viewModel: viewModel),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppPadding.p20),
                child: Builder(
                  builder: (context) {
                    final canFinish = viewModel.isAllMatched;
                    final canAdvancePage =
                        viewModel.isCurrentPageComplete && viewModel.canGoNext;
                    final label = S.current.commonNext;
                    final enabled = canFinish ? true : canAdvancePage;
                    final VoidCallback? action = canFinish
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FillGapsScreen(verse: widget.verse),
                              ),
                            );
                          }
                        : (enabled ? viewModel.goToNextPage : null);

                    return _ConnectPrimaryButton(
                      label: label,
                      enabled: enabled,
                      onPressed: action,
                    );
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

class _ProgressDots extends StatelessWidget {
  final ConnnectMeaningViewModel viewModel;
  const _ProgressDots({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final currentPageMatches = viewModel.currentPageMatchedWords.entries
        .toList();
    final activeIndex = currentPageMatches.indexWhere(
      (entry) => entry.value == null,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(currentPageMatches.length, (index) {
        final isCompleted = currentPageMatches[index].value != null;
        final isCurrent =
            !isCompleted && (activeIndex == -1 ? false : index == activeIndex);
        final isFullyCompleted = viewModel.isCurrentPageComplete;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: AppPadding.p4),
          width: isFullyCompleted ? AppSize.s20 : AppSize.s24,
          height: isFullyCompleted ? AppSize.s20 : AppSize.s24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? Colors.green : Colors.transparent,
            border: Border.all(
              color: isCompleted
                  ? Colors.green
                  : (isCurrent ? Colors.grey.shade300 : Colors.grey.shade300),
              width: AppSize.s1,
            ),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? Icon(Icons.check, color: Colors.white, size: AppSize.s14)
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

class _MatchedPairsList extends StatelessWidget {
  final ConnnectMeaningViewModel viewModel;
  const _MatchedPairsList({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final matchedWords = viewModel.currentPageMatchedWords;
    return ListView.separated(
      itemCount: matchedWords.length,
      separatorBuilder: (_, __) => SizedBox(height: AppPadding.p4),
      itemBuilder: (context, index) {
        final englishWord = matchedWords.keys.elementAt(index);
        final matchedArabicWord = matchedWords[englishWord];
        final isError = viewModel.failedDragTargetEnglishWord == englishWord;
        return _MatchedRow(
          englishWord: englishWord,
          matchedArabicWord: matchedArabicWord,
          isError: isError,
          viewModel: viewModel,
        );
      },
    );
  }
}

class _MatchedRow extends StatelessWidget {
  final String englishWord;
  final String? matchedArabicWord;
  final bool isError;
  final ConnnectMeaningViewModel viewModel;

  const _MatchedRow({
    required this.englishWord,
    required this.matchedArabicWord,
    required this.isError,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              CustomPaint(
                size: Size(double.infinity, AppSize.s50),
                painter: _PuzzlePiecePainter(
                  color: matchedArabicWord != null
                      ? Colors.green
                      : (isError ? Colors.red : Colors.blueGrey.shade500),
                  isLeftPiece: true,
                ),
              ),
              Container(
                height: AppSize.s50,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
                child: Text(
                  englishWord,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Transform.translate(
            offset: Offset(-AppSize.s12, 0),
            child: DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(double.infinity, AppSize.s50),
                      painter: _PuzzlePiecePainter(
                        color: matchedArabicWord != null
                            ? Colors.green
                            : (isError ? Colors.red : Colors.grey.shade100),
                        isLeftPiece: false,
                        hasBorder: matchedArabicWord == null,
                        borderColor: candidateData.isNotEmpty
                            ? ColorManager.primary
                            : Colors.transparent,
                      ),
                    ),
                    if (matchedArabicWord != null)
                      Padding(
                        padding: EdgeInsets.only(left: AppPadding.p16),
                        child: Text(
                          matchedArabicWord!,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontFamily: 'Uthmanic',
                              ),
                        ),
                      )
                    else if (isError &&
                        viewModel.failedDragTargetArabicWord != null)
                      Padding(
                        padding: EdgeInsets.only(left: AppPadding.p16),
                        child: Text(
                          viewModel.failedDragTargetArabicWord!,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontFamily: 'Uthmanic',
                              ),
                        ),
                      ),
                    if (matchedArabicWord != null)
                      Positioned(
                        left: AppSize.s12 - (AppSize.s24 / 2),
                        child: SvgPicture.asset(
                          SvgAssets.rubElHizb,
                          width: AppSize.s24,
                          height: AppSize.s24,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      )
                    else if (isError &&
                        viewModel.failedDragTargetArabicWord != null)
                      Positioned(
                        left: AppSize.s12 - (AppSize.s24 / 2),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: AppSize.s20,
                        ),
                      ),
                  ],
                );
              },
              onWillAcceptWithDetails: (_) => matchedArabicWord == null,
              onAcceptWithDetails: (details) {
                viewModel.onWordDropped(details.data, englishWord);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AvailableWordsWrap extends StatelessWidget {
  final ConnnectMeaningViewModel viewModel;
  const _AvailableWordsWrap({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppPadding.p40,
      runSpacing: AppPadding.p20,
      alignment: WrapAlignment.center,
      children: viewModel.availableDraggableWords.map((word) {
        return Draggable<String>(
          data: word,
          feedback: _ArabicWordWidget(word: word, isDragging: true),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _ArabicWordWidget(word: word),
          ),
          child: _ArabicWordWidget(word: word),
        );
      }).toList(),
    );
  }
}

class _ConnectPrimaryButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onPressed;
  const _ConnectPrimaryButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

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
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: enabled ? Colors.white : Colors.grey.shade500,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
              padding: EdgeInsets.only(left: AppSize.s16),
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
      path.moveTo(cornerRadius, 0);
      path.lineTo(width - tabRadius, 0);

      path.lineTo(width - tabRadius, height / 2 - tabRadius);
      path.arcToPoint(
        Offset(width - tabRadius, height / 2 + tabRadius),
        radius: Radius.circular(tabRadius),
        clockwise: true,
      );
      path.lineTo(width - tabRadius, height);

      path.lineTo(cornerRadius, height);
      path.arcToPoint(
        Offset(0, height - cornerRadius),
        radius: Radius.circular(cornerRadius),
      );

      path.lineTo(0, cornerRadius);
      path.arcToPoint(
        Offset(cornerRadius, 0),
        radius: Radius.circular(cornerRadius),
      );
    } else {
      path.moveTo(tabRadius, 0);

      path.lineTo(width - cornerRadius, 0);
      path.arcToPoint(
        Offset(width, cornerRadius),
        radius: Radius.circular(cornerRadius),
      );

      path.lineTo(width, height - cornerRadius);
      path.arcToPoint(
        Offset(width - cornerRadius, height),
        radius: Radius.circular(cornerRadius),
      );

      path.lineTo(tabRadius, height);

      path.lineTo(tabRadius, height / 2 + tabRadius);
      path.arcToPoint(
        Offset(tabRadius, height / 2 - tabRadius),
        radius: Radius.circular(tabRadius),
        clockwise: true,
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
