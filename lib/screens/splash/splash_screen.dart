import 'package:flutter/material.dart';
import 'package:holy_quran/generated/l10n.dart';
import 'package:holy_quran/main.dart';
import 'package:holy_quran/routes/routes_manager.dart';
import 'package:holy_quran/screens/home/surah_selection_view_model.dart';
import 'package:holy_quran/utils/helper/shared_pref.dart';
import 'package:holy_quran/values/assets_manager.dart';
import 'package:holy_quran/values/font_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> slidungAnimation;
  bool _hasNavigated = false;
  @override
  void initState() {
    intializeAnimation();
    super.initState();
  }

  void intializeAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    slidungAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.bounceInOut,
    );
    animationController.forward();

    // Initialize the ViewModel during splash to preload data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = getIt<SurahSelectionScreenViewModel>();
      viewModel.initialize();
    });

    slidungAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateNext();
      }
    });
  }

  void _navigateNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    final storedUserId = SharedPrefrencesHelper.getString(
      key: SharedPrefrencesHelper.userIdKey,
    );
    final nextRoute = (storedUserId != null && storedUserId.isNotEmpty)
        ? RoutesManager.homeRoute
        : RoutesManager.loginRoute;
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: Image.asset(ImageAssets.logo)),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                S.current.splashTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  fontSize: FontSizeManager.s16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
