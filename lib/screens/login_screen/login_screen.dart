import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:holy_quran/generated/l10n.dart';
import 'package:holy_quran/main.dart';
import 'package:holy_quran/routes/routes_manager.dart';
import 'package:holy_quran/screens/login_screen/login_screen_view_model.dart';
import 'package:holy_quran/values/assets_manager.dart';
import 'package:holy_quran/values/font_manager.dart';
import 'package:holy_quran/values/values_manager.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<LoginScreenViewModel>(),
      child: const Scaffold(body: SafeArea(child: _Body())),
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
      final viewModel = context.read<LoginScreenViewModel>();
      viewModel.initialize();
    });
  }

  Future<void> _handleGoogleLogin(LoginScreenViewModel viewModel) async {
    final success = await viewModel.loginWithGoogle();
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, RoutesManager.homeRoute);
    } else if (viewModel.errorMessage?.isNotEmpty == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      print(viewModel.errorMessage);
    }
  }

  Future<void> _handleAppleLogin(LoginScreenViewModel viewModel) async {
    final success = await viewModel.loginWithApple();
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, RoutesManager.homeRoute);
    } else if (viewModel.errorMessage?.isNotEmpty == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginScreenViewModel>(
      builder: (context, viewModel, child) {
        return SizedBox(
          height: context.height,
          width: context.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: WidgetHeight.h80),
              Image.asset(
                ImageAssets.logo,
                width: WidgetWidth.w90,
                height: WidgetHeight.h85,
              ),
              SizedBox(height: WidgetHeight.h24),
              Text(
                S.current.loginGreeting,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: FontSizeManager.s24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: WidgetHeight.h80),
              SizedBox(
                width: context.width * 0.8,
                height: WidgetHeight.h50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed:
                      viewModel.isLoading || !viewModel.isFirebaseSupported
                      ? null
                      : () => _handleGoogleLogin(viewModel),
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              IconAssets.googleIcon,
                              width: WidgetWidth.w20,
                              height: WidgetHeight.h20,
                            ),
                            SizedBox(width: WidgetWidth.w10),
                            Text(S.current.loginGoogleButton),
                          ],
                        ),
                ),
              ),
              if (!viewModel.isFirebaseSupported &&
                  (viewModel.unsupportedMessage?.isNotEmpty ?? false)) ...[
                SizedBox(height: WidgetHeight.h16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppMargin.m32),
                  child: Text(
                    viewModel.unsupportedMessage!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (Platform.isIOS) ...[
                SizedBox(height: WidgetHeight.h16),
                SizedBox(
                  width: context.width * 0.8,
                  height: WidgetHeight.h50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IgnorePointer(
                        ignoring:
                            viewModel.isAppleLoading ||
                            !viewModel.isFirebaseSupported,
                        child: SignInWithAppleButton(
                          style: SignInWithAppleButtonStyle.black,
                          onPressed: () => _handleAppleLogin(viewModel),
                        ),
                      ),
                      if (viewModel.isAppleLoading)
                        Positioned(
                          child: SizedBox(
                            width: WidgetWidth.w20,
                            height: WidgetHeight.h20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
