import 'package:flutter/material.dart';
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

    slidungAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Navigator.pushReplacementNamed(context, RoutesManager.loginRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Centered Image
          Center(child: Image.asset(ImageAssets.logo)),

          // Bottom Center Text
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                "Learn Quran the Easy & Fun Way",
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
