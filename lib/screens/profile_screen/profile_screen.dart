import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:holy_quran/generated/l10n.dart';
import 'package:holy_quran/main.dart';
import 'package:holy_quran/routes/routes_manager.dart';
import 'package:holy_quran/values/assets_manager.dart';
import 'package:holy_quran/values/color_manager.dart';
import 'package:holy_quran/values/font_manager.dart';
import 'package:holy_quran/values/spacing_manager.dart';
import 'package:holy_quran/values/values_manager.dart';
import 'package:provider/provider.dart';

import 'profile_screen_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ProfileScreenViewModel>()..init(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileScreenViewModel>(
      builder: (context, viewModel, child) {
        final navigator = Navigator.of(context);

        void showLogoutDialog() {
          showDialog(
            context: context,
            builder: (_) => LogoutConfirmationDialog(
              onConfirm: () async {
                await viewModel.logout();
                navigator.pushNamedAndRemoveUntil(
                  RoutesManager.loginRoute,
                  (route) => false,
                );
              },
            ),
          );
        }

        return SizedBox(
          width: context.width,
          height: context.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: WidgetHeight.h40),
              Image.asset(
                ImageAssets.userImage,
                width: WidgetWidth.w85,
                height: WidgetHeight.h85,
              ),

              SizedBox(height: WidgetHeight.h10),
              if (viewModel.isLoading)
                const CircularProgressIndicator()
              else
                Text(
                  viewModel.userName.isNotEmpty
                      ? viewModel.userName
                      : S.current.profileDefaultName,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: FontSizeManager.s20,
                  ),
                ),
              SizedBox(height: WidgetHeight.h60),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: HorizontalSpacing.meduimSpace16,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: showLogoutDialog,
                    borderRadius: BorderRadius.circular(WidgetBorderRadius.b12),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: WidgetHeight.h12),
                      child: Row(
                        children: [
                          SvgPicture.asset(IconAssets.logOut),
                          SizedBox(width: WidgetWidth.w8),
                          Text(
                            S.current.commonLogout,
                            style: TextStyle(
                              fontSize: FontSizeManager.s14,
                              fontWeight: FontWeight.w500,
                              color: ColorManager.newColor,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
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

class LogoutConfirmationDialog extends StatelessWidget {
  final Future<void> Function() onConfirm;
  const LogoutConfirmationDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppPadding.p16),
      ),
      title: Text(
        S.current.profileLogoutDialogTitle,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Text(S.current.profileLogoutDialogMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.current.commonCancel),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await onConfirm();
          },
          child: Text(S.current.commonLogout),
        ),
      ],
    );
  }
}
